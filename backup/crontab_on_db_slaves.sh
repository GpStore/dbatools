#!/usr/bin
sudo touch /var/spool/cron/mysql
sudo crontab -u mysql /var/spool/cron/mysql

sudo echo '0 2 * * * sh /home/mysql/server/mysql/backup/local_backup_to_remote_daily.sh.x' >> /var/spool/cron/mysql
