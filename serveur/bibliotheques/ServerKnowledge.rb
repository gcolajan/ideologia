require 'singleton'

class ServerKnowledge
  include Singleton

  attr_reader :listeSalons

  def initialize
    @nbPlayers = 4
    @nbClientConnected = 0
    @listeSalons = ListeSalon.new
    @authorizedTypes = %w(pong pseudo join des operation deco rejouer phaseack)
  end

  # Méthode activée lors de la réception d'une communication signalant que le joueur quitte le salon
  def unjoin_method(client, params)
    $LOGGER.info 'Executed unjoined method !'
    client.quitSalon
  end

  def howManyClient?
    @nbClientConnected
  end

  def howManySalon?
    @listeSalons.count
  end

  # Factory method to create the client agregate
  def createClient(ws)
    client = Client.new(@listeSalons)
    communication = Communication.new(ws, client, @authorizedTypes)
    communication.addAsync('unjoin', method(:unjoin_method))
    client.com = communication

    @nbClientConnected += 1
    $LOGGER.info ">>> #{@nbClientConnected} clients"

    client
  end

  def createBotClient(indexSalon, numClient)
    client = Client.new(@listeSalons)
    client.com = MockCommunication.new("Bot ##{numClient}", indexSalon)

    @nbClientConnected += 1
    $LOGGER.info ">>> #{@nbClientConnected} clients"

    client
  end

  def destroyClient(client, code=nil)
    @nbClientConnected -= 1
    $LOGGER.info "<<< #{@nbClientConnected} clients"

    # Si le client est encore dans un salon on le déconnecte
    unless client.salon.nil?
      client.salon.deconnexionJoueur(client, code)
    end

    client.stopThread
    client.stopPing
  end

  def voluntaryDeconnection(client)
    destroyClient(client)
    $LOGGER.info "Voluntary deconnection proceed"
  end

  def askingDemo(client)
    if client.salon.isDemo?
      $LOGGER.info "Demo has already been activated on this salon"
      return
    end
    
    client.salon.demo = true
    indexSalon = @listeSalons.indexOf(client.salon)

    currentlyInSalon = client.salon.nbJoueur

    # On rempli le salon
    (@nbPlayers - currentlyInSalon).times{ |i|
      newClient = createBotClient(indexSalon, i)
      newClient.init
    }

    $LOGGER.info "Demo mode has been set on salon ##{indexSalon}"
  end
end