#! /bin/sh


echo "Starting bots"

cd "test"
for i in `seq 0 2`; do
	echo "Bot #$i"
	(./client_auto.rb > "../log/bot$i.log")&
	sleep 5
done
cd ..

echo "Press to kill."
read k

killall "client_auto.rb"

