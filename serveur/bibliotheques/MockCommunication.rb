# We unplung (yes, dirty...) the ping, phases and the messages
# and we rewrite the ask method to have proper response.
class MockCommunication < Communication

  def initialize(pseudo, salonId)
    @pseudo = pseudo
    @salonId = salonId
  end

  def startPing
    return
  end

  def stopPing
    return
  end

  def incomingMessage(msg)
    return
  end

  def send(type, data='', delay=nil)
    return
  end

  def emitPhase(name)
    return
  end

  def receive(type, timeout=nil)
    return ask(type, '', 'nothing')
  end

  # We define the minimal communication, we add some "sleep" to let the player see a little what's going on
  def ask(type, data='', expected, delay)
    sleep(0.5)
    case type
      when 'pseudo' then return @pseudo
      when 'join' then return @salonId
      when 'operations' then
        sleep(1.0)
        return 0
      when 'des' then return ''
    end
  end
end