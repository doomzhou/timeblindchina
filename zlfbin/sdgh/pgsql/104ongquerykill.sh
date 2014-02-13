#!/bin/bash 
#second release by doom 08 may 2013
#third release by doom 08 may 2013 for each database fro parallel

#set some variable
#if [[ ! -z $1 ]] ;then main_port=$1;else echo "input port";exit 2; fi
host=eln105
port=5432
dbpass="elnBjKojpostgres"

echo -e "\033[33;1mUsage:\033[0m: $0 host port time"

if [[ $1 == "" ]] || [[ $2 == "" ]] || [[ $3 == "" ]];then echo -e "generate 104's db longquery(five minuties)!";fi


#generate .pgpass file
echo $host:$port:postgres:postgres:$dbpass > ~/.pgpass && chmod 600 ~/.pgpass

psql -U postgres -h $host -p $port \
 	-c "SELECT procpid,current_query FROM pg_stat_activity where query_start < (now()-time'00:00:30') and current_query <> '<IDLE>' order by query_start;" \
	| awk '{for (i=1;i<=NF;i++) {if (($i ~ /^[0-9]/) && ($i ~ /[0-9]$/)) printf("SELECT pg_terminate_backend(%s); /*%s*/\n",$i,$0)}}' \
   	| tee /data/share/longquerykill.t


rm -rf ~/.pgpass && echo -e "\033[41;33;1mdelete .pgpass complete!\033[0m"
