#!/bin/bash
#tjg (Wegare)
clear
host2="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $1}')" 
port2="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $2}')" 
bug2="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $3}')" 
pass2="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $4}')" 
path2="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $5}')" 
udp2="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $6}')" 

echo "Inject trojan-go by wegare"
echo "1. Sett Profile"
echo "2. Start Inject"
echo "3. Stop Inject"
echo "4. Enable auto booting & auto rekonek"
echo "5. Disable auto booting & auto rekonek"
echo "e. exit"
read -p "(default tools: 2) : " tools
[ -z "${tools}" ] && tools="2"
if [ "$tools" = "1" ]; then

echo "Masukkan host/ip" 
read -p "default host/ip: $host2 : " host
[ -z "${host}" ] && host="$host2"

echo "Masukkan port" 
read -p "default port: $port2 : " port
[ -z "${port}" ] && port="$port2"

echo "Masukkan password/key" 
read -p "default password/key: $pass2 : " pass
[ -z "${pass}" ] && pass="$pass2"

echo "Masukkan bug" 
read -p "default bug: $bug2 : " bug
[ -z "${bug}" ] && bug="$bug2"

echo "Masukkan path" 
read -p "default path: $path2 : " path
[ -z "${path}" ] && path="$path2"

read -p "ingin menggunakan port udpgw y/n " pilih
if [ "$pilih" = "y" ]; then
echo "Masukkan port udpgw" 
read -p "default udpgw: $udp2 : " udp
[ -z "${udp}" ] && udp="$udp2"
badvpn="--socks-server-addr 127.0.0.1:1080 --udpgw-remote-server-addr 127.0.0.1:$udp"
elif [ "$pilih" = "Y" ]; then
echo "Masukkan port udpgw" 
read -p "default udpgw: $udp2 : " udp
[ -z "${udp}" ] && udp="$udp2"
badvpn="--socks-server-addr 127.0.0.1:1080 --udpgw-remote-server-addr 127.0.0.1:$udp"
else
badvpn="--socks-server-addr 127.0.0.1:1080"
fi
if [[ -z $udp ]]; then
udp="-"
fi
echo "$host
$port
$bug
$pass
$path
$udp" > /root/akun/tjg.txt
cat <<EOF> /root/akun/tjg.json
{
  "run_type": "client",
  "local_addr": "127.0.0.1",
  "local_port": 1080,
  "remote_addr": "$host",
  "remote_port": $port,
  "password": ["$pass"],
  "ssl": {
       "verify": false,
       "sni": "$bug"
  },
  "router":{
        "enabled": true,
        "bypass": [
            "geoip:cn",
            "geoip:private",
            "geosite:cn",
            "geosite:geolocation-cn"
        ],
        "block": [
            "geosite:category-ads"
        ],
        "proxy": [
            "geosite:geolocation-!cn"
        ],
        "default_policy": "proxy"
   },
  "websocket": {
       "enabled": true,
       "path": "$path",
       "host": "$bug"
   }
}
EOF
cat <<EOF> /usr/bin/gproxy-tjg
badvpn-tun2socks --tundev tun1 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 $badvpn --udpgw-connection-buffer-size 65535 --udpgw-transparent-dns &
EOF
chmod +x /usr/bin/gproxy-tjg
echo "Sett Profile Sukses"
sleep 2
clear
/usr/bin/tjg
elif [ "${tools}" = "2" ]; then
ipmodem="$(route -n | grep -i 0.0.0.0 | head -n1 | awk '{print $2}')" 
echo "ipmodem=$ipmodem" > /root/akun/ipmodem.txt
udp="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $6}')" 
host="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $1}')" 
route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)"

trojan-go -config /root/akun/tjg.json &
sleep 5
ip tuntap add dev tun1 mode tun
ifconfig tun1 10.0.0.1 netmask 255.255.255.0
/usr/bin/gproxy-tjg
route add 8.8.8.8 gw $route metric 0
route add 8.8.4.4 gw $route metric 0
route add $host gw $route metric 0
route add default gw 10.0.0.2 metric 0
echo "
#!/bin/bash
#tjg (Wegare)
host=$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $1}')
fping -l $host" > /usr/bin/ping-tjg
chmod +x /usr/bin/ping-tjg
/usr/bin/ping-tjg > /dev/null 2>&1 &
sleep 5
elif [ "${tools}" = "3" ]; then
host="$(cat /root/akun/tjg.txt | tr '\n' ' '  | awk '{print $1}')" 
route="$(cat /root/akun/ipmodem.txt | grep -i ipmodem | cut -d= -f2 | tail -n1)" 
#killall screen
killall -q badvpn-tun2socks trojan-go ping-tjg fping
route del 8.8.8.8 gw "$route" metric 0 2>/dev/null
route del 8.8.4.4 gw "$route" metric 0 2>/dev/null
route del "$host" gw "$route" metric 0 2>/dev/null
ip link delete tun1 2>/dev/null
killall dnsmasq 
/etc/init.d/dnsmasq start > /dev/null
sleep 2
echo "Stop Suksess"
sleep 2
clear
/usr/bin/tjg
elif [ "${tools}" = "4" ]; then
cat <<EOF>> /etc/crontabs/root

# BEGIN AUTOREKONEKTJG
*/1 * * * *  autorekonek-tjg
# END AUTOREKONEKTJG
EOF
sed -i '/^$/d' /etc/crontabs/root 2>/dev/null
/etc/init.d/cron restart
echo "Enable Suksess"
sleep 2
clear
/usr/bin/tjg
elif [ "${tools}" = "5" ]; then
sed -i "/^# BEGIN AUTOREKONEKTJG/,/^# END AUTOREKONEKTJG/d" /etc/crontabs/root > /dev/null
/etc/init.d/cron restart
echo "Disable Suksess"
sleep 2
clear
/usr/bin/tjg
elif [ "${tools}" = "e" ]; then
clear
exit
else 
echo -e "$tools: invalid selection."
exit
fi