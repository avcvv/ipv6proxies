#!/bin/bash
# Made by
# Copyright
# Version: 1.0
# PLEASE ONLY USE THIS FOR CENTOS 7.X

if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

#function StartTheProcess()
#{
	read -r -p "What is your IPv6 prefix? eg:(2604:180:2:11c7) " vPrefix
	read -r -p "VPS IP: " vIp
	read -r -p "Quantity IP for generate: " vCount
	read -r -p "IP who get access to this Proxies: " vIp2
	

	yum -y groupinstall "Development Tools"
        yum -y install gcc zlib-devel openssl-devel readline-devel ncurses-devel wget tar dnsmasq net-tools iptables-services system-config-firewall-tui nano iptables-services
	git clone https://github.com/z3APA3A/3proxy.git
	cd 3proxy
	make -f Makefile.Linux
	ulimit -u unlimited -n 999999 -s 16384
	
	wget https://github.com/avcvv/ipv6proxies/raw/master/3proxycfg.sh
	wget https://github.com/avcvv/ipv6proxies/raw/master/Genips.sh
	chmod 0755 Genips.sh
	chmod 0755 3proxycfg.sh
	
	sed -i "s/1.4.8.8/$vIp2/g" /root/3proxy/3proxycfg.sh
	sed -i "s/i127.0.0.1/i$vIp/g" /root/3proxy/3proxycfg.sh
	
	//extend file limits
	echo '* hard nofile 999999' >> /etc/security/limits.conf
	echo '* soft nofile 999999' >> /etc/security/limits.conf
	
	echo $vPrefix > v_prefix.txt
        echo $vCount > v_count.txt

  echo ====================================
  echo      Stop 3proxy:  OK!
  echo ====================================
  
  kill -9 $(pidof 3proxy)

  echo ====================================
  echo  Remove old ip.list
  echo ====================================

  rm -rf ip.list

  echo ====================================
  echo      Generate IPs: OK!
  echo ====================================

  #./random-ipv6_64-address-generator.sh > ip.list

  #Random generator ipv6 addresses within your ipv6 network prefix.

  # Copyright
  # Vladislav V. Prodan
  # universite@ukr.net
  # 2011


  #read -p "Enter Num IPs to gen: " ipcount
  #read -p "Put your ipv6 network prefix eg: 2604:180:2:b93: " network

  network=$vPrefix
  netip=$vIp
  MAXCOUNT=$vCount
  
  

  #network=2604:180:2:11c7
  #MAXCOUNT=1500

  array=( 1 2 3 4 5 6 7 8 9 0 a b c d e f )
  #MAXCOUNT=1500
  count=1

  #network=2604:180:2:b93 # your ipv6 network prefix
  
  
  rnd_ip_block ()
  {
      a=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
      b=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
      c=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
      d=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
      e=${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}${array[$RANDOM%16]}
      echo $network:$a:$b:$c:$d:$e >> ip.list #Для /64 сети требуется 4 блока:a, b, c, d #Если сеть /48, то 5 блоков, то есть + e блок через двоеточие
  }

  #echo "$MAXCOUNT случайных IPv6:"

  while [ "$count" -le $MAXCOUNT ]        # Генерация 20 ($MAXCOUNT) случайных чисел.
  do
    	rnd_ip_block
          let "count += 1"                # Нарастить счетчик.
          done


  echo ====================================
  echo      Restarting Network: OK!
  echo ====================================

  service network restart

  echo ====================================
  echo      Adding IPs to interface: OK!
  echo ====================================

  for i in `cat ip.list`; do
      #echo "ifconfig eth0 inet6 add $i/64"
      # Если сеть 64 то $i/64 если 48 то $i/48
      ifconfig eth0 inet6 add $i/48
  done

  echo ====================================
  echo      Generate 3proxy.cfg: OK!
  echo ====================================

  /root/3proxy/3proxycfg.sh > 3proxy.cfg


  echo ====================================
  echo      Start 3proxy: OK!
  echo ====================================


  /root/3proxy/bin/3proxy /root/3proxy/3proxy.cfg
  
  
  echo ====================================
  echo      Stop Firewall: OK!
  echo ====================================
  
  systemctl stop firewalld
  systemctl disable firewalld

  #}
