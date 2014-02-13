#!/bin/bash
# File Name : pitr.sh
# Purpose : in order to crontab PITR from postgresql
# Creation Date : 16-12-2013
# Last Modified : Mon 16 Dec 2013 06:54:13 PM CST
# Release By : Doom.zhou

#Help&Usage
if [[ -z $1 ]] || [[ $1 == "help" ]];then #{{{
    echo -e "\033[31;1mIn order to crontab PITR from postgresql(1th version)\033[0m"
    echo -e "\033[31;1m--------------------------------------------------------\033[0m"
    awk -v t=$0 'BEGIN{
		printf "%-8s%-15s%-15s\n"," Usage: ", t ,""
       	}'
exit 
fi #}}}

#set variables
export PATH=$HOME/bin:$PATH:
datadir=/data/pglab/pitr/
bakdir=/data/pglab/weeklybasebak/
masterport=5432
basedir=`date +%d%m%Y`

#main
if [[ ! -d $bakdir$basedir ]]
then
	mkdir -pv $bakdir$basedir
	chmod 700 $bakdir$basedir
	psql -p $masterport -c "select pg_start_backup('pitrcrontab',true);"
	echo start cp
	cp -r $datadir/*  $bakdir$basedir/
	echo end cp
	psql -p $masterport -c "select pg_stop_backup()"
else
	echo basebackup exsit
fi;

#function write recovey.conf
function genconf () {
	echo "restore_command = 'find /data/pglab/archivedir  -name %f | xargs -n 1 -I {} cp {} %p'" > $bakdir/recovery.conf 
	echo recovery_target_time = \'2013-12-16 18:48:00\' >> $bakdir/recovery.conf 
	echo  $bakdir/recovery.conf generate Successful;
}
genconf


#end
