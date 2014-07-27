class Emission

	# @ws

	def initialize(ws)
		@ws = ws
	end

	def send(type, data, delay)
		if type != 'ping'
			puts "SENDED #{type}"
		end

		response = {'type' => type}
		if not data.empty?
			response['data'] = data
		end
		if delay > 0.0
			response['delay'] = delay
		end

		@ws.send JSON.generate(response)
	end
end
