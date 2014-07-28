$LOAD_PATH << File.dirname(__FILE__) + "/jeu"

class GestionJoueur

	def initialize(instanceCommunication, instancePartie, instanceJoueur, instanceSalon)
		@communication = instanceCommunication
		@partie = instancePartie
		@joueur = instanceJoueur
		@salon = instanceSalon
	end

	def preparationClient

		# On envoie une synthèse des personnes participant et les idéologies associées
		partenaires = @partie.obtenirTableauPartenaires
		envoieDonnees("partenaires", partenaires)
		
		# On envoie au client les niveaux idéaux de ses jauges.
		niveaux = @joueur.niveauxIdeals
		envoieDonnees("jaugesIdeales", niveaux)

	end


	def miseAJour

		# Envoi du temps pour la synchronisation
		envoieDonnees('temps', @partie.temps.to_s)
				
		# S'il existe un événement, on l'envoie
		if @partie.evenement != nil
			envoieDonnees('evenement', @partie.obtenirEvenement)
		end

		puts "MaJ globale :#{@joueur.pseudo}"
		
		# Envoi des informations utiles à l'actualisation du client
		envoieDonnees("listeTerritoires", {'liste' => @partie.territoiresPartenaires, 'synthese' => @joueur.syntheseTerritoire})
		envoieDonnees("positions", @partie.positionsJoueurs)
		envoieDonnees("pcases", @partie.presenceCases)
		envoieDonnees("fonds", @joueur.fondsFinanciers.to_s)
		envoieDonnees("jauges", @joueur.syntheseJauge)
		# envoieDonnees("syntheseTerritoires", @joueur.syntheseTerritoire)

	end

	def actionJoueur(caseCourante)

		# Recuperation du type d'instance de case
		type = @partie.plateau.recupererTypeCase(caseCourante)
		case type
			when "caseTerritoire"
				# Génération des opérations sur un territoire
				listeId = @partie.genererIdOperationsProposees()
				
				# Transmission des identifiants d'opération possibles et attente d'un choix
				idActionChoisie = envoieDonneesAvecReponse("operations", listeId, 30)

				puts "L'action choisie est #{idActionChoisie}"

				# Vérification des données venant du client
				if((idActionChoisie.to_i.integer?) && listeId.include?(idActionChoisie))
					# Création de l'opération choisie
					operation = Operation.new(idActionChoisie, @partie.joueurCourant.ideologie.numero)
					
					# Repercussion du choix
					@partie.appliquerOperationTerritoire(operation, caseCourante.territoire)
				else
					operation = Operation.new(listeId[0], @partie.joueurCourant.ideologie.numero)
					
					# Repercussion du choix
					@partie.appliquerOperationTerritoire(operation, caseCourante.territoire)
				end

						  
			when "caseEvenement"
				# On réclame une opération sur événement
				operation = caseCourante.selectionnerOperation()
				  
				# On transmet l'opération à Partie pour son application aux joueurs concernés
				@partie.appliquerOperationEvenement(operation)
	
			when "caseDepart" # Muet
				
		end
	end

	def tourDuJoueur

		# DEBUG
		puts "#{@joueur.pseudo} joue"

		# On attend le lance de des
		@communication.receive('des',10)
		# On calcule les des
		de1, de2 = @partie.plateau.lanceDes
		
		# Envoi du résultat obtenu
		envoieDonnees('des', [de1, de2])
	
		# On fait progresser le joueur des des qu'il vient de lancer
		caseCourante, passageDepart = @partie.progression(de1+de2)

		# Envoi de la nouvelle position
		envoieDonnees('position', caseCourante.numCase.to_s)

		# Récupération de la rétribution du joueur
		gain = @partie.recupererGain(passageDepart)

		# Renseignement du gain obtenu
		envoieDonnees('gain', gain.to_s)

		# Permet de faire les différentes actions sur la case courante
		actionJoueur(caseCourante)
		

		# Déclarer le tour suivant
		@partie.tourSuivant
		
		# Réveiller les joueurs inactifs
		@partie.reveilFinTour
		
		# Vérifier que le temps n'est pas dépassé
		@partie.temps
	end

	def tourJoueur
		while @partie.estDemarree

			# Mettre à jour des données du joueur
			miseAJour

			# Obtenir le joueur courant
			jc = @partie.joueurCourant.numJoueur
		
			# Transmettre le joueur courant
			envoieDonnees("joueurCourant", jc.to_s)
		
			# Gestion du tour
			if (@joueur.numJoueur == jc)

				# Appel de la fonction gérant le tour du joueur courant
			  	tourDuJoueur()

			else # jc != numeroJoueur
				puts "#{@joueur.pseudo} attend" # DEBUG
				
				# Attendre la fin du tour
				@partie.attendreFinTour()
			end
		
		end # Fin du while (partie.estDemarree)

	end
	
	
	def envoieDonnees(identifiantCommunication, donnees)
		@communication.send(identifiantCommunication, donnees)
	end
	
	def envoieDonneesAvecReponse(identifiantCommunication, donnees, delai)
		@communication.send(identifiantCommunication, donnees, delai)
		return @communication.receive('operation', delai)
	end

	def envoyerSignalDeconnexion(numeroJoueurDeconnecte)
		envoieDonnees("deconnexionJoueur", numeroJoueurDeconnecte)
	end
end
