#!/bin/sh

if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

echo
      echo ====================================
      echo -e    "\e[1;226;42m Reset network\e[0m"
      echo ====================================
      echo
service network restart
rm -rf /home/proxy-installer/

random() {
	tr </dev/urandom -dc A-Za-z0-9 | head -c5
	echo
}

array=(1 2 3 4 5 6 7 8 9 0 a b c d e f)
gen64() {
	ip64() {
		echo "${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}"
	}
	echo "$1:$(ip64):$(ip64):$(ip64):$(ip64)"
}
install_3proxy() {
      
      echo      
      echo ====================================
      echo -e    "\e[1;226;42m Installing 3proxy\e[0m"
      echo ====================================
      echo
   
	git clone https://github.com/z3APA3A/3proxy.git
	cd 3proxy
	make -f Makefile.Linux

    mkdir -p /usr/local/etc/3proxy/{bin,logs,stat}
    cp src/3proxy /usr/local/etc/3proxy/bin/
    cp ./scripts/rc.d/proxy.sh /etc/init.d/3proxy
    chmod +x /etc/init.d/3proxy
    chkconfig 3proxy on
    cd $WORKDIR
}

gen_3proxy() {
    cat <<EOF
daemon
maxconn 10000
nserver 1.1.1.1
nserver [2606:4700:4700::1111]
nserver [2606:4700:4700::1001]
nserver [2001:4860:4860::8888]
nscache6 65536
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
flush
auth strong
users $(awk -F "/" 'BEGIN{ORS="";} {print $1 ":CL:" $2 " "}' ${WORKDATA})
$(awk -F "/" '{print "auth strong\n" \
"allow " $1 "\n" \
"proxy -6 -n -a -p" $4 " -i" $3 " -e"$5"\n" \
"flush\n"}' ${WORKDATA})
EOF
}

gen_proxy_file_for_user() {
    cat >proxy.txt <<EOF
$(awk -F "/" '{print $1 ":" $2 "@" $3 ":" $4 }' ${WORKDATA})
EOF
}

upload_proxy() {
    local PASS=$(random)
    zip --password $PASS proxy.zip proxy.txt
    URL=$(curl -s --upload-file proxy.zip https://transfer.sh/proxy.zip)

    echo "Proxy is ready! Format LOGIN:PASS@IP:PORT"
    echo "Download zip archive from: ${URL}"
    echo "Password: ${PASS}"

}
gen_data() {
    seq $FIRST_PORT $LAST_PORT | while read port; do
        echo "usr$(random)/pass$(random)/$IP4/$port/$(gen64 $IP6)"
         #echo "usr1/pass1/$IP4/$port/$(gen64 $IP6)"
    done
}

gen_iptables() {
    cat <<EOF
    $(awk -F "/" '{print "iptables -I INPUT -p tcp --dport " $4 "  -m state --state NEW -j ACCEPT"}' ${WORKDATA}) 
EOF
}


gen_ifconfig() {
    cat <<EOF
$(awk -F "/" '{print "ifconfig eth0 inet6 add " $5 "/64"}' ${WORKDATA})
EOF
}

      echo
      echo ====================================
      echo -e    "\e[1;226;42m Installing tools\e[0m"
      echo ====================================
      echo
yum -y groupinstall "Development Tools"
yum -y install gcc zlib-devel openssl-devel readline-devel ncurses-devel wget tar zip dnsmasq net-tools iptables-services system-config-firewall-tui nano iptables-services bsdtar

install_3proxy

echo "working folder = /home/proxy-installer"
WORKDIR="/home/proxy-installer"
WORKDATA="${WORKDIR}/data.txt"
mkdir $WORKDIR && cd $_

IP4=$(curl -4 -s icanhazip.com)
IP6=$(curl -6 -s icanhazip.com | cut -f1-4 -d':')

echo "Internal ip = ${IP4}. Exteranl sub for ip6 = ${IP6}"

echo
      echo ====================================
      echo -e    "\e[1;226;42m Internal IP = ${IP4}\e[0m"
      echo -e    "\e[1;226;42m Exteranl sub for ip6 = ${IP6}\e[0m"
      echo Please check this sub twice, for /64 network it looks like 2604:180:2:11c7 for /48 like 2604:180:2
      echo ====================================
      echo

#echo "How many proxy do you want to create? Example 500"
#read COUNT
echo -r -p "How many proxy do you want to create? Example 500:  " COUNT
#COUNT=$1
#echo $COUNT

FIRST_PORT=10000
LAST_PORT=$(($FIRST_PORT + $COUNT))

gen_data >$WORKDIR/data.txt
gen_iptables >$WORKDIR/boot_iptables.sh
gen_ifconfig >$WORKDIR/boot_ifconfig.sh
chmod +x boot_*.sh /etc/rc.local

gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg

gen_autoboot() {
         cat >>/etc/rc.local <<EOF
         bash ${WORKDIR}/boot_iptables.sh
         bash ${WORKDIR}/boot_ifconfig.sh
         service 3proxy start
EOF
} 

gen_autoboot
bash /etc/rc.local
gen_proxy_file_for_user
upload_proxy
#bash ${WORKDIR}/boot_ifconfig.sh
