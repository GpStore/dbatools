#!/usr/bin
sudo touch /var/spool/cron/mysql
sudo crontab -u mysql /var/spool/cron/mysql

BACKUP_DIR='DIR_IN_BACKUPCENTER';

find $BACKUP_DIR -mtime +7 -type f -name '*.mime.log' -exec rm -f {} \;
find $BACKUP_DIR -mtime +7 -type f -name '*.xbstream' -exec rm -f {} \;
