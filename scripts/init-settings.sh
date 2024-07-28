#!/bin/bash

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci

#iptables设置
sed -i '/REDIRECT --to-ports 53/d' /etc/firewall.user
echo "iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53" >> /etc/firewall.user
echo "iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53" >> /etc/firewall.user

#系统时区设置
uci set system.@system[0].timezone=CST-8
uci set system.@system[0].zonename=Asia/Shanghai
uci commit system

#系统温度调整
uci set glfan.@globals[0].temperature='60'
uci set glfan.@globals[0].intergration='4'
uci set glfan.@globals[0].differential='20'
uci commit glfan

#设置fstab开启热插拔自动挂载
uci set fstab.@global[0].anon_mount=1
uci commit fstab

# 配置nps 
#uci set nps.@nps[0].enabled='0'
#uci set nps.@nps[0].server_addr='127.0.0.1'
#uci set nps.@nps[0].vkey='kbEwlNnKytsg28gfvseCmP5pU8Vqo0c1rrlHfsi3Q'
#uci commit nps
# dnsmasq
#uci set dhcp.@dnsmasq[0].rebind_protection='0'
#uci set dhcp.@dnsmasq[0].localservice='0'
#uci set dhcp.@dnsmasq[0].nonwildcard='0'
#if ! grep -Eq '223.5.5.5' /etc/config/dhcp;then
#  uci add_list dhcp.@dnsmasq[0].server='223.5.5.5#53'
#fi
#uci commit dhcp

# Disable IPV6 ula prefix
# sed -i 's/^[^#].*option ula/#&/' /etc/config/network

# Check file system during boot
# uci set fstab.@global[0].check_fs=1
# uci commit fstab

exit 0
