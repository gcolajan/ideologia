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
		#Ici on doit créer un salon pour le jeu si aucun salon n'est disponible, sinon on récupère le salon sélectionné
		begin
			semSalon.synchronize{
				#Si tous les salons sont pleins, on crée un salon pour le joueur
				tousPleins = true
				listeSalons.each{|salon| if(!salon.plein)
					tousPleins = false 
					end}
				if(tousPleins)
					salon = Salon.new
					listeSalons.push(salon)
					#On envoie l'identifiant du salon
					ws.send(tojson("salons", {listeSalons.index(salon) => salon.nbJoueur}))
				else
					#Sinon on envoie la liste des salons avec le nombre de joueurs
					dictionnaireSalon = {}
					listeSalons.each{|salon| dictionnaireSalon.merge!({listeSalons.index(salon) => salon.nbJoueur})}
					ws.send(tojson("salons", dictionnaireSalon))
					#On récupère l'index du salon choisi
					indexSalon = todata(ws.receive())["data"]
					salon = listeSalons.at(indexSalon)
					#Si le salon est devenu plein avant d'être connecté on le signal
					if(salon.plein)
						ws.send(tojson("salonplein", indexSalon))
						redo
					end
				end
			}

			# On recupère notre numero de joueur (en reveillant les autres thread si la partie peut commencer)
			numJoueur = salon.connexionJoueurSalon(ws,pseudo)

			attenteJoueur = Thread.new do
				salon.attendreDebutPartie()
			end

			#On doit pouvoir dire quand le joueur sort du salon
			gestionDeconnexion = Thread.new do
				if(todata(ws.receive())["data"] == "deco")
					salon.deconnexionJoueur(ws)
					#Si le dernier joueur présent sur le salon se déconnecte, il faut supprimer le salon
					if(salon.nbJoueur == 0 && listeSalons.size > 2)
						listeSalons.delete(salon)
					end
				end
			end

			attenteJoueur.kill()
			gestionDeconnexion.kill()
		end while(!salon.debutPartie)
		
		if(ws)
			sem.synchronize{
				# Attente debut de partie
				ws.send(tojson("numeroJoueur", numJoueur))
				puts numJoueur.to_s+" est reveille"
			}
		
			# Obtention de l'instance de Partie
			partie = salon.partie
			
			# Instanciation du joueur
			joueur = partie.recupererInstanceJoueur(numJoueur)

			gestionJoueur = GestionJoueur.new(ws, partie, joueur, salon)
			joueur.instanceGestionJoueur = gestionJoueur

			gestionJoueur.preparationClient(pseudo)

			semaphore = Mutex.new
			
			pingPrecedent = Time.now.to_i

			# On ping le client toutes les X secondes pour vérifier sa présence
			ping = Thread.new do
				while ws
					sleep($INTERVALLE_PING)
					pingPrecedent = Time.now.to_i
					@ws.send("ping")
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
	end
end	
