#!/bin/sh

# Set Linux PATH Environment Variables
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
rm -rf /usr/local/netspeeder

echo -e "\033[34m================================================================\033[0m

                欢迎使用 net-speeder 一键脚本

            系统要求:  CentOS 5,6,7, Debian, Ubuntu
            描述: 一键安装 Snet-speeder
            作者: DengXizhen
            联系方式： 1613049323@qq.com
	          			  
\033[34m================================================================\033[0m";

# Check If You Are Root
if [ $(id -u) != "0" ]; then
    clear
    echo -e "\033[31m 错误：本脚本必须以root用户执行！\033[0m"
    exit 1
fi
    
# CentOS
function centOS(){
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
	    if ! wget http://dl.fedoraproject.org/pub/epel/5/${OSB}/epel-release-5-4.noarch.rpm; then
		echo -e "\033[31m下载 epel 文件失败！\033[0m"
	        exit 1
	    fi
	elif egrep -q "6.*" /etc/issue; then
	    OST=6
	    if ! wget http://dl.fedoraproject.org/pub/epel/6/${OSB}/epel-release-6-8.noarch.rpm; then
		echo -e "\033[31m下载 epel 文件失败！\033[0m"
	        exit 1
	    fi
	else
	    if ! wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm; then
		echo -e "\033[31m下载 epel 文件失败！\033[0m"
	        exit 1
	    fi
	fi
	
	rpm -Uvh epel-release*rpm
	yum install -y libnet libnet-devel libpcap libpcap-devel gcc
}

# Debian/Ubuntu
function debian_ubuntu(){
    apt-get install libnet1-dev libpcap0.8-dev gcc
}

# 判断操作系统，并准备依赖包
if [ -f /etc/redhat-release ];then
    OS='CentOS'
    centOS
elif [ ! -z "`cat /etc/issue | grep bian`" ];then
    OS='Debian'
    debian_ubuntu
elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
    OS='Ubuntu'
    debian_ubuntu
else
    echo -e "\033[31m错误: 不支持该操作系统，请重新安装并重试！\033[0m"
    exit 1
fi

# 下载源码，并编译
if ! wget --no-check-certificate -O /usr/local/netspeeder.zip https://github.com/crazy886/netspeeder/releases/download/0.1/netspeeder.zip; then
    echo -e "下载 netspeeder.zip 文件失败！"
    exit 1
else
    cd /usr/local
    unzip netspeeder.zip
fi

cd /usr/local/netspeeder
if [ -f /proc/user_beancounters ] || [ -d /proc/bc ]; then
    sh build.sh -DCOOKED
    INTERFACE=venet0
else
    sh build.sh
    INTERFACE=eth0
fi

if [ -e /usr/local/netspeeder/net_speeder ]; then
    echo -e "\033[36m net_speeder 安装完成. \033[0m"
    echo -e "\033[36m 用法: nohup /usr/local/netspeeder/net_speeder $INTERFACE \"ip\" >/dev/null 2>&1 & \033[0m"
else
    echo -e "编译 net_speeder 失败！"
fi
