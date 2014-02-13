#!/bin/bash
# File Name : reindexconcurrently.sh
# Purpose : Reindex concurrently
# Creation Date : 18-12-2013
# Last Modified : Wed 18 Dec 2013 04:41:07 PM CST
# Release By : Doom.zhou

#Help&Usage
if [[ -z $1 ]] || [[ $1 == "help" ]];then #{{{
    echo -e "\033[31;1mDDL/DML/DCL/TCL manager\033[32;1m(1th version)\033[0m"
    echo -e "\033[31;1m--------------------------------------------------------\033[0m"
    awk -v t=$0 'BEGIN{
		printf "%-8s%-15s%-15s\n"," Usage: ", t ,""
       	}'
exit 
fi #}}}

#set variables
export PATH=$HOME/bin:$PATH

#main
 
dbhost=192.168.0.214
database=haier
dbport=5432
schema=public
dbschema=/tmp/dbschema.txt
filtered=/tmp/dbschema_filtered.txt
sql=/tmp/rebuild_indexes.sql
 
rm "$dbschema"; rm "$filtered"; rm "$sql"
 
pg_dump -U postgres -s -h "$dbhost" -p $dbport -n $schema  "$database" > "$dbschema"
 
grep -e CREATE\ INDEX -e SET\ search_path "$dbschema" | sed 's/CREATE\ INDEX/CREATE\ INDEX\ CONCURRENTLY/g' > "$filtered"

while read p
do
  if [[ "$p" == SET* ]]; then
    echo $p >> "$sql"
  else
  {
    name=$(cut -d\  -f4 <<<"${p}")
    drop="DROP INDEX $name;"
    echo $drop >> "$sql"
    echo $p >> "$sql"
  fi
done < "$filtered"

#psql -U postgres -h "$dbhost" -p $dbport -d "$database" -f "$sql"
 
#rm "$dbschema"
#rm "$filtered"
#rm "$sql"
 
 

#end
