#! /usr/bin/ruby
# encoding: UTF-8

require './conf.rb'

#Thread.abort_on_exception = false

if ARGV.size != 2 and ARGV.size != 0 
	$stderr.puts("Usage: ./serveur.rb ACCEPTED_DOMAIN PORT")
	exit(1)
end

adresseServeur = ""
port = -1

if(ARGV.size == 0)
	adresseServeur = "0.0.0.0"
	port = 8080
elsif(ARGV.size == 2)
	adresseServeur  = ARGV[0]
	port = ARGV[1].to_i
end

sem = Mutex.new

semSalon = Mutex.new

listeSalons = [Salon.new, Salon.new]

EventMachine.run {
	puts("Server is running at %d" % port)


	EventMachine::WebSocket.start(:host => adresseServeur, :port => port, :debug => true) do |ws| # ecoute des connexions
		mutexPseudo = Mutex.new
		condVarPseudo = ConditionVariable.new

		pongMutex = Mutex.new
		pongResponse = ConditionVariable.new

		mutexDes = Mutex.new
		condVarDes = ConditionVariable.new

		mutexOpe = Mutex.new
		condVarOpe = ConditionVariable.new

		mutexJoin = Mutex.new
		condVarJoin = ConditionVariable.new

		mutexDeco = Mutex.new
		condVarDeco = ConditionVariable.new

		transmission = ""


		listeMessage = []


		connexionMutex = Mutex.new
		connectionOpened = ConditionVariable.new

		# Gestion du ping
		pingThread = Thread.new do
			# We start when the connexion is opened
			connexionMutex.synchronize{
				connectionOpened.wait(connexionMutex)
			}

			while true
				ws.send '{"type":"ping","data":"1"}'
				puts "ping sended"
				pingLaunch = Time.now.to_f;
				# We are waiting for a response from the client
				pongMutex.synchronize {
					pongResponse.wait(pongMutex, $REPONSE_PING)
				}
				# If the response was too long (or not exists)
				if (Time.now.to_f - pingLaunch >= $REPONSE_PING)
					puts "Disconnected by timeout"
					break

				# We wait a little before re-ask
				sleep($INTERVALLE_PING_SALON)
			end
		end

	
		mainThread = Thread.new do
			# We start when the connexion is opened
			connexionMutex.synchronize{
				connectionOpened.wait(connexionMutex)
			}

			# Recuperation du pseudo
			mutexPseudo.synchronize{
				condVarPseudo.wait(mutexPseudo)
			}

			# We show the last message extracted
			puts listeMessage.pop()
		end

		

		ws.onopen{
			puts "connexion acceptee"

			# We wake up all the thread waiting for opening
			connexionMutex.synchronize{
				connectionOpened.broadcast
			}
		}

		ws.onclose {
			puts "Connection closed"
		}

		ws.onmessage { |msg|
			transmission = JSON.parse(msg)

			case transmission["type"]
				when "pseudo"
					condVarPseudo.signal
				when "pong"
					pongResponse.signal
				when "des"
					mutexDes.synchronize{
						condVarDes.signal
					}
				when "operation"
					mutexOpe.synchronize{
						condVarOpe.signal
					}
				when "join"
					mutexJoin.synchronize{
						condVarJoin.signal
					}
				when "deco"
					mutexDeco.synchronize{
						condVarDeco
					}
			end
		}

		ws.onerror { |error|
			puts "websockets error: #{error}"
		}
		
	end
}
