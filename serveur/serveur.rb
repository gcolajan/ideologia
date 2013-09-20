$LOAD_PATH << File.dirname(__FILE__) + "/bibliotheques"

require "web_socket"
require "thread"
require 'CoordinationClient'
require 'Partie'
require 'GestionJoueur'

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

			gestionJoueur.preparationClient(pseudo)

			queue = Queue.new

			semaphore = Mutex.new

			communicationClient = Thread.new do
				while 1
					sleep(0.1)
					transmission = nil
					semaphore.synchronize{
						transmission = queue.pop
					}
					if(transmission != "ping")
						gestionJoueur.transmission = transmission
					else
						queue.push(transmission)
				  	end
				end
			end

			ping = Thread.new do
				while 1
					sleep(0.1)
					transmission = nil
					semaphore.synchronize{
						transmission = queue.pop
					}
					if(transmission == "ping")
						pingRecu = Time.now.to_i
						pingAncien = gestionJoueur.dernierPing
						if(pingRecu - pingAncien > 30)
							puts("ping trop vieux")
						else
							gestionJoueur.dernierPing = pingRecu
						end
					else
						queue.push(transmission)
					end
				end
			end

			threadGestionJoueur = Thread.new do
				gestionJoueur.tourJoueur()
			end

			while partie.estDemarree
				queue.push(ws.receive())
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
