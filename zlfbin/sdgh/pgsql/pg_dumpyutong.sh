#!/bin/bash
#File Name : pg_dumpyutong.sh
#Purpose :pg_dump for yutong
#Creation Date : 10-12-2013
#Last Modified : Thu 19 Dec 2013 07:06:58 PM CST
#Release By : Doom.zhou

#set variables 
export PATH=/home/postgres/bin/pg_dump:$PATH
send=`date '+%Y-%m-%d'`
send2=`date -d '7 day ago' '+%Y-%m-%d'`

#main
su -m postgres -c 'rm -rf /data/data_bak/pg_dumpBak'$send2'.sql'
su -m postgres -c 'pg_dumpall -p 5432 | gzip >/data/data_bak/pg_dumpBak'$send'.gz'
echo 'postgresql dumpAll done... time:'$send
echo 'clean history backup done... time:'$send2

#end
