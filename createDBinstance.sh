#!/usr/bin
if [ "$#" != 7 ];
then
    echo "需要传入5个参数:用户名如mysql, 实例类型如slave,  磁盘类型如sata,数据目录如/data ip地址如10.11.12.13，serverid如1213, 端口号比如3306"
    echo "正确格式如sh createDBinstance.sh dba master ssd /data 10.11.12.13  1213  3306"
    exit 1;
fi

user=$1;
type=$2;
disk=$3;
dir=$4;
ip=$5;
sid=$6;
port=$7;


sh /home/$user/dba/yum_install.sh

mkdir /home/$user/dba/cnf
cp /home/admin/dba/my3306_${disk}.cnf /home/${user}/dba/cnf/my${port}_${disk}.cnf
sed -i "s#3306#$port#g" /home/${user}/dba/cnf/my${port}_${disk}.cnf
sed -i "s#ip%#$ip#g" /home/${user}/dba/cnf/my${port}_${disk}.cnf
sed -i "s#sid%#$sid#g" /home/${user}/dba/cnf/my${port}_${disk}.cnf

cat /home/${user}/dba/cnf/my${port}_${disk}.cnf |grep bind
cat /home/${user}/dba/cnf/my${port}_${disk}.cnf |grep server-id
sleep 5;

cp /home/${user}/dba/cnf/my${port}_${disk}.cnf /home/${user}/server/my${port}.cnf
sh /home/${user}/dba/buildServer.sh  $user $disk $dir $port 
sleep 5;

/home/${user}/server/mysql/bin/mysql -S /tmp/mysql{port}/mysqld.sock -uroot -e "set password=PASSWORD('root123');"
if [ $type == master ]
then
    /home/${user}/server/mysql/bin/mysql -S /tmp/mysql{port}/mysqld.sock -uroot -proot123 -e "";
    /home/${user}/server/mysql/bin/mysql -S /tmp/mysql{port}/mysqld.sock -uroot -proot123 -e "";
    /home/${user}/server/mysql/bin/mysql -S /tmp/mysql{port}/mysqld.sock -uroot -proot123 -e "";
    /home/${user}/server/mysql/bin/mysql -S /tmp/mysql{port}/mysqld.sock -uroot -proot123 -e "";
fi
/home/${user}/server/mysql/bin/mysqladmin -S /tmp/mysql{port}/mysqld.sock -uroot -proot123 shutdown;

