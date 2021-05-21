#!/bin/bash
JAVA_HOME=''
jdkDir=/usr/local/jdk/
 
#校验解压JDK的文件夹
if [ -e $jdkDir ]
then 
	echo "$jdkDir文件夹已存在,执行被迫终止!"
	exit
fi
 
echo "检查压缩包是否存在..."
if [ -f $1 ]
then
	mkdir $jdkDir
	echo "开始解压..."
	tar -zxvf $1 -C $jdkDir
	for file in $jdkDir*
	do
		if [ -d $file ]
		then
			JAVA_HOME=$file
		fi
	done
	echo "JAVA_HOME=$JAVA_HOME"	
 
else
	echo 文件不存在:$1
	exit
fi
 
#修改环境变量
 
echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
 
echo "jdk 安装配置完成"
source /etc/profile
echo `java -version`
