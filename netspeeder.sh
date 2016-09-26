#!/bin/sh

# Set Linux PATH Environment Variables
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check If You Are Root
if [ $(id -u) != "0" ]; then
    clear
    echo -e "\033[31m 错误：本脚本必须以root用户执行！\033[0m"
    exit 1
fi

if [ $(arch) == x86_64 ]; then
    OSB=x86_64
elif [ $(arch) == i686 ]; then
    OSB=i386
else
    echo -e "\033[31m 错误: 不能确定 CentOS 的平台. \033[0m"
    exit 1
fi
if egrep -q "5.*" /etc/issue; then
    OST=5
    wget http://dl.fedoraproject.org/pub/epel/5/${OSB}/epel-release-5-4.noarch.rpm
elif egrep -q "6.*" /etc/issue; then
    OST=6
    wget http://dl.fedoraproject.org/pub/epel/6/${OSB}/epel-release-6-8.noarch.rpm
else
    echo -e "\033[31m 错误: 请重新安装 CentOS 5 或 6 版本. \033[0m"
    exit 1
fi

rpm -Uvh epel-release*rpm
yum install -y libnet libnet-devel libpcap libpcap-devel gcc

wget https://github.com/crazy886/netspeeder/releases/download/0.1/netspeeder.zip -O /usr/local/netspeeder.zip|unzip
cd /usr/local/net_speeder
if [ -f /proc/user_beancounters ] || [ -d /proc/bc ]; then
    sh build.sh -DCOOKED
    INTERFACE=venet0
else
    sh build.sh
    INTERFACE=eth0
fi

echo -e "\033[36m net_speeder 安装完成. \033[0m"
echo -e "\033[36m 用法: nohup /usr/local/net_speeder/net_speeder $INTERFACE \"ip\" >/dev/null 2>&1 & \033[0m"
