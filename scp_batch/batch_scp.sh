#!/usr/bin/

#rm -fr dba.tar.gz
#tar zcvf dba.tar.gz dba
#tar zcvf /home/mysql/dba.tar.gz /home/mysql/dba

mysqlpass=“mysqlpass”;
for i in `cat ip.list`
    do
        ./batch_scp.exp $i $mysqlpass;
    done
