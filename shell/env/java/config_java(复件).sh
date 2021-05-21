#!/bin/sh
# 用于一键安装配置JDK，放到jdk安装包同级目录即可
# 使用source来运行该脚本即可
# source jdk-install.sh

# 获取jdk路径
# 如果不是参数，则用默认的路径../
JDK_TAR=$1
if [ -n $JDK_TAR ];then
# 找出当前目录下的jdk-*.tar.gz文件
    JDK_TAR=`find . -name "jdk-*.tar.gz"`
fi
echo $JDK_TAR

# 配置文件安装路径
INS_PATH_JDK="/usr/java/latest"

echo "开始进行jdk安装"
# 当串的长度大于0时为真(串非空)
if [ -n $JAVA_HOME ]; then
    # JDK安装
    mkdir -p /usr/java
    tar -zxf $JDK_TAR -C /usr/java
    ln -s /usr/java/jdk* /usr/java/latest
    # 设置环境变量
    export JAVA_HOME=/usr/java/latest
    export JRE_HOME=/usr/java/latest/jre
    export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib
    export PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
    # 写入到文件中
    echo "export JAVA_HOME=/usr/java/latest
export JRE_HOME=/usr/java/latest/jre
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JRE_HOME/lib
export PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin" >> /etc/profile
    source /etc/profile
    echo "jdk安装完成"
else
    echo "检测到已安装JDK，JAVA_HOME为 $JAVA_HOME ，跳过jdk安装"
fi
echo "jdk版本信息如下"
echo `java -version`
