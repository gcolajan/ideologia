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

def unjoin_method(client, params)
	puts "Executed unjoined method !"
	client.quitSalon()
end

specialTypes = {
	'unjoin' => method(:unjoin_method)
}

EventMachine.run {
	puts("Server is running at %d" % port)


	EventMachine::WebSocket.start(:host => adresseServeur, :port => port, :debug => true) do |ws| # ecoute des connexions
		connexionMutex = Mutex.new
		connectionOpened = ConditionVariable.new

		client = nil
		communication = nil
		
		condVarAttenteDebut = nil

		salon = nil

	
		mainThread = Thread.new do
			# We start when the connexion is opened
			connexionMutex.synchronize{
				connectionOpened.wait(connexionMutex)
			}

			# Recuperation du pseudo
			client.pseudo = communication.receive('pseudo')

			puts client.pseudo + " vient de se connecter"

			
			numJoueur = -1

			# On boucle en attendant le début de la partie ou en quittant le salon
			begin
				# On cherche à savoir si tous les salons sont pleins
				tousPleins = true
				listeSalons.each{ |salon|
					if not salon.full?
						tousPleins = false
						break
					end
				}

				if(tousPleins)
					puts "Salons tous pleins"
					salon = Salon.new
					listeSalons.push(salon)
					client.salon = salon
					communication.send("salons", listeSalons.index(salon) => salon.nbJoueur)
				else
					dictionnaireSalon = {}
					listeSalons.each{|salon| if(!salon.plein)
							dictionnaireSalon.merge!({listeSalons.index(salon) => salon.nbJoueur})
						end
					}
					communication.send("salons", dictionnaireSalon)

					puts "Attente choix salon par "+client.pseudo

					indexSalon = communication.receive('join')

					puts "Salon choisi par "+client.pseudo+" : "+indexSalon.to_s
					client.salon = listeSalons.at(indexSalon)

					if client.salon.full?
						communication.send("salonplein", indexSalon)
						redo
					end
				end

				puts client.pseudo+" commence à attendre"

				numJoueur = client.salon.connexionJoueurSalon(client)

				puts client.pseudo+" a le numéro de joueur "+numJoueur.to_s

				#puts listeSalons.index(client.salon)
				communication.send("joined", listeSalons.index(client.salon).to_s)

				puts "Envoie de l'index du salon effectue"

				partie = client.salon.partie

				joueur = partie.recupererInstanceJoueur(numJoueur)


				# À reprendre pour transmettre client et pas les éléments séparément
				gestionJoueur = GestionJoueur.new(communication,partie,joueur,client.salon)
				joueur.obtenirInstanceGestionJoueur(gestionJoueur)

				puts "Debut d'attente de "+client.pseudo

				debutPartie = !client.salon.debutPartie ? client.salon.attendreDebutPartie(client) : true

				if not debutPartie
					puts "Le joueur s'est barré"
				else
					puts "La partie peut commencer !"
				end

				puts "Fin d'attente de "+client.pseudo

			end while(!debutPartie)

			puts "Debut partie"

			gestionJoueur.preparationClient(client.pseudo)
			gestionJoueur.tourJoueur()
		
			communication.send("score", partie.obtenirScores)
			ws.close()
		end



		ws.onopen{
			client = Client.new
			communication = Communication.new(ws, client)
			communication.setAuthorizedTypes(authorizedTypes)
			communication.setSpecialTypes(specialTypes)

			communication.startPing()

			client.com = communication

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
			if(client.salon)
				client.salon.deconnexionJoueur(ws)
			end
			mainThread.kill()
		}

		ws.onmessage { |msg|
			test = JSON.parse(msg)
			if(test["type"]  == "deco")
				condVarAttenteDebut.signal
				client.salon.deconnexionJoueur(ws)
			end
			communication.filterReception(msg)
		}

		ws.onerror { |error|
			puts "websockets error: #{error}"
		}
		
	end
}
