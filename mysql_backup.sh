#!/bin/bash
tdate=`date +'%d%b%Y-%H'`

DIR=/backup

[ ! $DIR ] && mkdir -p $DIR || :

/usr/bin/mysqldump -u dbdump -p'pass@1234' --routines --all-databases --lock-tables=false | gzip -c > $DIR/all_db_$tdate.sql.gz

if [ "$?" == "0" ]; then
        echo "MSM(180.179.174.111) Backup is successful" > /backup/log_file
echo "`cat /backup/log_file`" | /backup/sendEmail -f "db.mysql@netmagicsolutions.com" -t "db.mysql@netmagicsolutions.com" -u "MSM (180.179.174.111) Backup is successful" -s "202.87.39.93:25"
else
        echo "MSM (180.179.174.111) Backup is failed" > /backup/log_file
echo "`/backup/log_file`" | /backup/sendEmail -f "db.mysql@netmagicsolutions.com" -t "db.mysql@netmagicsolutions.com" -u "MSM (180.179.174.111) Backup is failed" -s "202.87.39.93:25"
fi

find $DIR/*.gz -mtime +6 -exec rm {} \;


