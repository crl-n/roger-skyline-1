#!/bin/sh
CRONTAB=/etc/crontab
BACKUP=/etc/crontab.backup
MESSAGE="There has been a change to the crontab."

if test -f "$BACKUP"; then
	exit 0
fi

DIFF=$(diff $CRONTAB $BACKUP)

if [ "$DIFF" != "" ]; then
	echo MESSAGE | mail -s 'Crontab change' root@debian.lan
fi
