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
		@listeVerroux = {}

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

	# We wake up the player concerned (only him !)
	def cancelJoin(ws)
		index = @listeJoueur.index(ws)
		@listeVerroux[index]['mutex'].synchronize {
			@listeVerroux[index]['resource'].signal
		}
		deconnexionJoueur(ws)
	end

	# Permet au joueur d'attendre le début de la partie
	def attendreDebutPartie(ws)
		verroux = @listeVerroux[@listeJoueur.index(ws)]

		verroux['mutex'].synchronize {
			verroux['resource'].wait(verroux['mutex'])
		}
		puts "Fin attente!"
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
			@listeVerroux[@listeJoueur.index(ws)] = {
				'mutex'    => Mutex.new,
				'resource' => ConditionVariable.new
			}

			@nbJoueur += 1

			# On transmet tous les pseudo à tout le monde
			transmissionPseudo()

			# Si on a 4 joueurs on commence la partie
			if(@nbJoueur == 4)
				@debutPartie = true
				@plein = true
				# Réveil des joueurs un par un
				@listeVerroux.each { |joueur, verroux|
					verroux['mutex'].synchronize {
						verroux['resource'].signal()
					}
				}
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
