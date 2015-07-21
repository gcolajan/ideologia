#! /usr/bin/ruby
# encoding: UTF-8

require './conf.rb'

Thread.abort_on_exception = true

if ARGV.size != 2 and ARGV.size != 0 
	$stderr.puts('Usage:ruby ./serveur.rb ACCEPTED_DOMAIN PORT')
	exit(1)
end

adresseServeur = ''
port = -1

if ARGV.size == 0
	adresseServeur = '0.0.0.0'
	port = 8080
elsif ARGV.size == 2
	adresseServeur  = ARGV[0]
	port = ARGV[1].to_i
end

listeSalons = ListeSalon.new

nbClients = 0

# Types de communication entrantes autorisées
authorizedTypes = %w(pong phaseack pseudo join des operation deco)


# Méthode activé lors de la réception d'une communication signalant que le joueur quitte le salon
def unjoin_method(client, params)
	$LOGGER.info 'Executed unjoined method !'
	client.quitSalon
end

EventMachine.run {
	puts('Server is running at %d' % port)


	EventMachine::WebSocket.start(:host => adresseServeur, :port => port, :debug => false) do |ws| # ecoute des connexions

		client = nil
		communication = nil
    ping = nil

		condVarAttenteDebut = nil

		# Réaction du serveur lors de l'ouverture d'une connexion websocket
		ws.onopen{
			client = Client.new(listeSalons)
			communication = Communication.new(ws, client, authorizedTypes)
      communication.addAsync('unjoin', method(:unjoin_method))

      client.com = communication
      client.launchThread

			nbClients += 1
      $LOGGER.info ">>> #{nbClients} client(s)"

      # On commence le ping du joueur
      ping = EventMachine.add_periodic_timer( $INTERVALLE_PING_SALON ) { ws.ping }
    }

		# Réaction du serveur sur fermeture de la websocket
		ws.onclose { |params|
      $LOGGER.debug params

			nbClients -= 1
      $LOGGER.info "<<< #{nbClients} client(s)"

			puts ws.to_s
			# Si le client est encore dans un salon on le déconnecte
			unless client.salon.nil?
				client.salon.deconnexionJoueur(client, code=params[:code])
			end

			# On tue ses threads
			client.stopThread
      ping.cancel
		}

		# Réaction du serveur sur réception d'un message de la websocket
		ws.onmessage { |msg|
			test = JSON.parse(msg)
			# Si on a un message de deco on réveille le joueur et on le déconnecte du salon
			if test['type']  == 'deco'
				condVarAttenteDebut.signal
				client.salon.deconnexionJoueur(client)
      else
        # On traite le message
        communication.incomingMessage(msg)
      end
		}

		#Réaction du serveur en cas d'erreur
		ws.onerror { |error|
      $LOGGER.error "websockets error: #{error}"
      $LOGGER.info error.backtrace
		}
	end
}
