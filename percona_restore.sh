
#!/bin/bash
#echo $#
if [ "$#" != 3 ];
then
        echo "需要传入两个参数:备份文件所在目录，my.cnf绝对路径, 恢复文件夹[my.cnf中datadir绝对路径],实际只有 $# 个参数,"
        echo "正确格式如./decompress.sh /data/backup/t.xbstream /home/gp/my.cnf  /data/mysql/data"
fi
DIR_BACKUP=$1;
DIR_MYCNF=$2;
DIR_RESTORE=$3;
echo "备份文件绝对路径："$DIR_BACKUP;
echo "mysql实例的data目录："$DIR_RESTORE;
if [ ! -f "$DIR_BACKUP" ]; 
then
        echo "$DIR_BACKUP 文件不存在"
        exit 1;
fi
if [ ! -f "$DIR_MYCNF" ];
then
        echo "$DIR_MYCNF 文件不存在"
        exit 1;
fi
if [ -d "$DIR_RESTORE" ]; 
then
        mv -f $DIR_RESTORE /tmp/;
fi
mkdir -p "$DIR_RESTORE"
repath=$(cd `dirname $DIR_RESTORE`;pwd)
echo "mysql恢复的base目录："$repath
echo "参数配置正常；"

## MySQL备份之后的恢复脚本
## percona-xtrabackup-24-2.4.4-1.el6.x86_64下载路径
## wget https://www.percona.com/downloads/XtraBackup/Percona-XtraBackup-2.4.4/binary/redhat/6/x86_64/percona-xtrabackup-24-2.4.4-1.el6.x86_64.rpm
## 以ROOT用户安装 yum install percona-xtrabackup-24-2.4.4-1.el6.x86_64.rpm
## MySQL安装
## yum install Percona-mysql的client,develop,share和Server四个安装包

##先解压xbstream
xbstream -x -v <$DIR_BACKUP -C $DIR_RESTORE;
innobackupex --decompress --parallel=4 $DIR_RESTORE;
find  $DIR_RESTORE  -name "*.qp" -delete;
##准备MySQL实例配置文件与相关初始目录与文件等
cd $repath
mkdir -p {binlog,relaylog,data,tmp,backup}
touch  binlog/binlog.index
chmod -R 760 binlog
chmod -R 750 data

innobackupex --use-memory=1G  --apply-log $DIR_RESTORE
cd $DIR_RESTORE;
mv ib* ../
mv undo* ../
mv xtrabackup* ../backup/
cd $repath
chmod -R 755 relaylog
touch slow.log
chmod a+r slow.log
chmod 664 *.log
chmod 660 ib*
chown -R mysql:mysql $repath

#innobackupex --defaults-file=$DIR_MYCNF  --copy-back $DIR_RESTORE
## 启动MySQL服务程序
mysqld_safe --defaults-file=$DIR_MYCNF --skip-name-resolve --read-only=1 -umysql&

## 挂载复制起始文件与位置点
## mysql -e "stop slave; change master to MASTER_HOST='127.0.0.1', MASTER_PORT=3306, MASTER_USER='repl', MASTER_PASSWORD='repl123', MASTER_LOG_FILE='binlog.000003', MASTER_LOG_POS=745; "
## 恢复成功
## mysql -e "start slave ; show slave status\G";
