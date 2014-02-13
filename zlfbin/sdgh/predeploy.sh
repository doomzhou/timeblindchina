#!/bin/bash 
#First by doom 29 may 2013 local
#Second by doom 30 may 2013 local
#set variable {{{1
doompre=/tmp/deploytmp/doompre
remote=123.103.103.83
appcode=$1
workdir="/web/eln4share/test/new"
overridef="/web/eln4share/test/new/overridepre"
if [[ ! -d $doompre ]];then mkdir $doompre ;fi

#Judge sf-server{{{1
if [[ "$1" = "sf-web" ]]; then args1="sf-server";fi;
#add change none "web"'s app to "web"{{{2
if [[ ! -z `echo $1 | awk /-web/` ]]; then
    if [[ -z $args1 ]]; then    # judge sf-web
        appcode=`echo $1 | sed 's/-web//g'`
    fi  
else 
    appcode=$1 
fi
tmp=$doompre/$appcode

#wget maven tarball{{{1
#get three parameter{{{2
g=`awk -F "\"" /\"$appcode\"/'{printf("%s"),$4}' $workdir/projects.xml`
a=`awk -F "\"" /\"$appcode\"/'{printf("%s"),$2}' $workdir/projects.xml`
v=`awk -F "\"" /\"$appcode\"/'{printf("%s"),$6}' $workdir/projects.xml`

nexusurl="http://192.168.0.211:8080/nexus/service/local/artifact/maven/redirect?r=snapshots&g=$g&a=$a&v=$v&e=war"
rm -rf $tmp; mkdir -p $tmp ; cd $tmp
wget $nexusurl 1>$doompre/log.log 2>&1; if [[ ! $? -eq 0 ]];then echo -e "\033[32;1merror app!! exit 2\033[0m"; exit 2 ;fi
jar xf $a*war
/bin/cp $overridef/* $tmp/WEB-INF/classes/ && echo -e "\033[32;1moverride okay\033[0m"
rm -f $a*war

#get compare files{{{1
cd $tmp && find * -maxdepth 0 -type d > $doompre/1.dt
cd $tmp && find * -type f | xargs md5sum > $doompre/1.ft  
#Judge svc or web{{{2
if [[ $appcode =~ [a-z].*svc$ ]]
then
	ssh $remote "cd /web/eln4share/svc/$appcode && find * -maxdepth 0 -type d" > $doompre/2.dt
	ssh $remote "cd /web/eln4share/svc/$appcode && find * -type f | xargs md5sum" > $doompre/2.ft
else
	ssh $remote "cd /web/eln4share/$appcode && find * -maxdepth 0 -type d" > $doompre/2.dt
	ssh $remote "cd /web/eln4share/$appcode && find * -type f | xargs md5sum" > $doompre/2.ft
fi

dir_dif_str=(`cd $doompre && cat 1.dt 2.dt | sort | uniq -u`)
file_dif_str=(`cd $doompre && cat 1.ft 2.ft | awk '{print$2}' | sort | uniq -u`)
tar_str=(`cat $doompre/1.ft $doompre/2.ft | sort | uniq -u | awk '{print$2}' |sort|uniq`)

#dir_del_str{{{2
cd $doompre
#echo ${dir_dif_str[@]}
len=${#dir_dif_str[*]}
for ((i=0;i<$len;i++))
do
	if [[ ! -z `grep ${dir_dif_str[i]} 2.dt` ]]
	then
		dir_target_str=$dir_target_str\ ${dir_dif_str[i]}
	fi
done
if [[ -z $dir_target_str ]] ;then echo NULL ;else echo -e "delete folder \033[31m$dir_target_str \033[0m";fi;

#file_del_str{{{2
#echo ${file_dif_str[@]}
flen=${#file_dif_str[*]}
for ((i=0;i<$flen;i++))
do
	if [[ ! -z `grep ${file_dif_str[i]} 2.ft` ]]
	then
		file_target_str=$file_target_str\ ${file_dif_str[i]}
	fi
done
if [[ -z $file_target_str ]] ;then echo NULL ;else echo -e "delete file \033[31m$file_target_str \033[0m";fi;

#file_diff_str{{{2
tarlen=${#tar_str[*]}
cd $doompre
rm -f transfer.tgz
for ((i=0;i<$tarlen;i++))
do
	if [[ -f $tmp/${tar_str[i]} ]]
	then
		tar -C $doompre/ -rvf transfer.tgz $appcode/${tar_str[i]} 1>>log.log 2>&1
	fi
done
#override file
echo "override 3 file"
tar -C $doompre/ -rvf transfer.tgz $appcode/WEB-INF/classes/c3p0-config.xml 1>>log.log 2>&1
tar -C $doompre/ -rvf transfer.tgz $appcode/WEB-INF/classes/env.properties 1>>log.log 2>&1
tar -C $doompre/ -rvf transfer.tgz $appcode/WEB-INF/classes/log4j.properties 1>>log.log 2>&1
if [[ $? != 0 ]];then exit 2 ;fi
#transport gz to pre{{{1
scp transfer.tgz $remote:/tmp 
#tar file to target{{{1
if [[ $appcode =~ [a-z].*svc$ ]]
then
	ssh $remote "tar xvf /tmp/transfer.tgz -C /tmp/svc/" && echo tar file to  1>>log.log 2>&1 
else
	ssh $remote "tar xvf /tmp/transfer.tgz -C /tmp/" && echo tar file to  1>>log.log 2>&1 
fi
#LAST DONE!{{{1
rm -f $doompre/*.[df]t && echo $doompre "delete complete" 1>>log.log 2>&1
rm -rf $tmp && echo $tmp "delete complete" 1>>log.log 2>&1
echo -e "\033[32;1mDEPLOY COMPLETE\033[0m"
