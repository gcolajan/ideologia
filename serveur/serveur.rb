$LOAD_PATH << File.dirname(__FILE__) + "/bibliotheques"

require "web_socket"
require "thread"
require 'CoordinationClient'
require 'Partie'
require 'GestionJoueur'
require 'conf'

Thread.abort_on_exception = true

def tojson(transmission, contenu)
	return {"transmission" => transmission, "contenu" => contenu}.to_s.gsub("=>", ':')
end

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

			# Gestion des communication : filtre les réponses au ping et les transmissions utiles
			communicationClient = Thread.new do
				while partie.estDemarree
					transmission = ws.receive()
				
					if (transmission != "pong")
						gestionJoueur.transmission = transmission
					elsif (Time.now.to_i-pingPrecedent > $REPONSE_PING)
						# Aie: joueur trop long à répondre
				  	end
				end
			end
			
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
