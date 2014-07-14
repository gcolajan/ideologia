class Salon
	
	attr_reader :partie
	attr_reader :plein
	attr_reader :nbJoueur
	attr_reader :debutPartie
	attr_reader :condVariable

	def initialize

		@partie = Partie.new
		@plein = false

		# Création des deux listes concordantes pour la gestion des joueurs présents
		@listeJoueur = [nil, nil, nil, nil]
		@listePseudo = [nil, nil, nil, nil]

		@semaphore = Mutex.new
		@condVariable = ConditionVariable.new

		@semaphorePseudo = Mutex.new
		@condVariablePseudo = ConditionVariable.new

		@semaphoreControle = Mutex.new

		@debutPartie = false
		@nbJoueur = 0

		@canceled = false

	end

	#Destruction du salon
	def destruction
		@partie = nil
	end

	def cancelJoin
		@canceled = true
		@semaphore.synchronize{
			@condVariable.signal
		}
	end

	# Permet au joueur d'attendre le début de la partie
	def attendreDebutPartie
		@semaphore.synchronize{
			while(!@debutPartie and !@canceled)
				@condVariable.wait(@semaphore)
			end
		}
		return @debutPartie
	end

	# Sur déconnexion du salon on envoie les pseudo des personnes restantes et on mets à jour les tableaux
	def deconnexionJoueur ws
		@semaphoreControle.synchronize{
			indexDeco = @listeJoueur.index(ws)

			@listeJoueur[indexDeco] = nil
			@listePseudo[indexDeco] = nil

			transmissionPseudo()

			@nbJoueur -= 1
		}
	end

	# Connexion d'un joueur au salon
	def connexionJoueurSalon ws, pseudo
		@semaphoreControle.synchronize{
			# Permet de dire quand un salon est plein
			if(@nbJoueur == 4)
				@plein = true
				return
			end

			# On place les données correctement dans les listes
			@listeJoueur[@listeJoueur.index(nil)] = ws
			@listePseudo[@listeJoueur.index(ws)] = pseudo

			@nbJoueur += 1

			# On transmet tous les pseudo à tout le monde
			transmissionPseudo()

			# Si on a 4 joueurs on commence la partie
			if(@nbJoueur == 4)
				@debutPartie = true
				@plein = true
				@condVariable.broadcast()
			end

			# On retourne le numéro du joueur
			return @listeJoueur.index(ws)
		}
	end

	#Transmet le pseudo à chaque joueur présent dans le salon
	def transmissionPseudo()
		listeEnvoi = @listePseudo
		listeEnvoi = listeEnvoi.keep_if{|pseudo| pseudo != nil}
		@listeJoueur.each{|ws| if(ws)
			ws.send(tojson("waitingWith", @listePseudo))
			end
		}
	end
end
