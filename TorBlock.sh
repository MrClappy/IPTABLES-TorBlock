
#!/bin/bash

# Blocking Tor Exit nodes on Windows-Apache or Linux Servers
# Ryan MacNeille (2012)

echo -ne "\n"
read -p "Installing for a remote Windows Web Server? (y/n)" yn
case $yn in
	[Yy]* )

# REMOTE WINDOWS SERVER CONFIGURATION

# SET YOUR WINDOWS SERVER FTP VARIABLES HERE
FTP_HOST=MySite.com
FTP_USER=John.Doe
FTP_PASS=Password1234

# REPLACE THIS STRING WITH YOUR STATIC IP IF APPLICABLE
IP_ADDRESS=123.123.123.123
 
# Generate Updated Tor-Node List
echo -ne "\n"
echo --- Retrieving updated Tor node list from TorProject.org

wget -q -O - "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$IP_ADDRESS&port=80" -U NoSuchBrowser/1.0 > /tmp/full.tor
tail -n +4 /tmp/full.tor > /tmp/tor.list

echo -ne "\n"
echo "--- Preparing list for .htaccess"

sed -i -e 's/^/Deny from /' /tmp/tor.list > /dev/null 2>&1
sed -i 1i"Order Allow,Deny" /tmp/tor.list > /dev/null 2>&1
echo -e "\r\nAllow from all" >> /tmp/tor.list > /dev/null 2>&1
sed -i 's|^#.*$||g' /tmp/tor.list > /dev/null 2>&1
echo -e "\r\n" | cat - /tmp/tor.list > /dev/null 2>&1

# Retrieve Updated Apache Access Log From Web Server & Send the Tor List
echo -ne "\n"
echo --- "Sending information to the Windows Server FTP"
echo -ne "\n"

ftp -inv $FTP_HOST << EOF
user $FTP_USER $FTP_PASS
put /tmp/tor.list Tor_List.txt
bye > /dev/null 2>&1 
EOF

echo -ne "\n"
echo --- "Configuration is complete, be sure to configure your Windows Server to complete the Installation Process"
echo -ne "\n";; [Nn]* )

# LINUX APACHE WEB SERVER CONFIGURATION IPTABLES_TARGET="DROP"
IPTABLES_CHAINNAME="TOR" IP_ADDRESS=123.123.123.123 WORKING_DIR="/tmp/”

# If string doesn’t exist, create it.
if ! iptables -L "$IPTABLES_CHAINNAME" -n >/dev/null 2>&1 ; then
	iptables -N "$IPTABLES_CHAINNAME" >/dev/null 2>&1
fi

cd $WORKING_DIR echo -ne "\n"

echo --- Retrieving updated Tor node list from TorProject.org echo -ne "\n"

wget -q -O - "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$IP_ADDRESS&port=80" -U NoSuchBrowser/1.0 > /tmp/full.tor
sed -i 's|^#.*$||g' /tmp/full.tor iptables -F "$IPTABLES_CHAINNAME" CMD=$(cat /tmp/full.tor | uniq | sort) 

for IP in $CMD; do
  let COUNT=COUNT+1
  iptables -A "$IPTABLES_CHAINNAME" -s $IP -j $IPTABLES_TARGET 
done

iptables -A "$IPTABLES_CHAINNAME" -j RETURN

echo "--- IP Table rules are now set to block Tor connection attempts" echo -ne "\n"
rm /tmp/full.tor
esac
