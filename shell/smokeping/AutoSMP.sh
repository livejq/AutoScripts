#!/bin/bash

target_dir="/opt/ysnet"

updateUb() {
cp /etc/apt/sources.list /etc/apt/sources.list.old
cat << EOF > /etc/apt/sources.list
deb https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-proposed main restricted universe multiverse
deb https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
deb-src https://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
EOF
}

updateCe() {
mv /etc/yum.repos.d/* /tmp/
curl -o /etc/yum.repos.d/centos7.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum -y install epel-release
yum clean all && yum repolist
}

get_info() {
	source /etc/os-release || source /usr/lib/os-release || exit 1
	if [[ $ID == "centos" ]]; then
		PM="yum"
		INS="yum install"
		updateCe
	elif [[ $ID == "debian" || $ID == "ubuntu" ]]; then
		PM="apt"
		INS="apt install"
		updateUb
	else
		exit 1
	fi
	read -rp "输入监控页面端口（默认20000）：" port1
	ss -tnlp | grep -q ":${port1:-20000} " && echo "端口 ${port1:-20000} 已被占用" && exit 1
}

install_packages() {
	rpm_packages="smokeping unzip wqy-zenhei-fonts.noarch"
	apt_packages="smokeping echoping unzip traceroute"
	if [[ $ID == "debian" || $ID == "ubuntu" ]]; then
		$PM update
		$INS wget curl -y
		$INS $apt_packages -y || error=1
		[[ $error -eq 1 ]] && echo "安装 smokeping 失败" && exit 1
		systemctl stop apache2 && systemctl stop smokeping
		configureUb
	elif [[ $ID == "centos" ]]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
		setenforce 0
		$INS wget curl -y
		$INS $rpm_packages -y
		systemctl stop httpd && systemctl stop smokeping
		configureCe
	fi
}

configureUb() {
	#get local ip
	origin="https://github.com/jiuqi9997/smokeping/raw/main"
	ip=$(curl -sL https://api64.ipify.org -4) || error=1
	[[ $error -eq 1 ]] && echo "获取本机 IP 地址失败" && exit 1
	#clean local config
	mkdir -p $target_dir
	mkdir -p /var/run/smokeping
	rm -fr /var/lib/smokeping/*/*.rrd
	rm -fr /etc/smokeping/config.d
	#get Gist config
	wget https://gist.github.com/livejq/d60d8db950a42e9ceb7e4c01e9d32921/archive/9275570e264e12fbaf62a0fc40229818834a74d3.zip
	unzip -o *.zip -d /etc/smokeping/
	mv /etc/smokeping/d60d8db950a42e9ceb7e4c01e9d32921-9275570e264e12fbaf62a0fc40229818834a74d3 /etc/smokeping/config.d
	mv /etc/smokeping/config.d/HW-HK /opt/ysnet
	sed -i 's/some.url/'$ip':'${port1:-20000}'/g;' /etc/smokeping/config.d/General
	sed -i 's/smokeping.cgi/smokeping/g;' /etc/smokeping/config.d/General
	#apache2
	sed -i 's/80/'${port1:-20000}'/g' /etc/apache2/ports.conf
	sed -i 's/DirectoryIndex/DirectoryIndex smokeping.cgi/g' /etc/apache2/mods-available/dir.conf
	systemctl enable apache2 smokeping
	#TCPPing
	wget -O /usr/bin/tcpping https://raw.githubusercontent.com/deajan/tcpping/master/tcpping
	chmod 755 /usr/bin/tcpping
	#timezone
	timedatectl set-timezone Asia/Shanghai
	smokeping --debug || error=1
	[[ $error -eq 1 ]] && echo "测试运行失败！" && exit 1
	systemctl start apache2 smokeping || error=1
	[[ $error -eq 1 ]] && echo "启动失败" && exit 1
	echo ""
	echo "安装完成，监控页面网址：http://$ip:${port1:-20000}/smokeping"
	echo ""
	echo "注意："
	echo "如有必要请在防火墙放行 ${port1:-20000} 端口"
	echo "请等待一会，监控数据不会立即更新"
}

configureCe() {
	#get local ip
	origin="https://github.com/jiuqi9997/smokeping/raw/main"
	ip=$(curl -sL https://api64.ipify.org -4) || error=1
	[[ $error -eq 1 ]] && echo "获取本机 IP 地址失败" && exit 1
	#clean local config
	mkdir -p $target_dir
	rm -fr /var/lib/smokeping/*/*.rrd
	rm -fr /etc/smokeping/config.d
	rm -fr /etc/smokeping/config
	#get Gist config
	wget https://gist.github.com/livejq/5175c6801ac088cf5177f6a1b12af45c/archive/002038e18ae5617b7aea89ba188c4886cc72eb99.zip
	unzip -o *.zip -d /etc/smokeping/
	mv /etc/smokeping/5175c6801ac088cf5177f6a1b12af45c-002038e18ae5617b7aea89ba188c4886cc72eb99 /etc/smokeping/config.d
	mv /etc/smokeping/config.d/HW-HK /opt/ysnet
	mv /etc/smokeping/config.d/config /etc/smokeping
	sed -i 's/localhost/'$ip':'${port1:-20000}'/g;' /etc/smokeping/config.d/General
	#httpd
	sed -i 's/Require local/Require all granted/g;' /etc/httpd/conf.d/smokeping.conf
	sed -i 's/Listen 80/Listen '${port1:-20000}'/g' /etc/httpd/conf/httpd.conf
	systemctl enable httpd smokeping
	#TCPPing
	wget -O /usr/bin/tcpping https://raw.githubusercontent.com/deajan/tcpping/master/tcpping
	chmod 755 /usr/bin/tcpping
	#firewalld
	systemctl stop firewalld && systemctl disable firewalld
	#timezone
	timedatectl set-timezone Asia/Shanghai
	smokeping --debug || error=1
	[[ $error -eq 1 ]] && echo "测试运行失败！" && exit 1
	systemctl start httpd smokeping || error=1
	[[ $error -eq 1 ]] && echo "启动失败" && exit 1
	echo ""
	echo "安装完成，监控页面网址：http://$ip:${port1:-20000}/smokeping/sm.cgi"
	echo ""
	echo "注意："
	echo "如有必要请在防火墙放行 ${port1:-20000} 端口"
	echo "请等待一会，监控数据不会立即更新"
}

get_info
install_packages