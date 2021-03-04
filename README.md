# TorBlock Scripts

The Tor Project (thetorproject.org) offers a Python script to view a list of IP addresses on the Tor network. Unfortunately, the list changes very frequently for security purposes. The following scripts automate the pulling and blocking of Tor exit node IPs for Windows Apache .htaccess and Linux IPTABLES.

## TorBlock
Updates the IP list and blocks IPs.

1. Configuring IPTABLES on a local Linux server:
  a. Updates the list of Tor nodes and explicitly denies access using Linux IPTABLES commands. Tor list updates with Cron, at a frequency of the user’s choice.
2. Configuring a remote Windows Apache Server’s .htaccess file:
  a. Updates the list of Tor nodes from a Linux machine and modifies the syntax for the Apache .htaccess file
  b. Uses FTP to transfer the list to the Windows web server where an additional script will be run

## TorTrack
TorTrack is an additional Bash script for tracking access attempts from Tor exit nodes. The script updates the Tor list and parses through the web server’s access log to show when and how often a Tor node attempted access. This can also be run for the remote Windows machine using FTP to transfer the access log.

TorTrack has additional uses, including a documented process for tracking Tor requests from any log or error page. Users can customize the access log filter as they desire. These configuration lines are specified in the script comments.

- To list possible successful access: Remove “grep 403”
  ```shell
  (Ex: cat $ACCESS_LOG | grep 403 > /tmp/tor.log)
  ```
- To omit specific IP Addresses from being displayed, use the –v Grep option.
  ```shell
  (Ex: cat $ACCESS_LOG | grep 403 | grep –v 192.168.1.1 > /tmp/tor.log)
  ```
- To omit entire IP Ranges from being displayed, use the –v Grep option with a * variable.
  ```shell
  (Ex: cat $ACCESS_LOG | grep 403 | grep –v 192.168.1.* > /tmp/tor.log)
  ```
- To select a custom output time frame, use Grep with the following syntax:
  -Year = Full year followed by a ":"
    ```shell
    (Ex: cat $ACCESS_LOG | grep 2012: | grep 403 | grep –v 192.168.1.* > /tmp/tor.log) 
    ```
  -Month = Three letter abbreviation
    ```shell
    (Ex: cat $ACCESS_LOG | grep Mar | grep 403 | grep –v 192.168.1.* > /tmp/tor.log)
    ```
    
Windows Server Scheduled Task Batch Code (Required for running on Windows Servers)
- Batch file added to Windows server as a Scheduled Task, running daily.
- Batch file retrieves the Tor list from Linux server and copies access log to FTP directory

NOTE: You MUST backup your original .htaccess file and rename it old.htaccess in the same directory PRIOR to running this script.
```batch
del "C:\apache\.htaccess"
copy /B /Y "C:\apache\old.htaccess"+"C:\root-FTP-directory\Tor_List.txt" "C:\apache\htdocs\.htaccess" copy C:\apache\logs\access.log C:\root-FTP-directory\access.log
```
