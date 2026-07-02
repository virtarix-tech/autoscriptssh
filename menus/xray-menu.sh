#!/bin/bash
# Xray Menu
clear
echo -e "v2ray menu service"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "[ 1 ] create vmess acount"
echo -e "[ 2 ] create vless acount"
echo -e "[ 3 ] create trojan acount"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━"
read -p "Select option: " opt

case $opt in
1) /opt/virtarixtech/bin/add-vmess ;;
2) /opt/virtarixtech/bin/add-vless ;;
3) /opt/virtarixtech/bin/add-trojan ;;
*) echo "Invalid option" ;;
esac