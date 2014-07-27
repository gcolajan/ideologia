#! /usr/bin/ruby
# encoding: UTF-8

require './conf.rb'

#Thread.abort_on_exception = false

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

sem = Mutex.new

semSalon = Mutex.new

listeSalons = ListeSalon.new

nbClients = 0

# Types de communication entrantes autorisées
authorizedTypes = %w(pong pseudo join des operation deco)

# Méthode activé lors de la réception d'une communication signalant que le joueur quitte le salon
def unjoin_method(client, params)
	puts 'Executed unjoined method !'
	client.quitSalon
end

#Types de communication entrantes spéciales utilisant une méthode lors de leur réception
specialTypes = {
	'unjoin' => method(:unjoin_method)
}

EventMachine.run {
	puts('Server is running at %d' % port)


	EventMachine::WebSocket.start(:host => adresseServeur, :port => port, :debug => false) do |ws| # ecoute des connexions

		client = nil
		communication = nil
		
		condVarAttenteDebut = nil

		salon = nil

		# Thread principal permettant de jouer
		mainThread = Thread.new do
			Thread.stop

			# Recuperation du pseudo
			client.pseudo = client.com.receive('pseudo')

			puts "#{client.pseudo} vient de se connecter"

			numJoueur = -1

			salonSelected = nil
			begin
				# On fait choisir un salon 
				puts client.pseudo+" est entrain de choisir un salon"
				listeSalons.selection(client)

				# Test si la partie n'est pas commencée afin d'endormir le client si besoin
				if client.salon.full?
					# On réveille les amis
					puts "WAKE UP!"
					client.salon.wakeup()
				else
					puts "#{client.pseudo} (#{client.num}) commence à attendre"
					client.wait()
					puts "#{client.pseudo} est réveillé"
				end

				# Au réveil, je vérifie que le client ne m'a pas réveillé pour changer de salon
			end while (client.salon.nil?)

			# On initialise tout un tas de variables pour pouvoir démarrer la partie
			joueur = client.salon.partie.recupererInstanceJoueur(client.num)

			joueur.definirPseudo(client.pseudo)
			# À reprendre pour transmettre client et pas les éléments séparément
			gestionJoueur = GestionJoueur.new(communication,client.salon.partie,joueur,client.salon)

			# Le joueur de la partie connait l'instance le gérant
			joueur.obtenirInstanceGestionJoueur(gestionJoueur)



			puts 'Debut partie'

			# Préparation du client pour le début de partie

			puts 'preparationClient'
			gestionJoueur.preparationClient

			# Gestion du joueur durant toute la partie
			puts 'Debut tour'
			gestionJoueur.tourJoueur
		
			# Envoi des scores finaux au client
			puts 'envoi score'
			communication.send('score', partie.obtenirScores)

			# On ferme la ws
			ws.close
		end


		# Réaction du serveur lors de l'ouverture d'une connexion websocket
		ws.onopen{
			client = Client.new
			communication = Communication.new(ws, client)
			communication.setAuthorizedTypes(authorizedTypes)
			communication.setSpecialTypes(specialTypes)

			# On commence le ping du joueur
			communication.startPing

			client.com = communication

			nbClients += 1
			puts 'connexion acceptee'
			puts ">>> Clients = #{nbClients}"

			mainThread.run
		}

		# Réaction du serveur sur fermeture de la websocket
		ws.onclose {
			nbClients -= 1
			puts 'Connection closed'
			puts "<<< Clients = #{nbClients}"

			puts ws.to_s
			# Si le client est encore dans un salon on le déconnecte
			if client.salon
				client.salon.deconnexionJoueur(ws)
			end

			# On tue son thread
			mainThread.kill
		}

		# Réaction du serveur sur réception d'un message de la websocket
		ws.onmessage { |msg|
			test = JSON.parse(msg)
			# Si on a un message de deco on réveille le joueur et on le déconnecte du salon
			if test['type']  == 'deco'
				condVarAttenteDebut.signal
				client.salon.deconnexionJoueur(ws)
			end

			# On traite le message
			communication.filterReception(msg)
		}

		#Réaction du serveur en cas d'erreur
		ws.onerror { |error|
			puts "websockets error: #{error}"
		}
		
	end
}
