$LOAD_PATH << File.dirname(__FILE__) + "/bibliotheques"

require "web_socket"
require "thread"
require 'CoordinationClient'
require 'Partie'

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
			joueur.definirPseudo(pseudo)
			coord.transmissionPseudo()
			
			# On envoie une synthèse des personnes participant et les idéologies associées
			partenaires = partie.obtenirTableauPartenaires()
			ws.send(tojson("partenaires", partenaires))
			
			# On envoie au client les niveaux idéaux de ses jauges.
			niveaux = joueur.niveauxIdeals()
			ws.send(tojson("jaugesIdeales", niveaux))
			
			while (partie.estDemarree)

				# Envoi du temps pour la synchronisation
				ws.send(tojson("temps", partie.temps()))
				
				# S'il existe un événement, on l'envoie
				if (partie.evenement != nil)
					ws.send(tojson("evenement", partie.obtenirEvenement))
				end
        
				puts "MaJ globale :"+numJoueur.to_s
				
				# Envoi des informations utiles à l'actualisation du client
				ws.send(tojson("listeTerritoires", {'liste' => partie.territoiresPartenaires, 'synthese' => joueur.syntheseTerritoire}))
				ws.send(tojson("positions", partie.positionsJoueurs))
				ws.send(tojson("pcases", partie.presenceCases))
				ws.send(tojson("fonds", joueur.fondsFinanciers))
				ws.send(tojson("jauges", joueur.syntheseJauge))
				#ws.send(tojson("syntheseTerritoires", joueur.syntheseTerritoire))
				
				# Obtenir le joueur courant
				jc = partie.joueurCourant.numJoueur
			
				# Transmettre le joueur courant
				ws.send(tojson("joueurCourant", jc))
			
				# Gestion du tour
				if (numJoueur == jc)
				  	# DEBUG
          			puts numJoueur.to_s+" joue"
				  
					# On attend le lance de des
					ws.receive()
				
					# On calcule les des
					de1, de2 = partie.plateau.lanceDes()
					
					# Envoi du résultat obtenu
					ws.send(tojson("des", [de1,de2]))
				
					# On fait progresser le joueur des des qu'il vient de lancer
					caseCourante, passageDepart = partie.progression(de1+de2)

					# Envoi de la nouvelle position
					ws.send(tojson("position", caseCourante.numCase))

					# Récupération de la rétribution du joueur
					gain = partie.recupererGain(passageDepart)

					# Renseignement du gain obtenu
					ws.send(tojson("gain", gain))

					
					# Recuperation du type d'instance de case
					type  = partie.plateau.recupererTypeCase(caseCourante)
					case type
						when "caseTerritoire"
							# Génération des opérations sur un territoire
							listeId = partie.genererIdOperationsProposees()
							
							# Transmission des identifiants d'opération possibles
							ws.send(tojson("operations", listeId))
							
							# Attente de l'action choisie
							idActionChoisie = ws.receive()
							
							# Vérification des données venant du client
							if((idActionChoisie.to_i.integer?) && listeId.include?(idActionChoisie))
								#Création de l'opération choisie
								operation = Operation.new(idActionChoisie,partie.joueurCourant.ideologie.numero)
								
								# Repercussion du choix
								partie.appliquerOperationTerritoire(operation,caseCourante.territoire)
							else
								operation = Operation.new(listeId[0],partie.joueurCourant.ideologie.numero)
								
								# Repercussion du choix
								partie.appliquerOperationTerritoire(operation,caseCourante.territoire)
							end
		
									  
						when "caseEvenement"
							# On réclame une opération sur événement
							operation = caseCourante.selectionnerOperation()
							  
							# On transmet l'opération à Partie pour son application aux joueurs concernés
							partie.appliquerOperationEvenement(operation)
				
						when "caseDepart" # Muet
							
					end

					# Déclarer le tour suivant
					partie.tourSuivant()
					
					# Réveiller les joueurs inactifs
					partie.reveilFinTour()
					
					# Vérifier que le temps n'est pas dépassé
					partie.temps()

				else # jc != numeroJoueur
					puts numJoueur.to_s+" attend" # DEBUG
					
					# Attendre la fin du tour
					partie.attendreFinTour()
				end
		
			end # Fin du while (partie.estDemarree)
			
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
