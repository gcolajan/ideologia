class Salon
	
	attr_reader :partie
	attr_reader :plein
	attr_reader :nbJoueur
	attr_reader :debutPartie

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

	end

	#Destruction du salon
	def destruction
		@partie = nil
	end

	# Permet au joueur d'attendre le début de la partie
	def attendreDebutPartie
		@semaphore.synchronize{
			while(!@debutPartie)
				@condVariable.wait(@semaphore)
			end
		}
	end

	# Sur déconnexion du salon on envoie les pseudo des personnes restantes et on mets à jour les tableaux
	def deconnexionJoueur ws
		@semaphoreControle.synchronize{
			indexDeco = @listeJoueur.index(ws)
			@listeJoueur.insert(indexDeco, nil)
			@listePseudo.insert(indexDeco, nil)
			transmissionPseudo()
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
			@listeJoueur.insert(@listeJoueur.index(nil), ws)
			@listePseudo.insert(@listeJoueur.index(ws), pseudo)

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
			ws.send(tojson("pseudo", @listePseudo))
			end
		}
	end
end
