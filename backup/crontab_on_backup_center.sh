#!/usr/bin
sudo touch /var/spool/cron/mysql
sudo crontab -u mysql /var/spool/cron/mysql

sudo echo '0 2 * * * sh /home/mysql/server/mysql/backup/backup_center_delete_7days_before.sh' >> /var/spool/cron/mysql
