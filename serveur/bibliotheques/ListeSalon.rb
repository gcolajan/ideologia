class ListeSalon

	def initialize
		@mutex = Mutex.new

		@listeSalon = []

		2.times {
			@listeSalon << Salon.new
		}
	end

	def selection(client)
		begin
			client.com.send("salons", getListToCommunicate)
			indexSalon = client.com.receive('join')

			# Si le salon n'existe pas, une exception est levé
			# Client se débrouille pour notifier le salon de sa venue
			client.salon = salonAt(indexSalon)

			if client.salon.full?
				@listeSalon << Salon.new
			end
		rescue => e
			puts e # Salon does not exist
			retry
		end

		client.com.send('joined')
		puts 'Confirmation "join" envoyee'
	end

	def getNonEmptySalon
		return (@listeSalon.select { |salon| not salon.full?})
	end

	def getListToCommunicate
		liste = Hash.new

		@listeSalon.each_index { |id|
			if (not @listeSalon[id].full?)
				liste[id] = @listeSalon[id].nbJoueur
			end
		}

		return liste
	end

	def salonAt(index)
		salon = @listeSalon[index]

		raise StandardError, "Salon does not exist" if salon.nil?

		return salon
	end

	def couldBeJoined(index)
		return (not @listeSalon[index].full?)
	end

	# Doit être exécuté par partie pour s'assurer qu'il ne soit pas appelé plusieurs fois
	def unsetSalon(salon)
		@listeSalon.delete(salon)
	end
end
