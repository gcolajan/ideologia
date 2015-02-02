require 'json'
require 'websocket-eventmachine-client'


Thread.abort_on_exception = true

if ARGV.size != 2 and ARGV.size != 0
  $stderr.puts('Usage:ruby ./client_auto.rb ACCEPTED_DOMAIN PORT')
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
    ws = WebSocket::EventMachine::Client.connect(:host => adresseServeur, :port => port)

    # Réaction du client lors de l'ouverture d'une connexion websocket
    ws.onopen do
      puts("Client connected")
    end

    # Réaction du client sur fermeture de la websocket
    ws.onclose do
      puts("Closed.")
    end

    # Réaction du client sur réception d'un message de la websocket
    ws.onmessage do |msg|

      _msg = JSON.parse(msg)
      type = _msg['type']
      data = _msg['data']

      if type != 'ping'
        puts("#{type} => #{data}")
        sleep(1) # Before doing anything on reception, we wait 1s
      end

      if type == 'ping'
        ws.send JSON.generate({'type' => 'pong'})
      elsif type == 'phase'
        ws.send JSON.generate({'type' => 'phaseack', 'data' => data})

        case data
          when 'introduction'
            ws.send JSON.generate({'type' => 'pseudo', 'data' => 'BOT_'+Process.pid.to_s})
          when 'salons'
            # Nothing here
          when 'attente'
            # Nothing here
          when 'jeu'
            # Nothing here
          else
            puts "Unknow phase: #{data}"
        end
      elsif type == 'salons'
        ws.send JSON.generate({'type' => 'join', 'data' => '1'})
      elsif type == 'operations'
        ws.send JSON.generate({'type' => 'operation', 'data' => data.first()})
      else
        # I don't care
      end
    end


    #Réaction du client en cas d'erreur
    ws.onerror { |error|
      puts "websockets error: #{error}"
      puts error.backtrace
    }
}
