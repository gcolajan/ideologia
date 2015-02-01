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
    ws = EventMachine::Client.connect(:host => adresseServeur, :port => port)

    # Réaction du client lors de l'ouverture d'une connexion websocket
    ws.onopen do
      puts("Client connected")
    end

    # Réaction du client sur fermeture de la websocket
    ws.onclose do
      puts("fin de partie")
    end

    # Réaction du client sur réception d'un message de la websocket
    ws.onmessage do |msg|
      test = JSON.parse(msg)
      # Si on a un message de deco on réveille le joueur et on le déconnecte du salon
      puts("type : #{test['type']}, data : #{test['data']}")
      response = {type => test['type']}
      if test['type']  == 'operation'
        response['data'] = test['data'].first()
        ws.send(JSON.generate(response))
      elsif test['type'] == 'pseudo'
        response['data'] = Process.pid
        ws.send(JSON.generate(response))
      elsif test['type'] == 'ping'
        response['type'] = 'pong'
        response['data'] = 'pong'
        ws.send(JSON.generate(response))
      end
    end

    #Réaction du client en cas d'erreur
    ws.onerror { |error|
      puts "websockets error: #{error}"
      puts error.backtrace
    }
}
