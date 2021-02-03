echo pidfile /root/3proxy/3proxy.pid

echo daemon
echo maxconn 3333
echo nserver 1.1.1.1
echo nserver [2606:4700:4700::1111]
echo nserver [2606:4700:4700::1001]
echo nserver [2001:4860:4860::8888]
echo nscache6 65536
echo nscache 65536
echo stacksize 6000
echo timeouts 1 5 30 60 180 1800 15 60
echo setgid 65535
echo setuid 65535
echo flush
echo #allow admin


# HTTP(S) прокси
echo "auth iponly"
echo "allow * 127.0.0.1"

#echo "users user1:CL:user1"
#echo "flush"
#echo "allow * * * *"

port=30000
count=1
for i in `cat ip.list`; do
    echo "proxy -6 -n -a -p$port -i127.0.0.1 -e$i"
    ((port+=1))
    ((count+=1))
    if [ $count -eq 10001 ]; then
        exit
    fi
done

# Socks прокси
# echo "#auth iponly"
# echo "#allow * 1.4.8.8"
# echo "users user1:CL:user1"
# echo "flush"
# echo "allow * * * *"

# port=30000
# count=1
# for i in `cat ip.list`; do
#     echo "socks -6 -p$port  -i127.0.0.1 -e$i"
#     ((port+=1))
#     ((count+=1))
#     if [ $count -eq 10001 ]; then
#         exit
#     fi
# done
