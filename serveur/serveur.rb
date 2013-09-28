$LOAD_PATH << File.dirname(__FILE__) + "/bibliotheques"

require "web_socket"
require "thread"
require 'CoordinationClient'
require 'Partie'
require 'GestionJoueur'
require 'conf'

Thread.abort_on_exception = true

if ARGV.size != 2
	$stderr.puts("Usage: ruby sample/chat_server.rb ACCEPTED_DOMAIN PORT")
	exit(1)
end

server = WebSocketServer.new(
  :accepted_domains => [ARGV[0]],
  :port => ARGV[1].to_i())
  
puts("Server is running at port %d" % server.port)

coord = CoordinationClient.new

sem=Mutex.new

server.run() do |ws| # ecoute des connexions
	begin # Code du thread joueur
		puts "connexion acceptee"
		ws.handshake()
		
		# On initialise nos mutex/cv pour les communications
		$mutexReception = Mutex.new
		$cvReception = ConditionVariable.new
		
		# On recupère notre numero de joueur (en reveillant les autres thread si la partie peut commencer)
		numJoueur = coord.nouveauJoueur()
		
		# Recuperation du pseudo
		pseudo=ws.receive()
		puts "Pseudo client = "+pseudo
		
		if (numJoueur < 0)
			# La partie est pleine
			ws.send(tojson("etat", -1))
			
			# On ferme la socket
			ws.close()
		else
			sem.synchronize{
				# Attente debut de partie
				coord.attendreDebutPartie()
				ws.send(tojson("numeroJoueur", numJoueur))
				puts numJoueur.to_s+" est reveille"
			}
		
			# Obtention de l'instance de Partie
			partie = coord.obtenirPartie()
			
			# Instanciation du joueur
			joueur = partie.recupererInstanceJoueur(numJoueur)

			gestionJoueur = GestionJoueur.new(ws, partie, joueur, coord)
			joueur.instanceGestionJoueur = gestionJoueur

			gestionJoueur.preparationClient(pseudo)

			semaphore = Mutex.new
			
			pingPrecedent = Time.now.to_i

			# On ping le client toutes les X secondes pour vérifier sa présence
			ping = Thread.new do
				while partie.estDemarree
					sleep($INTERVALLE_PING)
					pingPrecedent = Time.now.to_i
					ws.send("ping")
				end
			end

			threadGestionJoueur = Thread.new do
				gestionJoueur.tourJoueur()
			end
			
			# Gestion des communication : filtre les réponses au ping et les transmissions utiles
			communications = Thread.new do
				while partie.estDemarree
					transmission = ws.receive()
			
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

			sem.synchronize{
				coord.nouvellePartie()
			}
		end
		

		
		ws.close()
	end
end	
