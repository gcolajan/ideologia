class Reception

	@autorisedTypes

	def initialize()
		@autorisedTypes = {}
	end

	# Add a new type if it isn't already referenced
	def addType(type)
		if @autorisedTypes.has_key?(type)
			return false
		end

		@autorisedTypes[type] = {
			'mutex' => Mutex.new,
			'resource' => ConditionVariable.new}
		return true
	end

	def hasType(type)
		return @autorisedTypes.has_key?(type)
	end

	# Method to connect to the onmessage event
	def signal(type)
		@autorisedTypes[type]["mutex"].synchronize {
			@autorisedTypes[type]['resource'].signal
		}
	end

	# To use when we want to wait for a response from the client
	def wait(type, timeout)
		@autorisedTypes[type]['mutex'].synchronize {
			@autorisedTypes[type]['resource'].wait(
				@autorisedTypes[type]['mutex'],
				timeout)
		}
	end

	def unlock(type)
		@autorisedTypes[type]["mutex"].synchronize {
			@autorisedTypes[type]['resource'].signal
		}
	end
end
