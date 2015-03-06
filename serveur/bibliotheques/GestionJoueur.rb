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
      puts "#{@joueur.pseudo} attend" # DEBUG
      @partie.attendreFinTour # Attendre la fin du tour
    end
  end

  private

  # Permit to refresh the dataset of players
	def updatePlayerData

		puts "Global update for \"#{@joueur.pseudo}\""

    playerData = []
    @partie.listeJoueurs.each { |joueur|
      data = {
        'position' => joueur.position,
        'territories' => {}
      }

      joueur.listeTerritoires.each { |territory|
        data['territories'].merge!({territory.idTerritoire => territory.calculerDecalage()})
      }

      playerData.push(data)
    }

    # Useful informations to refresh client's UI
    @com.send('updates', {
        'playersData' => playerData,
        'positions' => @partie.positionsJoueurs,
        'pcases' => @partie.presenceCases,
        'fonds' => @joueur.fondsFinanciers.to_s,
        'jauges'=> @joueur.syntheseJauge
        #'syntheseTerritoires' => @joueur.syntheseTerritoire
    })
	end

	def currentPlayerTurn

		# DEBUG
		puts "#{@joueur.pseudo} joue"

		# On attend le lance de des
		@com.receive('des',10)
		# On calcule les des
		de1, de2 = @partie.plateau.lanceDes
		
		# Envoi du résultat obtenu
		@com.send('des', [de1, de2])
	
		# On fait progresser le joueur des des qu'il vient de lancer
		caseCourante, passageDepart = @partie.progression(de1+de2)

		# Envoi de la nouvelle position
		@com.send('position', caseCourante.numCase.to_s)

		# Récupération de la rétribution du joueur
		gain = @partie.recupererGain(passageDepart)

		# Renseignement du gain obtenu
		@com.send('gain', gain.to_s)

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
        listeId = @partie.genererIdOperationsProposees()

        # Transmission des identifiants d'opération possibles et attente d'un choix
        idAction = @com.ask('operations', listeId, 'operation', 30)

        puts "L'action choisie est #{idAction}"

        # Repercussion du choix (l'action proposée sera la première si la réponse n'est pas correcte)
        @partie.appliquerOperationTerritoire(
            Operation.new(
                ((idAction.to_i.integer?) && listeId.include?(idAction)) ? idAction : listeId[0],
                @partie.joueurCourant.ideologie.numero
            ),
            caseCourante.territoire
        )

      when 'caseEvenement'
        # On réclame une opération sur événement
        operation = caseCourante.selectionnerOperation()

        # On transmet l'opération à Partie pour son application aux joueurs concernés
        @partie.appliquerOperationEvenement(operation)

        # Send the id of the event to each client
        @salon.broadcast('evenement', operation.idEvenement.to_s)

      when 'caseDepart' # Muet

      else
       puts 'GestionJoueur::action: unknown case.'
    end
  end
end
