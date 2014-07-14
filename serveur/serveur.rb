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

nbClients = 0;

EventMachine.run {
	puts("Server is running at %d" % port)


	EventMachine::WebSocket.start(:host => adresseServeur, :port => port, :debug => false) do |ws| # ecoute des connexions
		connexionMutex = Mutex.new
		connectionOpened = ConditionVariable.new

		reception = Reception.new
		reception.addType('pong')
		reception.addType('pseudo')
		reception.addType('join')
		reception.addType('des')
		reception.addType('operation')
		reception.addType('deco')

		# Gestion du ping
		pingThread = Thread.new do
			# We start when the connexion is opened
			connexionMutex.synchronize{
				connectionOpened.wait(connexionMutex)
			}

			while true
				ws.send '{"type":"ping","data":"1"}'
				puts "<!>"
				pingLaunch = Time.now.to_f;
				# We are waiting for a response from the client
				reception.wait('pong', $REPONSE_PING)
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
			pseudo = reception.wait('pseudo')

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
					puts "Salons tous pleins"
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

					indexSalon = reception.wait('join')

					puts "Salon choisi par "+pseudo+" : "+indexSalon.to_s

					salon = listeSalons.at(indexSalon)

					if(salon.plein)
						ws.send(tojson("salonplein", indexSalon))
						redo
					end
				end

				puts pseudo+" commence à attendre"

				numJoueur = salon.connexionJoueurSalon(ws, pseudo)

				puts pseudo+" a le numéro de joueur "+numJoueur.to_s

				ws.send(tojson("joined", listeSalons.index(salon)))

				partie = salon.partie

				joueur = partie.recupererInstanceJoueur(numJoueur)

				gestionJoueur = GestionJoueur.new(ws,partie,joueur,salon)

				reception.wait('deco')

			end while(!salon.debutPartie)

			# We show the last message extracted
			puts "Message reçu après fin du salon d'attente"+transmission.to_s
		end



		ws.onopen{
			nbClients += 1
			puts "connexion acceptee"
			puts ">>> Clients = #{nbClients}"

			# We wake up all the thread waiting for opening
			# pingThread.run()
			# mainThread.run()
			connexionMutex.synchronize{
				connectionOpened.broadcast
			}

		}

		ws.onclose {
			nbClients -= 1
			puts "Connection closed"
			puts "<<< Clients = #{nbClients}"

			pingThread.kill()
			mainThread.kill()
		}

		ws.onmessage { |msg|
			transmission = JSON.parse(msg)
			reception.signal(transmission['type'], transmission['data'])
		}

		ws.onerror { |error|
			puts "websockets error: #{error}"
		}
		
	end
}
