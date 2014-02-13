#!/bin/bash
# File Name : sshtunneldeamon.sh
# Purpose :
# Creation Date : 25-12-2013
# Last Modified : Wed 25 Dec 2013 04:10:20 PM CST
# Release By : Doom.zhou

#Help&Usage
if [[ -z $1 ]] || [[ $1 == "help" ]];then #{{{
    echo -e "\033[31;1mdeamon the ssh tunnel\033[32;1m(1th version)\033[0m"
    echo -e "\033[31;1m--------------------------------------------------------\033[0m"
    awk -v t=$0 'BEGIN{
		printf "%-8s%-15s%-15s\n"," Usage: ", t ,""
       	}'
exit 
fi #}}}

#set variables
export PATH=$HOME/bin:$PATH
target=app14
portlist=22,80,3389,149,1521,5432,11111

#main
arr=(`echo $portlist | tr , "  "`)

#kill
if [[ $1 == "kill" ]];
then
	pid=`ps -ef | grep sshtunneldeamon | grep -v grep | awk '{print$2}'`
	kill $pid
	echo "Killed exit"
	exit 0
fi

while ( true )
do
	for i in ${arr[*]}
	do
		count=`echo $i | wc -c`
		case "$count" in 
				"3")
			pre=444;;
				"4")
			pre=44;;
				"5")
			pre=4;;
				"6")
			pre="";;
		esac
		flag=`ssh $target "netstat -anp | grep sshd | grep LISTEN | grep 0.0.0.0:$pre$i"`
		[[ -z $flag ]] && flag=`ssh $target "netstat -anp | grep sshd | grep LISTEN | grep 0.0.0.0:$pre$i"`
		[[ -z $flag ]] && ssh -CfNgR $pre$i:127.0.0.1:$i root@$target 
	done
	printf %s"\n" "perform Success check next 100 secs"
	sleep 100
done
#end
