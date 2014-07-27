class Salon
	
	attr_reader :partie
	attr_reader :plein
	attr_reader :nbJoueur
	attr_reader :debutPartie
	attr_reader :condVariable

	class FullSalonException < StandardError
	end

	def initialize

		@partie = Partie.new

		# Création des deux listes concordantes pour la gestion des joueurs présents
		@clients = [nil, nil, nil, nil]

		@semaphoreControle = Mutex.new

		@debutPartie = false
		@nbJoueur = 0

	end

	#Destruction du salon
	def destruction
		@partie = nil
	end

	# Permet au joueur d'attendre le début de la partie
	def attendreDebutPartie(client)
		client.wait()
		return @debutPartie
	end

	# Sur déconnexion du salon on envoie les pseudo des personnes restantes et on mets à jour les tableaux
	def deconnexionJoueur(client)
		@semaphoreControle.synchronize{

			@clients.delete(client)

			transmissionPseudo()

			@nbJoueur -= 1
		}
	end

	def full?
		return (@nbJoueur == 4)
	end

	# Connexion d'un joueur au salon
	def join(client)
		@semaphoreControle.synchronize{
			# Permet de dire quand un salon est plein
			raise StandardError, "Salon is full" if full?

			# On place notre client
			indexJoueur = @clients.index(nil)
			@clients[indexJoueur] = client
			@nbJoueur += 1

			# On transmet tous les pseudo à tout le monde
			transmissionPseudo()

			# Si après l'ajout on est 4 joueurs on commence la partie
			if full?
				@debutPartie = true

				# Réveil des joueurs un par un
				@clients.each { |client|
					client.signal
				}
			end

			# On indique son numéro au client/joueur
			client.num = indexJoueur
		}
	end

	#Transmet le pseudo à chaque joueur présent dans le salon
	def transmissionPseudo()
		# On constitue une liste des pseudos
		pseudos = []
		@clients.each{ |client|
			if (client != nil)
				pseudos.push(client.pseudo)
			end
		}

		# On l'envoie à tous les clients du salon
		@clients.each{ |client|
			if (client != nil)
				client.com.send('waitingWith', pseudos)
			end
		}
	end
end
