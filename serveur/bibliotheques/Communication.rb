class Communication

	# @ws
	# @emission
	# @reception
	# @data

	# @pingThread

	def initialize(ws, client)
		@ws        = ws
		@client    = client
		@emission  = Emission.new(ws)
		@reception = Reception.new(client)
		@data      = {}

		@pingThread	  = nil
	end

	def setAuthorizedTypes(types)
		types.each do |type|
			@reception.addType(type)
		end
	end

	def setSpecialTypes(types)
		types.each do |type, block|
			@reception.addCallbackType(type, block)
		end
	end

	def send(type, data='', delay=0)
		@emission.send(type,data,delay)
	end

	def filterReception(msg)
		recept = JSON.parse(msg)

		if not @reception.hasType(recept['type'])
			puts "Reception unauthorized: #{msg}"
			return
		end	

		@reception.signal(recept['type'])
		@data[recept['type']] = recept.has_key?('data') ? recept['data'] : nil
	end

	def addCallbackParams(type, params)
		@reception.tellParams(type, params)
	end

	def receive(type, timeout=nil)
		if not @reception.hasType(type)
			puts "Reception type unknown!"
		end	

		@reception.wait(type, timeout)
		return @data[type]
	end

	def close
		@pingThread.kill()
		@ws.close()
	end

	def startPing
		# Gestion du ping
		@pingThread = Thread.new do
			while true
				send 'ping'
				puts "<!>"
				pingLaunch = Time.now.to_f;
				# We are waiting for a response from the client
				receive('pong', $REPONSE_PING)
				# If the response was too long (or not exists)
				if (Time.now.to_f - pingLaunch >= $REPONSE_PING)
					puts "Disconnected by timeout"
					close()
					break
				end

				# We wait a little before re-ask
				sleep($INTERVALLE_PING_SALON)
			end
		end
	end

end
