#!/bin/sh

echo 'Compressing source files...'
tar czf webapp.tar.gz --directory=webapp .
sleep 1

echo 'Copying over SSH...'
scp -P 50000 webapp.tar.gz cnysten@10.11.203.111:/home/cnysten
sleep 2
/bin/rm webapp.tar.gz

echo 'Decompressing on remote...'
ssh -t -p 50000 cnysten@10.11.203.111 "tar xvf /home/cnysten/webapp.tar.gz; rm /home/cnysten/webapp.tar.gz; sudo mv /home/cnysten/index.html /var/www/html/"

echo 'Restarting remote server...'
ssh -t -p 50000 cnysten@10.11.203.111 "sudo systemctl restart apache2"

echo 'Done.'
