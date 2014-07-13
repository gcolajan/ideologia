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


	EventMachine::WebSocket.start(:host => adresseServeur, :port => port, :debug => true) do |ws| # ecoute des connexions
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

		transmission = ""

		ws.onopen{
			puts "connexion acceptee"

			# Gestion du ping
			ping = Thread.new do
				puts "Début du ping"
				while true
					str = '{"type":"ping","data":"1"}'
					puts "test ping"
					ws.send str
					puts "ping sended"
					pingLaunch = Time.now.to_f;
					# We are waiting for a response from the client
					puts "I'll wait"
					pongMutex.synchronize {
						pongResponse.wait(pongMutex, $REPONSE_PING)
					}
					# If the response was too long (or not exists)
					if (Time.now.to_f - pingLaunch >= $REPONSE_PING)
						puts "Disconnected by timeout"
						break
					else
						puts "In Time!"
					end

					# We wait a little before re-ask
					sleep($INTERVALLE_PING_SALON)
				end
			end

		
			# On initialise nos mutex/cv pour les communications
			$mutexReception = Mutex.new
			$cvReception = ConditionVariable.new
			
			# Recuperation du pseudo
			mutexPseudo.synchronize{
				condVarPseudo.wait(mutexPseudo)
			}
			pseudo = transmission["data"]
			puts "Pseudo client = " + pseudo
			
			salon = nil
			numJoueur = -1

			# On crée un salon pour le jeu si aucun salon n'est disponible, sinon on récupère le salon sélectionné
			begin
				
					
				# On cherche à savoir si tous les salons sont pleins
				tousPleins = true
				semSalon.synchronize{
					listeSalons.each{|salon| if(!salon.plein)
						tousPleins = false 
						end
					}
				}
					# Si tous les salons sont pleins, on crée un salon pour le joueur
				if(tousPleins)

					# Création du salon
					salon = Salon.new

					# Ajout du salon à la liste des salons possibles
					semSalon.synchronize{
						listeSalons.push(salon)
					}

					# On envoie l'index du salon au client
					semSalon.synchronize{
						ws.send(tojson("salons", {listeSalons.index(salon) => salon.nbJoueur}))
					}

				# Sinon on envoie la liste des salons avec le nombre de joueurs
				else
					# On crée un dictionnaire pour transmettre les index des salons disponibles avec leur nombre de joueur
					dictionnaireSalon = {}
					semSalon.synchronize{
						listeSalons.each{|salon| if(!salon.plein)
							dictionnaireSalon.merge!({listeSalons.index(salon) => salon.nbJoueur})
							end
						}
					}
					ws.send(tojson("salons", dictionnaireSalon))

					#On récupère l'index du salon choisi
					mutexJoin.synchronize{
						condVarJoin.wait(mutexJoin)
					}
					indexSalon = message

					semSalon.synchronize{
						salon = listeSalons.at(indexSalon["data"])
					}

					#Si le salon est devenu plein avant d'être connecté on le signale et on recommence
					if(salon.plein)
						ws.send(tojson("salonplein", indexSalon))
						redo
					end

				end


				puts "attenteJoueur " + pseudo
				# On recupère notre numero de joueur (en reveillant les autres thread si la partie peut commencer)
				numJoueur = salon.connexionJoueurSalon(ws,pseudo)

				# Le joueur attend les autres pour commencer la partie
				ws.send(tojson("joined", listeSalons.index(salon)))

				# Obtention de l'instance de Partie
				partie = salon.partie
				
				# Instanciation du joueur
				joueur = partie.recupererInstanceJoueur(numJoueur)

				# Création de la gestion du joueur au niveau du salon
				gestionJoueur = GestionJoueur.new(ws, partie, joueur, salon)

				semaphore = Mutex.new


				attenteJoueur = Thread.new do
					salon.attendreDebutPartie()
					gestionJoueur.finAttenteDebutPartie()
				end
				
				# Endormir le thread principal (1 par joueur) tant que la partie n'est pas démarrée ou que le joueur n'a pas quitté le salon
				gestionJoueur.endormirAttenteDebutPartie()

				ping.kill()
				attenteJoueur.kill()
				communications.kill()
				
			end while(!salon.debutPartie)
			
			if(ws)
				# Attente debut de partie
				ws.send(tojson("numeroJoueur", numJoueur))
				puts pseudo+" est reveille"
			
				# Obtention de l'instance de Partie
				partie = salon.partie
				
				# Instanciation du joueur
				joueur = partie.recupererInstanceJoueur(numJoueur)

				# Création de la gestion du joueur pour la partie
				gestionJoueur = GestionJoueur.new(ws, partie, joueur, salon)
				joueur.instanceGestionJoueur = gestionJoueur

				gestionJoueur.preparationClient(pseudo)

				semaphore = Mutex.new
				
				pingPrecedent = Time.now.to_i

				threadGestionJoueur = Thread.new do
					gestionJoueur.tourJoueur()
				end
				
				# Endormir le thread principal (1 par joueur) tant que la partie est démarrée
				partie.endormirFinPartie()

				ping.kill()
				communications.kill()

				# Fin de la partie
				sem.synchronize{ # Le premier accès se fait en écriture
					scores = partie.obtenirScores()
					ws.send(tojson("scores", scores))
				}

				salon.destruction()
			end

			ws.close()
		}


		ws.onclose {
			puts "Connection closed"
		}

		ws.onmessage { |msg|
			transmission = JSON.parse(msg)

			case transmission["type"]
				when "pseudo"
					condVarPseudo.signal
				when "pong"
					pongResponse.signal
				when "des"
					mutexDes.synchronize{
						condVarDes.signal
					}
				when "operation"
					mutexOpe.synchronize{
						condVarOpe.signal
					}
				when "join"
					mutexJoin.synchronize{
						condVarJoin.signal
					}
				when "deco"
					mutexDeco.synchronize{
						condVarDeco
					}
			end
			if transmission["type"] != 'pong'
				listeMessage.push(transmission)
				puts "Received message: #{msg}"
			else
				puts "PONG"
				
			end
		}

		ws.onerror { |error|
			puts "websockets error: #{error}"
		}
		
	end
}
