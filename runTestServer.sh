#! /bin/sh

cd serveur
(./serveur.rb > "../log/server.log")&
cd ..

sleep 10
echo;echo "Starting bots"

cd "test"
for i in `seq 0 2`; do
	echo "Bot #$i"
	sleep 2
	(./client_auto.rb > "../log/bot$i.log")&
done
cd ..

echo "Press to kill."
read k

killall "client_auto.rb"
killall "serveur.rb"
