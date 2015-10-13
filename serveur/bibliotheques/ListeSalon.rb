class ListeSalon

	def initialize
		@mutex = Mutex.new

		@listeSalon = []

		2.times {
			@listeSalon << Salon.new
		}
	end

	def selection(client)

    salon = nil
    while salon.nil?
      client.com.send("salons", getListToCommunicate)
      idSalon = client.com.receive('join').to_i
      selectedSalon = salonAt(idSalon)

      @mutex.synchronize {
        unless selectedSalon.full?
          client.com.send('joined')
          client.com.emitPhase('attente')
          salon = selectedSalon
          salon.addPlayer(client)
        end
      }
    end

    return salon
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

	def indexOf(salon)
		@listeSalon.index(salon)
	end

	def couldBeJoined(index)
		return (not @listeSalon[index].full?)
	end

	# Doit être exécuté par partie pour s'assurer qu'il ne soit pas appelé plusieurs fois
	def unsetSalon(salon)
		@listeSalon.delete(salon)
	end
end
