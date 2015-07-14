# encoding: UTF-8

class Client

	attr_accessor :com
	attr_accessor :num
	attr_accessor :pseudo
	attr_accessor :salon

	def initialize(listeSalons)
		@listeSalons = listeSalons
		@mainThread = nil
		@com = nil
		@num = nil
		@pseudo = nil
		@salon = nil
		@verroux = {
			'mutex' => Mutex.new,
			'resource' => ConditionVariable.new
		}
	end

	def quitSalon
		unless @salon.nil?
			# Je notifie le salon que je m'en vais
			@salon.deconnexionJoueur(self)

			# Je me dé-référence
			@salon = nil

			# Je libère le verroux lié à mon attente de début de partie
			signal()
		end
	end

	def signal
		@verroux['mutex'].synchronize {
			@verroux['resource'].signal
		}
	end

	def wait
		@verroux['mutex'].synchronize {
			@verroux['resource'].wait(@verroux['mutex'])
		}
	end

	def stopThread
		@mainThread.kill
	end


	# Thread principal permettant de jouer
	def launchThread
		@mainThread = Thread.new do

      @com.emitPhase('introduction')

			# Recuperation du pseudo
			@pseudo = @com.receive('pseudo')

			puts "#{@pseudo} vient de se connecter"

			begin
        @com.emitPhase('salons')

				# On fait choisir un salon 
				puts "#{@pseudo} est entrain de choisir un salon"
				@salon = @listeSalons.selection(self)

        # Test si la partie n'est pas commencée afin d'endormir le client si besoin
				if @salon.full?
					# On réveille les amis
					puts "WAKE UP!"
					@salon.wakeup()
				else
					puts "#{@pseudo} (#{@num}) commence à attendre"
					wait()
					puts "#{@pseudo} est réveillé"
				end

				# Au réveil, je vérifie que le client ne m'a pas réveillé pour changer de salon
			end while (@salon.nil?)

			# On initialise tout un tas de variables pour pouvoir démarrer la partie
			joueur = @salon.partie.recupererInstanceJoueur(self.num)

			joueur.definirPseudo(@pseudo)
			# À reprendre pour transmettre client et pas les éléments séparément
			gestionJoueur = GestionJoueur.new(joueur, @com, @salon)

			# Le joueur de la partie connait l'instance le gérant
			joueur.obtenirInstanceGestionJoueur(gestionJoueur)



			puts 'Debut partie'
			@com.emitPhase('jeu')

			# Préparation du client pour le début de partie

      # On envoie une synthèse des personnes participant et les idéologies associées
			puts 'Recuperation des partenaires'
      @com.send('partenaires', @salon.partie.obtenirTableauPartenaires)

			# Gestion du joueur durant toute la partie
			puts 'Debut tour'
      while @salon.partie.estDemarree
			  gestionJoueur.newTurn
      end
		
			# Envoi des scores finaux au client
			puts 'envoi score'
			@com.send('score', @salon.partie.obtenirScores)

			# On ferme la ws
			@com.close(code=4000)
		end
	end

end
