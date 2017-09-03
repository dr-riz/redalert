#!/bin/bash

set -x

WORKDIR=/home/rmian/support

RUNID=$(date +"%Y%m%d%H%M%S")
echo "$RUNID: poll for real alerts"

TOUCH_FILE=$WORKDIR/last_check
lastTouchpoint=$(date +%s -r $TOUCH_FILE)

DBHOST=server37.hostwhitelabel.com
USER=readuser

#alerts file
ALERT_FL=realalerts.txt
HISTORY_CSV=history.txt

mysql -h $DBHOST -u $USER -sN -e "select app_name,count(0) as num_alerts from support.realalerts where UNIX_TIMESTAMP(last_modified_time) > $lastTouchpoint" > $WORKDIR/$ALERT_FL

anyAlerts=$(head -1 $WORKDIR/$ALERT_FL | grep -c NULL)
touch $TOUCH_FILE

if [ $anyAlerts -gt 0 ] ; then
	echo "${RUNID},0" >> ${WORKDIR}/${HISTORY_CSV}
else 
	numOfAlertType=$(wc -l $WORKDIR/$ALERT_FL | tr -s ' ' | cut -d ' ' -f 1)

	FIXIT=$(cat $WORKDIR/$ALERT_FL)
	OUTPUT=$(echo "${RUNID},${numOfAlertType}" >> ${WORKDIR}/${HISTORY_CSV})
	HISTORY=$(tail -7 ${WORKDIR}/${HISTORY_CSV})

	MAILING_LIST="dr.rizz@budgetnow.ca"
	SENDER="support@budgetnow.ca"
	SUBJECT="Alerts needing attention in $numOfAlertType applications "
	BODY="RUNID=${RUNID}\n"
	BODY=$BODY"workdir=${HOSTNAME}:${WORKDIR}\n\n"
	BODY=$BODY"Address the following alerts (also attached as tab separated $ALERT_FL)\n"
	BODY=$BODY"$FIXIT\n\n"
	BODY=$BODY"history.csv from last 7 checks ${HISTORY_CSV}:\nRUNID,alertTypes(#)\n"
	BODY=$BODY"${HISTORY}"
	echo -e "$BODY" | mailx -r "$SENDER" -a $WORKDIR/$ALERT_FL -a $WORKDIR/$HISTORY_CSV -s "$SUBJECT" "$MAILING_LIST"
	exit 0
fi

