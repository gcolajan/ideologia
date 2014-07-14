class Transmission

	# @ws

	def initialize(ws)
		@ws = ws
	end

	def send(type, data, delay)
		puts "SENDED #{type}"
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
