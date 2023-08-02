#!/bin/bash
#enviarloginterface.sh
SCRIPT=$(readlink -f $0)
DIRBASE=$(dirname $SCRIPT)
cd $DIRBASE

# Enter your token
TOKEN="$(cat $DIRBASE/BOT)"

# Enter your channel id
CHANNEL="$(cat $DIRBASE/CHAT)"

curl -s -X POST https://api.telegram.org/bot"$TOKEN"/sendDocument -F chat_id="$CHANNEL" -F caption="Log Telegram Bot Interface" -F document="@/var/log/interface.log" >>/var/log/telegram.log 2>>/var/log/telegram.log