class Salon
	
	attr_reader :demarree
	attr_reader :partie
	attr_reader :nbJoueur
	attr_reader :condVariable
	attr_writer :demo

	class FullSalonException < StandardError
	end

	def initialize

		@partie = Partie.new

		# Création des deux listes concordantes pour la gestion des joueurs présents
		@clients = [nil, nil, nil, nil]

		@semaphoreControle = Mutex.new

		@demarree = false
		@nbJoueur = 0

		# Demo mode, false by default
		@demo = false

	end

	# On réveille tous les clients, la partie va démarrer
	def wakeup
		@demarree = true
		@clients.each { |client| client.signal }
	end

	# Sur déconnexion du salon on envoie les pseudo des personnes restantes et on mets à jour les tableaux
	def deconnexionJoueur(client, code=nil)
		put "DECO J"
		@semaphoreControle.synchronize{
			@clients[@clients.index(client)] = nil
			if(code != 4000)
				transmissionPseudo()
			end

			@nbJoueur -= 1
		}

		put "bot? #{client.bot?}"
		if fullOfBots? or @nbJoueur == 0
			close()
		end
	end

	def fullOfBots?
		@clients.each{ |client|
			unless client.com.bot?
				return false
			end
		}
		return true
	end

	def isDemo?
		return @demo
	end

	def full?
		return (@nbJoueur == 4)
	end

	def close
		unless @demarree
			ServerKnowledge.instance.listeSalons.addOne
		end
		@partie = nil
		ServerKnowledge.instance.listeSalon.unsetSalon(self)
	end

	def safeDelete
		@clients.each{	|client|
			client.close
		}
		close()
	end

	# Connexion d'un joueur au salon
	def addPlayer(client)
		@semaphoreControle.synchronize {

			# Permet de dire quand un salon est plein

			# On place notre client
			indexJoueur = @clients.index(nil)
			@clients[indexJoueur] = client
			@nbJoueur += 1

			# On transmet tous les pseudo à tout le monde
			transmissionPseudo()

			# Si après l'ajout on est 4 joueurs on commence la partie
			if full?
				# Réveil des joueurs un par un
				@clients.each { |client|
					unless client.nil?
					  client.signal
					else
						safeDelete()
						return
          end
				}

				# Le salon est plein, on va pouvoir démarrer la partie, on ajoute donc une instance
				ServerKnowledge.instance.listeSalons.addOne
			end

			# On indique son numéro au client/joueur
			client.num = indexJoueur
		}
	end

	# Transmet le pseudo à chaque joueur présent dans le salon
	def transmissionPseudo()
		# On constitue une liste des pseudos
		pseudos = []
		@clients.each{ |client|
			if (client != nil)
				pseudos.push(client.pseudo)
			end
		}

    broadcast('waitingWith',pseudos)

  end

  # Send a type of data to each client
  def broadcast(type, data, delay=nil)

    @clients.each{ |client|
      if (client != nil)
        client.com.send(type, data, delay)
      end
    }
  end

end
