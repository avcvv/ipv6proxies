#!/bin/bash
# Made by
# Copyright
# Version: 1.0
# PLEASE ONLY USE THIS FOR CENTOS 7.X

  ulimit -u unlimited -n 999999 -s 16384
  echo ====================================
  echo  Stop 3proxy: OK!
  echo ====================================

  #kill -9 $(pidof 3proxy)
  pkill 3proxy

  echo ====================================
  echo  Remove old ip.list: OK!
  echo ====================================

  rm -rf ip.list

  echo ====================================
  echo  Generate IPs: OK!
  echo ====================================

  #./random-ipv6_64-address-generator.sh > ip.list

  #Random generator ipv6 addresses within your ipv6 network prefix.

  # Copyright
  # Vladislav V. Prodan
  # universite@ukr.net
  # 2011


  #read -p "Enter Num IPs to gen: " ipcount
  #read -p "Put your ipv6 network prefix eg: 2604:180:2:b93: " network

  network="$(cat v_prefix.txt)"
  MAXCOUNT="$(cat v_count.txt)"

  array=( 1 2 3 4 5 6 7 8 9 0 a b c d e f )
  #MAXCOUNT=1500 #количество прокси
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
      ifconfig eth0 inet6 add $i/48 # Если сеть 64 то $i/64 если 48 то $i/48
  done


  echo ====================================
  echo      Generate 3proxy.cfg
  echo ====================================

  /root/3proxy/3proxycfg.sh > 3proxy.cfg
  
  echo ====================================
  echo      Start 3proxy: OK!
  echo ====================================
  
  ulimit -u unlimited -n 999999 -s 16384

  /root/3proxy/bin/3proxy /root/3proxy/3proxy.cfg
