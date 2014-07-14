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

authorizedTypes = ['pong', 'pseudo', 'join', 'des', 'operation', 'deco']

def unjoin_method(params)
	puts "Executed unjoined method !"
	params['salon'].cancelJoin(params['ws'])
end

specialTypes = {
	'unjoin' => method(:unjoin_method)
}

EventMachine.run {
	puts("Server is running at %d" % port)


	EventMachine::WebSocket.start(:host => adresseServeur, :port => port, :debug => false) do |ws| # ecoute des connexions
		connexionMutex = Mutex.new
		connectionOpened = ConditionVariable.new

		communication = nil
		
		condVarAttenteDebut = nil

		salon = nil

	
		mainThread = Thread.new do
			# We start when the connexion is opened
			connexionMutex.synchronize{
				connectionOpened.wait(connexionMutex)
			}

			# Recuperation du pseudo
			pseudo = communication.receive('pseudo')

			puts pseudo + " vient de se connecter"

			
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
					communication.send("salons", listeSalons.index(salon) => salon.nbJoueur)
				else
					dictionnaireSalon = {}
					listeSalons.each{|salon| if(!salon.plein)
							dictionnaireSalon.merge!({listeSalons.index(salon) => salon.nbJoueur})
						end
					}
					communication.send("salons", dictionnaireSalon)

					puts "Attente choix salon par "+pseudo

					indexSalon = communication.receive('join')

					puts "Salon choisi par "+pseudo+" : "+indexSalon.to_s

					salon = listeSalons.at(indexSalon)
					communication.tellParams('unjoin', {
						'salon' => salon, 'ws' => ws})

					if(salon.plein)
						communication.send("salonplein", indexSalon)
						redo
					end
				end

				puts pseudo+" commence à attendre"

				numJoueur = salon.connexionJoueurSalon(ws, pseudo)

				puts pseudo+" a le numéro de joueur "+numJoueur.to_s

				puts listeSalons.index(salon)
				communication.send("joined", listeSalons.index(salon).to_s)

				puts "Envoie de l'index du salon effectue"

				partie = salon.partie

				joueur = partie.recupererInstanceJoueur(numJoueur)

				gestionJoueur = GestionJoueur.new(ws,partie,joueur,salon)

				puts "Debut d'attente de "+pseudo

				debutPartie = salon.attendreDebutPartie(ws)

				if not debutPartie
					puts "Le joueur s'est barré"
				else
					puts "La partie peut commencer !"
				end

				puts "Fin d'attente de "+pseudo

			end while(!salon.debutPartie)

			# We show the last message extracted
			puts "Message reçu après fin du salon d'attente"+transmission.to_s
		end



		ws.onopen{
			communication = Communication.new(ws)
			communication.setAuthorizedTypes(authorizedTypes)
			communication.setSpecialTypes(specialTypes)

			communication.startPing()

			nbClients += 1
			puts "connexion acceptee"
			puts ">>> Clients = #{nbClients}"

			connexionMutex.synchronize{
				connectionOpened.broadcast
			}

		}

		ws.onclose {
			nbClients -= 1
			puts "Connection closed"
			puts "<<< Clients = #{nbClients}"

			puts ws.to_s
			if(salon)
				salon.deconnexionJoueur(ws)
			end
			mainThread.kill()
		}

		ws.onmessage { |msg|
			test = JSON.parse(msg)
			if(test["type"]  == "deco")
				condVarAttenteDebut.signal
				salon.deconnexionJoueur(ws)
			end
			communication.filterReception(msg)
		}

		ws.onerror { |error|
			puts "websockets error: #{error}"
		}
		
	end
}
