class Reception

	# @autorisedTypes

	def initialize()
		@autorisedTypes = {}
	end

	# Add a new type if it isn't already referenced
	def addType(type)
		addYieldType(type)
	end

	def addYieldType(type, block=nil)
		if @autorisedTypes.has_key?(type)
			return false
		end

		@autorisedTypes[type] = {
			'mutex'    => Mutex.new,
			'resource' => ConditionVariable.new,
			'block'    => block}
		return true
	end

	def hasType(type)
		return @autorisedTypes.has_key?(type)
	end

	# Method to connect to the onmessage event
	def signal(type)
		# Default way
		if (@autorisedTypes[type]["block"] == nil)
			@autorisedTypes[type]["mutex"].synchronize {
				@autorisedTypes[type]['resource'].signal
			}
		else # We want to execute a block
			yield(@autorisedTypes[type]["block"])
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
