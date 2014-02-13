#!/bin/bash
# File Name : pg_manager.sh
# Purpose :
# Creation Date : 10-12-2013
# Last Modified : Tue 24 Dec 2013 08:28:54 AM CST
# Release By : Doom.zhou

#Help&Usage
if [[ -z $1 ]] || [[ $1 == "help" ]];then #{{{
    echo -e "\033[31;1mDDL/DML/DCL/TCL manager\033[32;1m(3th version)\033[0m"
    echo -e "\033[31;1m--------------------------------------------------------\033[0m"
    awk 'BEGIN{
		printf "%-8s%-15s%-15s\n"," Usage: ","target(default&corp)       "," file/command  "
		printf "%-8s%-15s%-15s\n"," Usage: ","target(default&corp)       "," DRYRUN  "
       	}'
exit 
fi #}}}


#set variables
export PATH=$HOME/bin/:$PATH
argu="("`echo $1 | tr , \|`")"
target="default app12:5434:default \n
corp app14:15432:haier \n
i app12:5432:signal \n
sharec app12:6432:share_center \n
i app20:5433:signal \n
sharec app20:6433:share_center \n
report app14:15432:haier \n"

#single database judge
single=`echo $1"," | sed -n 's/default\|sharec\|corp\|report\|,//gp'` #single database flag equal except /default\|sharec\|corp\|report
if [[ ! -z $single ]];
then
	temp=`echo -en $target | awk -v temp=$argu 'match($1, temp){print $2}'` 
	target=$temp" "`echo -en $target | awk '{if ($1 == "i")print$2}' | sed -n "s/signal/$single/gp"` # i means $target variables 
else
	target=`echo -en $target | awk -v temp=$argu 'match($1, temp){print $2}'` 
fi
#host & port visable 
targethp=($target);len=${#targethp[*]}    

for ((i=0;i<$len;i++))
do
        echo -en "\033[32;1m $i \033[33;1m ${targethp[$i]}\n\033[0m"
done
#User custom input 
echo -en "Confirm your operation PGSQL host&posrt\033[33;1m(y/n)\033[0m " 
read interrupt;if [[ $interrupt == "y" ]]; then echo -e "\033[44;32;1mgogogo......\033[0m"; else echo -e "\033[44;32;1mSir interrupt......\033[0m";exit 2;fi

for (( i=0;i<$len;i++ ))
do
	host=`echo ${targethp[$i]} | awk -F ":" '{print$1}'`
	port=`echo ${targethp[$i]} | awk -F ":" '{print$2}'`
	db=`echo ${targethp[$i]} | awk -F ":" '{print$3}'`
	psql -U postgres -h $host -p $port $db -c "select 1;"  > /dev/null 2>&1; 
	#if [[ $? -ne 0 ]];then echo -ne  "\033[33;1m${targethp[$i]} not visable\033[0m\n" && exit 2 ;else echo -ne  "\033[32;1m${targethp[$i]} visable\033[0m\n";fi
	if [[ $? -ne 0 ]];then echo -ne  "\033[33;1m${targethp[$i]} not visable\033[0m\n" && exit 2 ;fi;
done



#main #{{{
if [[ -z $2 ]] || [[ "$2" == "DRYRUN" ]];then command="select 1";else command=$2;fi
tmp_fifofile="/tmp/$.fifo"
mkfifo $tmp_fifofile      
exec 6<>$tmp_fifofile     
rm $tmp_fifofile
thread=5
for ((i=0;i<$thread;i++));do 
echo
done >&6 # 
	
for (( i=0;i<$len;i++ ))
do
read -u6 
{ 
	host=`echo ${targethp[$i]} | awk -F ":" '{print$1}'`
	port=`echo ${targethp[$i]} | awk -F ":" '{print$2}'`
	db=`echo ${targethp[$i]} | awk -F ":" '{print$3}'`
	if [[ -f $command ]]
	then
		psql -U postgres -h $host -p $port $db -f $command | tee -a /tmp/exec.log || (echo -e "\033[31;1mUnkonwn error maybe error command\033[0m" ; exit 2) | tee -a /tmp/exec.log && echo -e  "\033[32;1m$host-$port-$db\033[32;0m" | tee -a /tmp/exec.log 
	else
		psql -U postgres -h $host -p $port $db -c "$command;" | tee -a /tmp/exec.log  || (echo -e "\033[31;1mUnkonwn error maybe error command\033[0m" ; exit 2) | tee -a /tmp/exec.log && echo -e  "\033[32;1m$host-$port-$db\033[32;0m" | tee -a /tmp/exec.log 
	fi
	
	echo >&6 
} &
done
	
wait 
exec 6>&- # close f6
	
#end #}}}

echo
