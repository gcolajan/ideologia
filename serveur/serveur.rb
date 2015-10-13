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


EventMachine.run {
	puts('Server is running at %d' % port)

	EventMachine::WebSocket.start(:host => adresseServeur, :port => port, :debug => false) do |ws| # ecoute des connexions

		client = nil

		# Réaction du serveur lors de l'ouverture d'une connexion websocket
		ws.onopen{
      client = ServerKnowledge.instance.createClient(ws)
      client.init
    }

		# Réaction du serveur sur fermeture de la websocket
		ws.onclose { |params|
      $LOGGER.debug params

      ServerKnowledge.instance.destroyClient(client, code=params[:code])
      $LOGGER.info ws.to_s
		}

		# Réaction du serveur sur réception d'un message de la websocket
		ws.onmessage { |msg|
      client.com.incomingMessage(msg)
		}

		#Réaction du serveur en cas d'erreur
		ws.onerror { |error|
      $LOGGER.error "websockets error: #{error}"
      $LOGGER.error error.backtrace
		}
	end
}
