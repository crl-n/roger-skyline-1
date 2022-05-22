#!/bin/zsh
scp -P 50000 monitor_crontab.sh cnysten@10.11.203.111:/home/cnysten
sleep 2
ssh -p 50000 cnysten@10.11.203.111 -t "sudo mv /home/cnysten/monitor_crontab.sh /usr/local/bin/; sudo chmod +x /usr/local/bin/monitor_crontab.sh"
