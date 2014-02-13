#!/bin/bash
# File Name : report.sh
# Purpose :
# Creation Date : 13-12-2013
# Last Modified : Mon 23 Dec 2013 06:02:22 PM CST
# Release By : Doom.zhou

#Help
if [[ -z $1 ]] || [[ $1 == "help" ]];then echo -e "\033[32;1mUsage: $0 Corpcode Starttime Endtime" ;exit 0;fi
#set variables

[ -z $3 ] && Et=$2  || Et=$3
if [[ ! $2 =~ ^[1-9][0-9]{3}-(0[1-9]|1[0-2]|[1-9])-([1-9]|0[1-9]|[1-2][0-9]|3[0-1])$ ]] || [[ ! $Et =~ ^[1-9][0-9]{3}-(0[1-9]|1[0-2]|[1-9])-([1-9]|0[1-9]|[1-2][0-9]|3[0-1])$ ]];then echo "NOT A YYYY-mm-dd!" && exit 0;fi



#main
echo "SELECT study_report_range_caller('"$1"','"$2"','"$Et"');"
#select p_login_situation_statistics('','');
#cat rfs.sql | sed -n 's@公司编号@cnjf@gp' | sed -n 's@开始时间@2013-1-21@gp' | sed -n 's@结束时间@2013-1-21@gp'

#end
