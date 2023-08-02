# simplytelegrambot
Telegram Bot for Kali Linux.
Developep 100% Bash and Debian 11.

#Download:
sudo git clone https://github.com/joselin666/TelegramBotForKaliLinux.git /opt/telegram

#Permissions:
sudo chmod -R 700 /opt/telegram

#Your Info:
update BOT and CHAT file with your info

#Add this line in the root crontab:
sudo crontab -e
@reboot /opt/telegram/interface.sh > /var/log/interface.log 2>&1 &