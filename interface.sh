#!/bin/bash
#interface.sh
SCRIPT=$(readlink -f $0)
DIRBASE=$(dirname $SCRIPT)
cd $DIRBASE
echo "$DIRBASE"

# Telegram Interface
VERSION="1.0\nTelegram Bot for Kali Linux by joselin666"

# Enter your token
TOKEN="$(cat $DIRBASE/BOT)"

# Enter your channel id
CHANNEL="$(cat $DIRBASE/CHAT)"

# File where the number of the last processed message will be saved
LASTMSG=$DIRBASE/lastmsg

# Commands
# use this format: ["/ mi command"] = '<comando del sistema>'
# Please remember to remove unnecessary examples
# You can add these commands to the list of telegram commands with the function "/setcommands in BotFather"

echo -e "\nKali Simply Telegram Interface v${VERSION}\n"
ABOUTME=$(curl -s "https://api.telegram.org/bot${TOKEN}/getMe")
if [[ "$ABOUTME" =~ \"ok\"\:true\, ]]; then
	if [[ "$ABOUTME" =~ \"username\"\:\"([^\"]+)\" ]]; then
		echo -e "Bot Nick:\t @${BASH_REMATCH[1]}"
	fi

	if [[ "$ABOUTME" =~ \"first_name\"\:\"([^\"]+)\" ]]; then
		echo -e "Bot Name:\t ${BASH_REMATCH[1]}"
	fi

	if [[ "$ABOUTME" =~ \"id\"\:([0-9\-]+), ]]; then
		echo -e "Bot ID:\t\t ${BASH_REMATCH[1]}"
	fi

else
	echo "Error: The bot for that token was not found."
	exit
fi

if [ -e "$LASTMSG" ]; then
	echo "Last Message Processed:"
	cat $LASTMSG
else
	echo "0" >$LASTMSG
fi

date
echo -e "\nService Started... Waiting for new messages\n"
curl -s -X POST https://api.telegram.org/bot"$TOKEN"/sendMessage -d chat_id="$CHANNEL" -d text="Kali Telegram Interface Started." >>/var/log/telegram.log 2>>/var/log/telegram.log

while true; do
	MSGOUTPUT=$(curl -s "https://api.telegram.org/bot${TOKEN}/getUpdates")
	MSGID=0
	TEXT=0

	echo -e "${MSGOUTPUT}" | while read -r line; do
		if [[ "$line" =~ \"chat\"\:\{\"id\"\:([\-0-9]+)\, ]]; then
			CHATID=${BASH_REMATCH[1]}
		fi

		if [[ "$line" =~ \"message\_id\"\:([0-9]+)\, ]]; then
			MSGID=${BASH_REMATCH[1]}
		fi

		if [[ "$line" =~ \"date\"\:([0-9]+)\, ]]; then
			DATE=${BASH_REMATCH[1]}
		fi

		if [[ "$line" =~ \"text\"\:\"([^\"]+)\" ]]; then
			TEXT=${BASH_REMATCH[1]}
		fi

		# Leo el ultimo msg procesado
		LASTMSGID=$(cat "$LASTMSG")
		ESROBOT=${TEXT:0:1}
		# Calculo la antiguedad del mensaje si viene sin fecha son cabeceras y las desestimo
		DATENOW=$(date "+%s")
		if [[ "$DATE" == "" ]]; then
			ANTIGUEDAD=99
		else
			ANTIGUEDAD=$(expr $DATENOW - $DATE)
		fi
		# Proceso las lineas que tengan mensaje y sea nuevo, tenga numero de chat y coincida con el que estoy procesando y la linea empiece por un comando y con antiguedad inferior a 15 segundos
		if [[ $MSGID -ne 0 && $CHATID -ne 0 && $CHATID = $CHANNEL && $MSGID -gt $LASTMSGID && "$ESROBOT" == "/" && $ANTIGUEDAD -lt 15 ]]; then
			robot=$(echo $TEXT | cut -d' ' -f 1)
			#Si el usuario teclea un comando desconocido saco el menu con las opciones Validas
			CMD="echo -e Bienvenido a Kali Bot\n/uptime \n/disk \n/ping <IP a verificar>\n/run <Comando a ejecutar>\n/reboot \n/apagar \n\n/red \n/router \n\n/log \n/menu"

			#/ping
			if [[ "$robot" == "/ping" ]]; then
				CMD="ping -c3 ${TEXT:6}"
			fi
			#/uptime
			if [[ "$robot" == "/uptime" ]]; then
				CMD="uptime"
			fi
			#/disk
			if [[ "$robot" == "/disk" ]]; then
				CMD="df -h"
			fi
			#/run
			if [[ "$robot" == "/run" ]]; then
				CMD="${TEXT:5}"
			fi
			#/reboot
			if [[ "$robot" == "/reboot" ]]; then
				CMD="sudo reboot"
			fi
			#/apagar
			if [[ "$robot" == "/apagar" ]]; then
				CMD="sudo shutdown -f now"
			fi
			#/red
			if [[ "$robot" == "/red" ]]; then
				CMD="ip a"
			fi
			#/router
			if [[ "$robot" == "/router" ]]; then
				CMD="ping 192.168.1.1 -c3"
			fi
			#/log
			if [[ "$robot" == "/log" ]]; then
				CMD="/opt/telegram/enviarloginterface.sh"
			fi

			#EXECUTION, NOTIFICATION and UPDATE OF LAST PROCESSED MESSAGE
			RESULTADO=$($CMD)
			curl -s -d "text=${RESULTADO}&chat_id=${CHATID}" "https://api.telegram.org/bot${TOKEN}/sendMessage" >/dev/null
			echo $MSGID >"$LASTMSG"
			#Log
			echo " "
			date
			echo "Comando: $CMD"
			echo "Result:"
			echo "$RESULTADO"
		fi
	done
	# Seconds to wait for the next execution
	sleep 5
done

exit 0