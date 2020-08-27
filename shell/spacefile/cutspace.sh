#!/bin/bash
#来源：https://blog.csdn.net/u012844301/article/details/50983526
dir=./
echo -e "\n 本程序将目录下所有文件名中的空格替换为“-”符号 \n"
read -p "请输入目录：" dir #默认脚本所在目录

#获取该目录下带空格的文件的路径
files=$(find ${dir} -name "* *")

#将原本的分隔符记录
old=${IFS}

#将内部域分隔符设置为换行
IFS=$'\n'

for file in ${files}; do
    rename=$(echo ${file} | sed 's/[[:space:]]/-/g')
    mv "${file}" "${rename}"
done

IFS=${old}
