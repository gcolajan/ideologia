require './conf.rb'

#Thread.abort_on_exception = false

if ARGV.size != 2
	$stderr.puts("Usage: ruby sample/chat_server.rb ACCEPTED_DOMAIN PORT")
	exit(1)
end

server = WebSocketServer.new(
  :accepted_domains => [ARGV[0]], 
  :port => ARGV[1].to_i())
  
puts("Server is running at port %d" % server.port)

sem = Mutex.new

semSalon = Mutex.new

listeSalons = [Salon.new, Salon.new]

server.run() do |ws| # ecoute des connexions
	begin # Code du thread joueur
		puts "connexion acceptee"
		ws.handshake()
		
		# On initialise nos mutex/cv pour les communications
		$mutexReception = Mutex.new
		$cvReception = ConditionVariable.new
		
		# Recuperation du pseudo
		pseudo = todata(ws.receive())["data"]

		puts "Pseudo client = "+pseudo
		
		salon = nil
		numJoueur = -1

		# On crée un salon pour le jeu si aucun salon n'est disponible, sinon on récupère le salon sélectionné
		begin
			
				
				#On cherche à savoir si tous les salons sont pleins
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
				indexSalon = todata(ws.receive())["data"]

				semSalon.synchronize{
					salon = listeSalons.at(indexSalon)
				}

				#Si le salon est devenu plein avant d'être connecté on le signale et on recommence
				if(salon.plein)
					ws.send(tojson("salonplein", indexSalon))
					redo
				end

			end


			puts "attenteJoueur "+pseudo
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
			
			pingPrecedent = Time.now.to_i

			# On ping le client toutes les X secondes pour vérifier sa présence
			ping = Thread.new do
				while !salon.debutPartie
					sleep($INTERVALLE_PING_SALON)
					pingPrecedent = Time.now.to_i
					ws.send(tojson("ping",""))
				end
			end

			attenteJoueur = Thread.new do
				salon.attendreDebutPartie()
				gestionJoueur.finAttenteDebutPartie()
			end
			
			# Gestion des communication : filtre les réponses au ping et les transmissions utiles
			communications = Thread.new do
				while !salon.debutPartie
					transmission = ws.receive()["type"]
			
					if (transmission == "deco")
						gestionJoueur.finAttenteDebutPartie()
						salon.deconnexionJoueur(ws)
					elsif (Time.now.to_i-pingPrecedent > $REPONSE_PING)
						# On considère qu'un client ne répondant pas dans les temps est un joueur déconnecté
						salon.deconnexionJoueur(ws)
				  	end
				end
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

			# On ping le client toutes les X secondes pour vérifier sa présence
			ping = Thread.new do
				while partie.estDemarree
					sleep($INTERVALLE_PING_PARTIE)
					pingPrecedent = Time.now.to_i
					ws.send(tojson("ping",""))
				end
			end

			threadGestionJoueur = Thread.new do
				gestionJoueur.tourJoueur()
			end
			
			# Gestion des communication : filtre les réponses au ping et les transmissions utiles
			communications = Thread.new do
				while partie.estDemarree
					transmission = ws.receive()["type"]
			
					if (transmission != "pong")
						gestionJoueur.transmission = transmission
						$mutexReception.synchronize {
							$cvReception.signal
						}
					elsif (Time.now.to_i-pingPrecedent > $REPONSE_PING)
						# On considère qu'un client ne répondant pas dans les temps est un joueur déconnecté
						partie.deconnexionJoueur(numJoueur)
				  	end
				end
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
	# rescue Exception => e
	# 	e.message
	# 	e.backtrace.inspect
	# 	puts "Exception attrapee !"
	end
end	
