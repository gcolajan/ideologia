class Client

	attr_accessor :com
	attr_accessor :num
	attr_accessor :pseudo
	attr_accessor :salon

	def initialize
		@com = nil
		@num = nil
		@pseudo = nil
		@salon = nil
		@verroux = {
			'mutex' => Mutex.new,
			'resource' => ConditionVariable.new
		}
	end

	def salon=(salon)
		if not @salon.nil?
			puts "Client could have change room without notify him!"
		end

		salon.join(self)

		@salon = salon
	end

	def quitSalon
		unless @salon.nil?
			# Je me déréfence
			@salon = nil

			# Je notifie le salon que je m'en vais
			@salon.deconnexionJoueur(self)

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

end
