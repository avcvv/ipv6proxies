# ipv6proxies
CentOS7 IPv6 + 3proxy

Install: 

wget https://github.com/avcvv/ipv6proxies/raw/master/make.sh

chmod +x install.sh

./make.sh

For Generate new ipv6 on interface run: 
./Genips.sh


Allow access for this IPs edit 3proxycfg.sh: 

echo "allow * WRITE YOUR IP" :: Your IP which will be using this proxy

Run command ./Genips.sh
