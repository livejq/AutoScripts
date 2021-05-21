#!/bin/bash
#awk '{print $NF}' info.txt

#单/双引号里面的变量并不一定为字符串
#单引号不对变量进行替换，双引号会
#=和==都可以比较字符串，而且==符号比=符号功能更丰富
let "a = 1 +1"
b=$a
c='apple'
d='a*'
e=3

if [ "$a" == "$b" ];then
echo "==生效"
fi

if [[ "$c" == a* ]];then
echo "==模式匹配生效"
fi

if [[ "$d" == "a*" ]];then
echo "==字符串匹配生效"
fi

if [ "test.sh" == t* ];then 
echo "当前目录下存在test.sh文件"
fi

#需要转义<，否则认为是一个重定向符号
if [ $a \< $e ];then
echo "变量a小于变量e"
fi
