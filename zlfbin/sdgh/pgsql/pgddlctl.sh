#!/bin/bash
# File Name : pgddlctl.sh
# Purpose : Control psql all tables's DDL
# Creation Date : 17-12-2013
# Last Modified : Wed 25 Dec 2013 02:45:34 PM CST
# Release By : Doom.zhou

#Help&Usage
if [[ -z $1 ]] || [[ $1 == "help" ]];then #{{{
    echo -e "\033[31;1mControl psql all tables's or generate detail(1th version)\033[0m"
    echo -e "\033[31;1m--------------------------------------------------------\033[0m"
    awk -v t=$0 'BEGIN{
		printf "%-8s%-15s%-15s\n"," Usage: ", t ,""
		printf "%-8s%-15s%-15s\n","", t,"all #show all tables "
		printf "%-8s%-15s%-15s\n","", t,"dirty #show dirty tables "
       	}'
exit 
fi #}}}

#set variables
export PATH=$HOME/bin:$PATH
origins="192.168.0.214:5432:postgres"
target="default app12:5434:default \n
corp app14:15432:haier \n
corp app12:5432:septwolves \n
i app12:5432:signal \n
sc app12:6432:share_center \n
i app20:5433:signal \n
sc app20:6433:share_center \n
report app14:15432:haier \n"

#main
##generate all tables from 192.168.0.214:15432
originshost=`echo $origins | awk -F: '{print$1}'`
originsport=`echo $origins | awk -F: '{print$2}'`
originsdb=`echo $origins | awk -F: '{print$3}'`
tables=$(psql -U postgres -h $originshost -p $originsport $originsdb -c "select table_name from information_schema.tables where table_schema='public';" | sed -n '3,$p') #fetch all table name include rows 
tablecount=`echo $tables |sed -nr 's/.*\(([0-9]* ).*/\1/gp'`
arr=($tables) 

function all () #{{{
{
	for (( i =0 ;i<$tablecount ;i++ ))
	do
		if [ $1 == "all" ];then
			printf "doom-"%d"->"%s"\n" $i ${arr[$i]} #print all tables
		elif [ $1 == "dirty" ];then
			if [[ ! ${arr[$i]} =~ ^t_[a-z]+_[a-z]+ ]];then printf "doom-"%d"->"%s"\n" $i ${arr[$i]} ;fi #print t_xxxx tables
		fi
	done
} #}}}


function compare () #{{{
{
	#generate source tempalte by orgins
	for (( i=0 ;i<$tablecount;i++ ))
	do
            S[$i]=`psql -U postgres -h $originshost -p $originsport $originsdb -c "\d ${arr[$i]}" | sed 's/timestamp(6)/timestamp/g' | sed 's/ //g' | sed '3d' | sed -n '1,/Triggers:/p' | sed '/Triggers:/d'`
	done
	echo  -e 'generate Success!\n\n\n\n'

	target=app12:5432:septwolves

	
	echo  -e "Suppose target is $target OK(y/n)?";read ctl
	[ $ctl == 'y' ] && echo  yes || exit 2
	host=`echo $target | awk -F: '{print$1}'`
	port=`echo $target | awk -F: '{print$2}'`
	db=`echo $target | awk -F: '{print$3}'`
	if [[ $db == "single" ]]
	then
		for (( j=0;j<$i;j++ )) #{{{
		do
			if [[ ${arr[$j]} =~ ^t_[a-z]+_[a-z]+ ]]
			then
				#generate db info
				db=`echo ${arr[$j]} | awk -F _ '{print$2}'`
				dest=`psql -U postgres -h $host -p $port $db -c "\d ${arr[$j]}" 2>&1 | sed 's/timestamp(6)/timestamp/g' | sed 's/ //g' | sed '3d' | sed -n '1,/Triggers:/p' | sed '/Triggers:/d'`
				if [[ "$dest" =~ "FATAL:database" ]];then echo -e "\033[31;1m$db doesnnt exsit\033[0m"; continue;fi
				if [[ "$dest" =~ "Didnotfindanyrelation" ]]
				then
					echo -e "\033[32;1m"desttination don\'t have  ${arr[$j]} "\033[0m"
					echo -e "\033[32;2m--------------------------------------------------\033[0m"
				elif [[ $dest != ${S[$j]} ]]
				then
					echo -e "\033[33;1m"${arr[$j]} misMatch"\033[0m"
					[ -p /tmp/pipo ] && rm -f /tmp/pipo 
					mkfifo /tmp/pipo
					#diff <(echo "$dest") <(echo "${S[$i]}")
					diff - /tmp/pipo <<< "$dest" & echo "${S[$j]}" > /tmp/pipo
					rm -f /tmp/pipo
					echo -e "\033[32;2m--------------------------------------------------\033[0m"
				else
					echo ${arr[$j]} >> /tmp/result.t
				fi 
			else
				echo -e "\033[34;1m${arr[$j]} Dirty table please drop it\033[0m"
				echo -e "\033[32;2m--------------------------------------------------\033[0m"
			fi

		done #}}}
	else
		for (( j=0;j<$i;j++ )) #{{{
		do
			dest=`psql -U postgres -h $host -p $port $db -c "\d ${arr[$j]}" 2>&1 | sed 's/timestamp(6)/timestamp/g' | sed 's/ //g' | sed '3d' | sed -n '1,/Triggers:/p' | sed '/Triggers:/d'`
			#echo -e ${arr[$j]} " "
			#echo ${S[$j]}
			if [[ "$dest" =~ "Didnotfindanyrelation" ]]
			then
				echo -e "\033[33;1m"desttination don\'t have  ${arr[$j]} "\033[0m"
				echo -e "\033[32;2m--------------------------------------------------\033[0m"
			elif [[ $dest != ${S[$j]} ]]
			then
				echo -e "\033[31;1m"${arr[$j]} misMatch"\033[0m"
				[ -p /tmp/pipo ] && rm -f /tmp/pipo 
				mkfifo /tmp/pipo
				#diff <(echo "$dest") <(echo "${S[$i]}")
				diff - /tmp/pipo <<< "$dest" & echo "${S[$j]}" > /tmp/pipo
				rm -f /tmp/pipo
				echo -e "\033[32;2m--------------------------------------------------\033[0m"
			else
				echo ${arr[$j]} >> /tmp/result.t
			fi 

		done #}}}
	fi
} #}}}

case $1 in 
		"all")
			all all;;
		"dirty")
			all dirty;;
		"compare")
			compare;;
esac






#end


