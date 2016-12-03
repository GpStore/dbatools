#!/usr/bin/bash

cd /home/mysql/server/mysql/backup
tar zxvf shc-3.8.3.tgz
make test
make strings
sudo mkdir -p /usr/local/man/man1
sudo make install;

cd ..
shc -f local_backup_to_remote_daily.sh
sudo sed -i -e '#^.*.backup_remote*#d' /var/spool/cron/mysql;
sudo echo "0 2 * * * /home/mysql/server/mysql/backup/local_backup_to_remote_daily.sh.x" >> /var/spool/cron/mysql
sudo systemctl restart cornd.service
crontab -l
##slave to do
#rm -fr local_backup_to_remote_daily.sh
