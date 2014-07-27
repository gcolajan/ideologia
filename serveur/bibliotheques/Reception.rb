class Reception

	# @autorisedTypes
	# @specialTypes
	# @specialTypesParams

	def initialize(client)
		@client             = client
		@autorisedTypes     = {}
		@specialTypes       = {}
		@specialTypesParams = {}
	end

	# Add a new type if it isn't already referenced
	def addType(type)
		if @autorisedTypes.has_key?(type)
			return false
		end

		@autorisedTypes[type] = {
			'mutex'    => Mutex.new,
			'resource' => ConditionVariable.new}
		return true
	end

	def addCallbackType(type, block)
		if @autorisedTypes.has_key?(type)
			return false
		end

		@specialTypes[type] = block
		return true
	end

	def hasType(type)
		return @autorisedTypes.has_key?(type) || @specialTypes.has_key?(type)
	end

	def tellParams(type, params)
		@specialTypesParams[type] = params
	end

	# Method to connect to the onmessage event
	def signal(type)
		# Default way
		if (@autorisedTypes.has_key?(type))
			@autorisedTypes[type]["mutex"].synchronize {
				@autorisedTypes[type]['resource'].broadcast
			}
		else # We want to execute a block
			params = (@specialTypesParams.has_key?(type) ? @specialTypesParams[type] : nil)
			@specialTypes[type].call(@client, params)
		end
	end

	# To use when we want to wait for a response from the client
	def wait(type, timeout)
		@autorisedTypes[type]['mutex'].synchronize {
			@autorisedTypes[type]['resource'].wait(
				@autorisedTypes[type]['mutex'],
				timeout)
		}
	end
end
