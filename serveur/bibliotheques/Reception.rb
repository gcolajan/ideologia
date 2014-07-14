class Reception

	@autorisedTypes
	@transmissions

	def initialize()
		@autorisedTypes = {}
		@transmissions = {}
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

	def signal(type, data)
		if @autorisedTypes.has_key?(type)
			@transmissions[type] = data
			@autorisedTypes[type]["mutex"].synchronize {
				@autorisedTypes[type]['resource'].signal
			}
		else
			puts "Not catched type: #{type}"
		end
	end

	def wait(type, timeout=nil)
		if @autorisedTypes.has_key?(type)
			@autorisedTypes[type]['mutex'].synchronize {
				@autorisedTypes[type]['resource'].wait(
					@autorisedTypes[type]['mutex'],
					timeout)
			}
			return @transmissions[type]
		else
			puts "#{type} doesn't exist!"
			return nil
		end

	end
end
