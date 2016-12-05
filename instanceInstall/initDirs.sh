#!/usr/bin/bash

if [ "$#" != 2 ];
then
            echo "需要传入3个参数: home目录下用户名如dba, 数据安装目录如/data1, 端口号比如3306"
            echo "正确格式如sudo sh initDirs.sh dba /data1  3306"
            exit 1;
fi

user=$1
dir=$2
port=$3

                    
mkdir -p /home/$user/server/db_logs/mysql$port
mkdir -p $dir//mysql/data$port

cd  $dir/mysql/data$port
mkdir -p {binlog,relaylog,data,tmp,backup}
touch  binlog/binlog.index
chmod -R 760 binlog
chmod -R 750 data
chown -R $user:$user /home/$user
chown -R $user:$user  $dir/mysql/data$port

