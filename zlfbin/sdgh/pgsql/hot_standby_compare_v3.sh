#!/bin/bash 
#second release by doom 08 may 2013
#third release by doom 08 may 2013 for each database fro parallel

#set some variable
#if [[ ! -z $1 ]] ;then main_port=$1;else echo "input port";exit 2; fi
bak_port=65432
main_port=64321
main_host=192.168.0.216;bak_host='null'
dbpass="postgres"


#generate .pgpass file
echo $main_host:$main_port:$dbname:postgres:$dbpass > ~/.pgpass && chmod 600 ~/.pgpass

check ()
	{
	tmp_fifofile="/tmp/$.fifo"
	mkfifo $tmp_fifofile      # 新建一个fifo类型的文件
	exec 6<>$tmp_fifofile      # 将fd6指向fifo类型
	rm $tmp_fifofile
	thread=15 # 此处定义线程数
	for ((i=0;i<$thread;i++));do 
	echo
	done >&6 # 事实上就是在fd6中放置了$thread个回车符
	#just cycle dbname
	dbname=$1
	echo $main_host:$main_port:$dbname:postgres:$dbpass > ~/.pgpass && chmod 600 ~/.pgpass

	bak_table_list=`psql -p $bak_port -d $dbname -c "select table_name from information_schema.tables where table_schema = 'public' order by table_name;"` 
	main_table_list=`psql -h $main_host -p $main_port -d $dbname -c "select table_name from information_schema.tables where table_schema = 'public' order by table_name;"` 
	echo $bak_table_list > bak.t ; echo $main_table_list > main.t
	
	if [[ $bak_table_list == $main_table_list ]]
	then
		echo -e "\033[32;1mtable_list is match\033[0m";
		sed -i -e 's/(.*)//g' -e 's/^.*-[ ]//g' bak.t
		len=`cat bak.t | grep -o ' ' | wc -l`
		for ((i=1;i<=$len;i++))
		do
		read -u6	
		{
			tempcommand=`awk -v t=$i 'END{print"select count(0) from "$t";"}' bak.t`
			bak_count=`psql -p $bak_port -d $dbname -c "$tempcommand"`
			main_count=`psql -h $main_host -p $main_port -d $dbname -c "$tempcommand"`
			if [[ $bak_count != $main_count ]]		
			then
				echo $tempcommand |  awk '{printf$4}'; echo -e "\033[31;1mDismatch\033[0m" 
				echo $tempcommand
			fi
			echo  >&6
		} &
		done
	else
		echo -e "\033[41;33;1mtable_list is Dismatch\033[0m" && exit 2;
	fi
	wait # 等待所有的后台子进程结束
	exec 6>&- # 关闭df6
	}

echo `psql -p $main_port -c 'select datname from pg_database;'` > dblist.t
if [[ ! -f dblist.t ]];then echo error port ;exit 2 ;fi
sed -i -e 's/(.*)//g' -e 's/^.*template0[ ]//g' dblist.t
dblen=`cat dblist.t | grep -o ' ' | wc -l`
for ((j=1;j<=$dblen;j++))
do
	dbfetch=`awk -v t=$j 'END{print$t}' dblist.t`
	echo -en "\033[34;1m$dbfetch\n\033[0m"
	check $dbfetch
done

#delete pgpass security file
rm -rf ~/.pgpass dblist.t && echo -e "\033[33;1mdelete .pgpass complete!\033[0m"
rm -rf bak.t main.t && echo -e "\033[33;1mdelete tempory file complete!\033[0m"
