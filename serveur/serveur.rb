#! /usr/bin/ruby
# encoding: UTF-8

require './conf.rb'

#Thread.abort_on_exception = false

if ARGV.size != 2 and ARGV.size != 0 
	$stderr.puts("Usage: ./serveur.rb ACCEPTED_DOMAIN PORT")
	exit(1)
end

adresseServeur = ""
port = -1

if(ARGV.size == 0)
	adresseServeur = "0.0.0.0"
	port = 8080
elsif(ARGV.size == 2)
	adresseServeur  = ARGV[0]
	port = ARGV[1].to_i
end

sem = Mutex.new

semSalon = Mutex.new

listeSalons = [Salon.new, Salon.new]

EventMachine.run {
	puts("Server is running at %d" % port)


	EventMachine::WebSocket.start(:host => adresseServeur, :port => port) do |ws| # ecoute des connexions
		mutexPseudo = Mutex.new
		condVarPseudo = ConditionVariable.new

		pongMutex = Mutex.new
		pongResponse = ConditionVariable.new

		mutexDes = Mutex.new
		condVarDes = ConditionVariable.new

		mutexOpe = Mutex.new
		condVarOpe = ConditionVariable.new

		mutexJoin = Mutex.new
		condVarJoin = ConditionVariable.new

		mutexDeco = Mutex.new
		condVarDeco = ConditionVariable.new

		connexionMutex = Mutex.new
		connectionOpened = ConditionVariable.new

		transmission = ""

		# Gestion du ping
		pingThread = Thread.new do
			# We start when the connexion is opened
			# connexionMutex.synchronize{
			# 	connectionOpened.wait(connexionMutex)
			# }

			while true
				ws.send '{"type":"ping","data":"1"}'
				puts "ping sended"
				pingLaunch = Time.now.to_f;
				# We are waiting for a response from the client
				pongMutex.synchronize {
					pongResponse.wait(pongMutex, $REPONSE_PING)
				}
				# If the response was too long (or not exists)
				if (Time.now.to_f - pingLaunch >= $REPONSE_PING)
					puts "Disconnected by timeout"
					break
				end

				# We wait a little before re-ask
				sleep($INTERVALLE_PING_SALON)
			end
		end

	
		mainThread = Thread.new do
			# We start when the connexion is opened
			# connexionMutex.synchronize{
			# 	connectionOpened.wait(connexionMutex)
			# }

			# Recuperation du pseudo
			mutexPseudo.synchronize{
				condVarPseudo.wait(mutexPseudo)
			}

			pseudo = transmission["data"]

			puts pseudo + " vient de se connecter"

			salon = nil
			numJoueur = -1

			# On boucle en attendant le début de la partie ou en quittant le salon
			begin
				# On cherche à savoir si tous les salons sont pleins
				tousPleins = true
				listeSalons.each{ |salon| if(!salon.plein)
						tousPleins = false
						break
					end
				}

				if(tousPleins)
					salon = Salon.new
					listeSalons.push(salon)
					ws.send(tojson("salons", listeSalons.index(salon) => salon.nbJoueur))
				else
					dictionnaireSalon = {}
					listeSalons.each{|salon| if(!salon.plein)
							dictionnaireSalon.merge!({listeSalons.index(salon) => salon.nbJoueur})
						end
					}
					ws.send(tojson("salons", dictionnaireSalon))

					puts "Attente choix salon par "+pseudo
					mutexJoin.synchronize{
						condVarJoin.wait(mutexJoin)
					}

					indexSalon = transmission["data"]

					puts "Salon choisi par "+pseudo+" : "+indexSalon

					if(salon.plein)
						ws.send(tojson("salonplein", indexSalon))
						redo
					end
				end

				puts pseudo + " commence à attendre"

				numJoueur = salon.connexionJoueurSalon(ws, salon)

				ws.send(tojson("joined", listeSalons.index(salon)))

				partie = salon.partie

				joueur = partie.recupererInstanceJoueur(numJoueur)


			end while(!salon.debutPartie)

			# We show the last message extracted
			puts transmission
		end



		ws.onopen{
			puts "connexion acceptee"

			# We wake up all the thread waiting for opening
			pingThread.run()
			mainThread.run()
			# connexionMutex.synchronize{
			# 	connectionOpened.broadcast
			# }
		}

		ws.onclose {
			puts "Connection closed"
		}

		ws.onmessage { |msg|
			puts msg
			transmission = JSON.parse(msg)

			puts "Type de transmission reçu "+transmission["type"]

			case transmission["type"]
				when "pseudo"
					mutexPseudo.synchronize{
						condVarPseudo.signal
					}
				when "pong"
					pongMutex.synchronize{
						pongResponse.signal
					}
				when "des"
					mutexDes.synchronize{
						condVarDes.signal
					}
				when "operation"
					mutexOpe.synchronize{
						condVarOpe.signal
					}
				when "join"
					puts "Transmission de type join repérée"
					mutexJoin.synchronize{
						condVarJoin.signal
					}
				when "deco"
					mutexDeco.synchronize{
						condVarDeco
					}
			end
		}

		ws.onerror { |error|
			puts "websockets error: #{error}"
		}
		
	end
}
