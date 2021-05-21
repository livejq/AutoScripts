#!/bin/bash
jdkpath=/usr/local/lib/java/
sudo mkdir -p $jdkpath
#read -p "Please input the name of JDK file you downloaded: " jdkfile
jdkfile=`ls|grep jdk`
sudo cp $jdkfile $jdkpath
cd $jdkpath
sudo tar xvf $jdkfile
sudo rm $jdkfile
dirname=`ls`
cd ~
echo >>.bashrc
echo "export JAVA_HOME=$jdkpath$dirname">>.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin:\$JAVA_HOME/jre/bin">>.bashrc
echo "export CLASSPATH=.:\$JAVA_HOME/lib:\$JAVA_HOME/jre/lib">>.bashrc
. .bashrc
