require "../../serveur/conf.rb"

class Communication

	def initialize(ws, client, initTypes=[])
		@ws         = ws
		@client     = client
		@data       = {}
    @pingThread = nil

    # Reception stuff
    @sync = {} # Classical type, for linear exchanges
    @async = {} # For asynchronous exchanges (with callback method : msgType => [block, args])

    initTypes.each { |type|
      addSync(type)
    }
  end


  # Closing the communication channel with that client
  def close(code=nil)
    @ws.close(code=code)
  end


  # @param [string] type
  # @param [string] data
  # @param [float] delay    Only accurate if we want to transmit a delay to inform the user
  def send(type, data='', delay=nil)

    response = {'type' => type}

    if (not data.nil?) && (not data.empty?)
      response['data'] = data
    end

    unless delay.nil?
      response['delay'] = delay
    end

    @ws.send JSON.generate(response)
  end


  # Called when we want to wait a specific response from the client (can only be a classic type: no callback)
  # @param [string] type      must be specified in @authorizedTypes
  # @param [seconds] timeout  nil/unspecified is unconditional wait
  def receive(type, timeout=nil)
    unless @sync.has_key?(type)
       $LOGGER.error "Communication::receive: You are expecting for \"#{type}\" but isn't an authorized classic type."
      return nil
    end

    # TODO add a boolean to inform if the information is arrived in time

    locks = @sync[type]

    locks['mutex'].synchronize {
      locks['resource'].wait(locks['mutex'], timeout)
    }

    # Return the last written information on that kind of data
    # TODO: Should be protected by mutex (check for the right value)
    return @data[type]
  end


  # @param [string] type      The type of data you send
  # @param [string] data      The data you send
  # @param [string] expected  The kind of data you expect to receive
  # @param [float] delay      How many secs we are ready to wait before failing (asking with delay at nil may be dangerous)
  # @return [Object]          The last known (careful!) information with [expected] type
  def ask(type, data='', expected, delay)
    send(type, data, delay)
    return receive(expected, delay)
  end


  # Send the special order to change the phase on client
  # It waits forever
  # @param [string] name    Name of the phase
  def emitPhase(name)
    ack = ask('phase', name, 'phaseack', nil)
    if ack != name
      $LOGGER.error "Communication::emitPhase: Wrong ACK on phase (expected: #{name}, received: #{ack})."
    end
  end


  def hasReceptionType?(type)
    return @sync.has_key?(type) || @async.has_key?(type)
  end


  # Add a new authorized reception message if it isn't already referenced
  # @param [string] type
  # @return [boolean]
  def addSync(type)
    if hasReceptionType?(type)
      $LOGGER.error "Communication::addAuthorizedType: #{type} is already defined."
      return false
    end

    @sync[type] = {
        'mutex'    => Mutex.new,
        'resource' => ConditionVariable.new
    }

    return true
  end

  def addAsync(type, block, args=nil)
    if hasReceptionType?(type)
      $LOGGER.error "Communication::addCallbackType: #{type} is already defined."
      return false
    end

    @async[type] = [block, args]
    return true
  end


  def setAsyncArgs(type, args)
    if not @async.has_key?(type)
      $LOGGER.error "Communication::setAuthorizedTypesArgs: cannot add args on undefined callback type \"#{type}\"."
    else
      @async[type][1] = args
    end
  end

  # Process each time server receive a communication (!= "deco")
  # @param [string] msg   JSON message provided by the client
  # @return [nil]
  def incomingMessage(msg)
    # At first, we parse the received message
    reception = JSON.parse(msg)
    type = reception['type']
    data = reception['data']

    # If the operation is unknown, we refuse it
    if not hasReceptionType?(type)
      $LOGGER.error "Reception unauthorized: #{msg}"
      return
    end

    # In case of a classical communication we wakeup ours locks
    if (@sync.has_key?(type))
      # In case of
      if (not data.nil?) && type != 'pong'
        @data[type] = data
      end

      @sync[type]['mutex'].synchronize {
        @sync[type]['resource'].broadcast
      }
    # Otherwise, we already know that the reception is authorized
    # We can execute the callback method provided before
    else # We want to execute a block
      block = @async[type][0]
      params = @async[type][1]

      block.call(@client, params)
    end
  end
end
