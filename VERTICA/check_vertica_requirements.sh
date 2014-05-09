#!/bin/bash

node="$1"

echo "==> Checking requirements for Vertica on cluster node: $node"

bash_check=$(which bash)
sudo_check=$(which sudo)

if [ -z "$bash_check" ]; then
   
	echo "==> Please check bash shell"

else

	echo "==> bash shell Looks good!"

fi


if [ -z "$sudo_check" ]; then

	echo "==> Please see sudo installation"

else

	echo "==> sudo Looks good!"

fi

echo "==> Firewall Settings" && service iptables save && service iptables status && service iptables stop && chkconfig iptables off

echo "==> Checking NTP settings" && chkconfig --list ntpd 

echo "==> Checking Runlevel" && runlevel

echo "==> Verify if NTP is operating correctly" && /usr/sbin/ntpq -c rv | grep stratum

echo "==> Install pstack, mcelog and sysstat packages" && yum install pstack mcelog sysstat

echo "==> Update the time zone database" && yum update tzdata

echo "==> Set GMT timezone" && echo "export TZ=\"GMT\"" >> /etc/profile



