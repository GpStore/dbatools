#!/usr/bin
# 安装备份数据库相关的软件包和备份命令
## 前提已经安装xtrabackup相关软件包
## 软件包名称  percona-xtrabackup-24-2.4.4-1.el6.x86_64
## 下载路径
## 相关依赖包 wget ftp://mirror.switch.ch/pool/4/mirror/epel/6/x86_64/libev-4.03-3.el6.x86_64.rpm
## wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/redhat/6/x86_64/percona-xtrabackup-24-2.4.4-1.el6.x86_64.rpm
## 以ROOT用户安装备份工具方法
## yum install percona-xtrabackup-24-2.4.4-1.el6.x86_64.rpm
## 备份恢复之前需要确认Master实例已经有备份恢复账号存在
# 类似于 grant replication slave on *.* to 'repl'@'%' identified by 'repl123';

if [ "$#" == 4 ];
then
	MY_CNF=$1
	USER=$2
	PASS=$3
	BACK_DIR=$4;
elif [ "$#" == 5 ]
then
	MY_CNF=$1
	USER=$2
	PASS=$3
	IP=$4;
	BACK_DIR=$5;
else
        echo "需要至少传入4个参数: my.cnf绝对路径，备份用户,备份用户密码,和备份目录绝对路径,[远程备份IP]，而实际只有 $# 个参数,"
        echo "正确格式如sh percona_backupex.sh /data/my.cnf root rootpass 10.11.12.100  /home/user/server/db_backs"
        exit 1;
fi


TMP=$(date +%Y-%m-%d_%H-%M-%S)

if [ ! -f "$BACK_DIR" ]; 
then
        mkdir -p $BACK_DIR;
fi


#mysql-5.7 需要xtrabackup-2.4版本以上才能备份,然后defaults-file需要写在最前面,同时/dev/null写法不能正常工作


if [ "$#" == 4 ];
then
	innobackupex  --defaults-file=$MY_CNF  --safe-slave-backup --slave-info --no-lock --user=$USER --password=$PASS  --use-memory=2G --stream=xbstream --compress --compress-threads=8 --parallel=4 $BACK_DIR/tmp  2>$BACK_DIR/$TMP.mime.log >$BACK_DIR/$TMP.t.xbstream
else
## 在MASTER机器实例上运行备份命令，统一备份到远程主机的固定目录下
	innobackupex  --defaults-file=$MY_CNF  --safe-slave-backup --slave-info --no-lock --user=$USER --password=$PASS  --use-memory=2G --stream=xbstream --compress --compress-threads=8 --parallel=4  $BACK_DIR/tmp  2>$BACK_DIR/$TMP.mime.log | ssh admin@$IP "cat -> /home/user/server/db_backs/$TMP.xbstream"
fi

## 查看备份操做日志
cat  $BACK_DIR/$TMP.mime.log
