
#!/bin/bash - Strip Access Log & Find Tor IPs
# Ryan MacNeille (2012)

# NOTE: You must modify the "CONFIGURATION LINES" below to set your Access log path and search options
# Windows Servers require FTP Credentials to be set below
#
# -To Show possible successful access – Remove “grep 403”
# -To Omit IP Addresses - grep -v 192.168.1.1
# -To Omit IP Ranges - grep -v 192.168.1.*
# -To Select Time Frames: #
# -Year = Full Year With ":" - grep 2012:
# -Month = Three Letter Abbreviation - grep Mar

echo -ne "\n"
read -p "Track Tor access on a Remote Windows Server? (y/n)" yn 
case $yn in
	[Yy]* ) 

#REMOTE WINDOWS SERVER CONFIGURATION IP_ADDRESS=123.123.123.123
echo -ne "\n"
echo Retrieving updated Tor node list from TorProject.org

wget -q -O - "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$IP_ADDRESS&port=*" -U NoSuchBrowser/1.0 > /tmp/full.tor
tail -n +4 /tmp/full.tor > tor.list

# SET YOUR WINDOWS SERVER FTP VARIABLES HERE FTP_HOST=MyServer.com
FTP_USER=John.Doe
FTP_PASS=password1234

echo -ne "\n"
echo "--- Retrieving Access log from Web Server" ftp -inv $FTP_HOST << EOF

user $FTP_USER $FTP_PASS
get access.log /tmp/access.log
bye > /dev/null 2>&1
EOF

echo -ne "\n"
echo "--- Searching for Tor IP Addresses in the log"
echo –ne “\n”

# EDIT THIS LINE TO CUSTOMIZE OPTIONS FOR WINDOWS - See Header
cat /tmp/access.log | grep 403 > /tmp/tor.log
grep -w -F -f /tmp/tor.list /tmp/tor.log > /tmp/tor_access.log
sed -i 's|^#.*$||g' /tmp/tor_access.log
rm /tmp/access.log /tmp/tor.list
echo -ne "\n"

if [[ -s /tmp/tor_access.log ]] ; then cat /tmp/tor_access.log
	echo -ne "\n"
else
	echo "No connection attempts associated with Tor were found." echo -ne "\n"
fi;;
	[Nn]* ) 

# LINUX APACHE WEB SERVER CONFIGURATION IP_ADDRESS=123.123.123.123
echo -ne "\n"
echo Retrieving updated Tor node list from TorProject.org

wget -q -O - "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$IP_ADDRESS&port=*" -U NoSuchBrowser/1.0 > /tmp/full.tor
tail -n +4 /tmp/full.tor > /tmp/tor.list

echo -ne "\n"
echo "Searching for Tor IP Addresses in the log"

# CONFIGURATION LINES; EDIT THESE LINES TO CUSTOMIZE SEARCH OPTIONS - See Header
ACCESS_LOG=/var/log/apache/httpd/access.log # Path to your access.log file 
cat $ACCESS_LOG | grep 403 > /tmp/tor.log
grep -w -F -f /tmp/tor.list /tmp/tor.log > /tmp/tor_access.log
sed -i 's|^#.*$||g' /tmp/tor_access.log
rm /tmp/tor.list
echo -ne "\n"

if [[ -s /tmp/tor_access.log ]] ; then
	cat /tmp/tor_access.log
	echo -ne "\n" 
else
	echo "No connection attempts associated with Tor were found." echo -ne "\n"
esac
