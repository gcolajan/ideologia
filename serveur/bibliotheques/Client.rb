class Client

	attr_accessor :com
	attr_reader :pseudo
	attr_reader :salon

	def initialize
		@com = nil
		@pseudo = nil
		@salon = nil
		@verroux = {
			'mutex' => Mutex.new,
			'resource' => ConditionVariable.new
		}
	end

	def setCommunication(communication)
		@com = communication
	end

	def setPseudo(pseudo)
		@pseudo = pseudo
	end

	def setSalon(salon)
		if not @salon.nil?
			puts "Client could have change room without notify him!"
		end
		@salon = salon
	end

	def quitSalon
		if not @salon.nil?
			# Je libère le verroux lié à mon attente de début de partie
			signal()

			# Je notifie le salon que je m'en vais
			@salon.deconnexionJoueur(self)

			# Je me déréfence
			@salon = nil
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

end
