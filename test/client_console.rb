# Copyright: Hiroshi Ichikawa <http://gimite.net/en/>
# Lincense: New BSD Lincense

$LOAD_PATH << File.dirname(__FILE__)
require "web_socket"
require 'json'

if ARGV.size != 1
  $stderr.puts("Usage: ruby samples/stdio_client.rb ws://HOST:PORT/")
  exit(1)
end

def tojson(transmission, contenu, delaiReponse=-1)
  return JSON.generate({"transmission" => transmission, "data" => contenu, "delai" => delaiReponse})
end

client = WebSocket.new(ARGV[0])
puts("Connected")
client.send(tojson("pseudo", "moi"))
Thread.new() do
  while data = client.receive()
  	if data == "ping"
  		client.send(tojson("pong",""))
  	end
    printf("Received: %p\n", data)
  end
  #exit()
end
$stdin.each_line() do |line|
  data = line.chomp()
  client.send(tojson("test", data))
  printf("Sent: %p\n", data)
end
client.close()
