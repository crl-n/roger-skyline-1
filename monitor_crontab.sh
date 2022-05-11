#!/bin/sh
CRONTAB=/var/spool/cron/crontabs/root
BACKUP=/var/spool/cron/crontabs/backup
MESSAGE="There has been a change to the crontab."

echo 'Looking for changes in crontab...'

if [ ! -e $BACKUP ]; then
	echo 'No previous backup found, creating backup...'
	cp $CRONTAB $BACKUP
	echo 'Exiting...'
	exit 0
fi

DIFF=$(diff $CRONTAB $BACKUP)

echo 'Checking diff...'

if [ "$DIFF" != "" ]; then
	echo MESSAGE | mail -s 'Crontab change' root@debian.lan
fi

cp $CRONTAB $BACKUP
