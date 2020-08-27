#!/bin/bash
local=$(ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:") #取得当前主机IP（可选）
target=192.168.111.2
count=1
delay=900 #延迟900秒再次检查是否有电
date=$(date)

(
cat << EOF

=================
TARGET IP: $target
PING COUNT: $count
TEST DELAY: $delay s
RUN TIME: $date
LOCAL IP: $local
=================
EOF
) >> /var/log/acpower.log #日志
ping -c ${count} ${target} > /dev/NULL #检测路由器是否正常
ret=$?  #将最后一次的PING返回值赋值给ret，$?表示如果命令执行正常返回0，如果不正常返回其它
if [ $ret -eq 0 ]  #如果ret值=0，即PING指令执行正常
then
echo 'AC Power OK!' >> /var/log/acpower.log
else
echo "AC Power maybe off, checking again after ${delay} second!" >> /var/log/acpower.log
sleep ${delay}  #延时
ping -c ${count} ${target} > /dev/NULL
ret=$?
if [ $ret -eq 0 ]
then
echo 'AC Power OK Luckily!' >> /var/log/acpower.log
else
echo 'AC Power off, shut down NAS!' >> /var/log/acpower.log 
docker stop $(docker ps -aq)
shutdown -h 2 # 两分钟后关机并关闭电源
fi
fi
