$LOAD_PATH << File.dirname(__FILE__) + '/jeu'

class GestionJoueur

  def initialize(joueur, communication, salon)
    @joueur = joueur
    @com = communication
    @salon = salon

    @partie = salon.partie
	end


  def newTurn
    # Mettre à jour des données du joueur
    updatePlayerData

    # Obtenir le joueur courant
    jc = @partie.joueurCourant.numJoueur

    # Transmettre le joueur courant
    @com.send('joueurCourant', jc.to_s)

    # Gestion du tour
    if @joueur.numJoueur == jc
      currentPlayerTurn
      @partie.finTour # Fin du tour du joueur courant
    else
      @partie.attendreFinTour # Attendre la fin du tour
    end
  end

  private

  # Permit to refresh the dataset of players
	def updatePlayerData

    # First, we synchronize both client & server
    if @partie.started?
      @com.send('temps', @salon.partie.timeLeft.to_i.to_s)
    end

    playerData = []
    @partie.listeJoueurs.each { |joueur|
      territories = {}

      joueur.listeTerritoires.each { |territory|
        territories[territory.idTerritoire] = territory.etatJauges()
      }

      playerData.push(territories)
    }

    # Useful informations about territories to refresh client's UI
    @com.send('playersData', playerData)
	end

	def currentPlayerTurn
		# On attend le lance de des
		@com.receive('des',10)
		# On calcule les des
		de1, de2 = @partie.plateau.lanceDes
		
		# Envoi du résultat obtenu
		@com.send('des', [de1, de2])
	
		# On fait progresser le joueur des des qu'il vient de lancer
		caseCourante, passageDepart = @partie.progression(de1+de2)

		# Envoi de la nouvelle position
		@salon.broadcast('jcPosition', caseCourante.numCase.to_s)

		# Récupération de la rétribution du joueur
		gain = @partie.recupererGain(passageDepart)

		# Renseignement du gain obtenu
		@com.send('gain', gain.to_s) #@joueur.fondsFinanciers.to_s

		# Permet de faire les différentes actions sur la case courante
		action(caseCourante)
  end


  # Propose the action that the player can do on the specified space
  def action(caseCourante)

    # Recuperation du type d'instance de case
    type = @partie.plateau.recupererTypeCase(caseCourante)
    case type
      when 'caseTerritoire'
        # Génération des opérations sur un territoire
        listeId = @partie.genererIdOperationsProposees(caseCourante.territoire.joueurPossesseur.ideologie)

        # Transmission des identifiants d'opération possibles et attente d'un choix
        idAction = @com.ask('operations', listeId, 'operation', 30).to_i


        appliedAction = ((idAction.integer?) && listeId.include?(idAction)) ? idAction : listeId[0]
        # Repercussion du choix (l'action proposée sera la première si la réponse n'est pas correcte)
        @partie.appliquerOperationTerritoire(
            Operation.new(
                appliedAction,
                caseCourante.territoire.joueurPossesseur.ideologie.numero
            ),
            caseCourante.territoire
        )
        @salon.broadcast("appliedOperation", appliedAction.to_s)

      when 'caseEvenement'
        # On réclame une opération sur événement
        operation = caseCourante.selectionnerOperation()

        # On transmet l'opération à Partie pour son application aux joueurs concernés
        @partie.appliquerOperationEvenement(operation)

        # Send the id of the event to each client
        @salon.broadcast('evenement', operation.idEvenement.to_s)

      when 'caseDepart' # Muet

      else
        $LOGGER.error 'GestionJoueur::action: unknown case.'
    end
  end
end
