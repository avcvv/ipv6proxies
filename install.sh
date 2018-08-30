#!/bin/bash
# Made by
# Copyright
# Version: 1.0
# PLEASE ONLY USE THIS FOR CENTOS 7.X

if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

function StartTheProcess()
{
	read -r -p "What is your IPv6 prefix? ex:(2604:180:2:11c7) " vPrefix
	read -r -p "What is your IP? " vIp

	yum -y groupinstall "Development Tools"
        yum -y install gcc zlib-devel openssl-devel readline-devel ncurses-devel wget tar dnsmasq net-tools iptables-services system-config-firewall-tui nano iptables-services
	git clone https://github.com/z3APA3A/3proxy.git
	cd 3proxy
	make -f Makefile.Linux
	ulimit -u unlimited -n 999999 -s 16384

	if [ "$IPAddress" != "$DigResult" ]; then
	    echo 'Error: Hostname does not match IP address yet, please wait otherwise LetsEncrypt will not work.'
	    exit 1
	fi

	echo " "
echo " "
