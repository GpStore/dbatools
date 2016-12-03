#!/usr/bin
if [ "$#" != 3 ];
then
    echo "需要传入3个参数:用户名如mysql, 磁盘类型如sata, 数据目录如/data, 端口号比如3306"
    echo "正确格式如sh buildServer.sh dba ssd /data 3306"
    exit 1;
fi

user=$1;
disk=$2;
dir=$3;
port=$4;


#初始化/home/$user/server目录下相关文件夹与文件
mkdir -p /home/$user/server/{db_srcs,db_backs,db_logs};

#安装percona依赖包，含备份恢复
cd  /home/$user/dba/rpm/perco57_boost159.tar.gz  /home/$user/server/db_srcs;

sudo yum install perl-DBD-MySQL-4.023-5.el7.x86_64
sudo rpm -Uvh libev-4.03-3.el6.x86_64.rpm
sudo rpm -Uvh percona-xtrabackup-24-2.4.4-1.el7.x86_64.rpm 

#源码安装percona代码 to /home/$user/server/mysql dir
cd /home/$user/server/db_srcs;
tar zxvf  perco57_boost159.tar.gz
tar zxvf percona-server-5.7.15-9.tar.gz
cd ~/server/db_srcs/percona-server-5.7.15-9
cmake . -DCMAKE_INSTALL_PREFIX=/home/$user/server/mysql  -DWITH_BOOST=/home/$user/server/db_srcs/ -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8mb4 -DWITH_TOKUDB_STORAGE_ENGINE=1
make -j 35
make install

#sleep 2;
# init mysql need dirs and files
cp -fr /home/$user/dba/backup /home/$user/server/mysql
cp -fr /home/$user/dba/mha /home/$user/server/mysql
cp -fr /home/$user/dba/initDirs.sh /home/$user/server/mysql


sudo sh ~/server/mysql/initDirs.sh  $user $dir $port 


#init mysqld with my.cnf and get error file of root passwd
#done thie in createdbinstance.sh   cp  /home/$user/dba/my${port}_${disk}.cnf /home/$user/server/my$port{}.cnf


rm -fr /home/$user/server/db_logs/mysql${port}/error.log
/home/$user/server/mysql/bin/mysqld --defaults-file=~/server/my${port}.cnf --initialize-insecure && cat /home/$user/server/db_logs/mysql${port}/error.log

numactl --interleave=all /home/$user/server/mysql/bin/mysqld_safe --defaults-file=/home/$user/server/my${port}.cnf -u${user} & 



