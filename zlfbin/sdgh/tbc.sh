#!/bin/bash
#First release by doom 13-May-2013 | 2nd by doom 22-May | 3rd by doom 27-May | 4th by doom add remote env
#shell name tbc.sh
#env
PATH=/db/jdk1.6.0_22/bin:/bin:/usr/local/snmp/sbin:/usr/local/snmp/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/lib64/ccache:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/pgsql/bin:/usr/local/net-snmp/bin:/opt/pgsql/bin:/usr/local/net-snmp/bin:/root/bin:/web/zlfsoft:/web/zlfbin:/root/bin:
export PATH
. /etc/profile



#set variable
Tom="/web/service/"
Tomrestart="bin/shutdown.sh &&rm -f logs/* && bin/startup.sh"
Tomstart="bin/startup.sh"
Tomshutdown="bin/shutdown.sh"

#awk print --help
if [[ -z $1 ]] || [[ -z $2 ]];then
	echo -e "\033[31;1mAll exec collect to this shell\033[32;1m(third version)\033[0m"
	echo -e "\033[31;1m--------------------------------------------------------\033[0m"
	awk 'BEGIN{
		printf "%-8s%-15s%-15s%-15s\n"," Usage: ","      $1       ","      $2       ","      $3       "
		printf "%-8s%-15s%-15s%-15s\n","        ","               "," ___________   ","               "
		printf "%-8s%-15s%-15s%-15s\n","        "," ________      ","|start/2    |  ","               "
		printf "%-8s%-15s%-15s%-15s\n","        ","|choose/1|*    ","|restart/1  |  ","               "
		printf "%-8s%-15s%-15s%-15s\n","        ","|regexp/2|**   ","|shutdown/3 |  ","    _          "
		printf "%-8s%-15s%-15s%-15s\n","        "," ˉˉˉˉˉˉˉˉ   ** ","|logcheck/4*|**","***|y|         "
		printf "%-8s%-15s%-15s%-15s\n","        ","             * ","|logbak/5   |  ","    ˉ          "
		printf "%-8s%-15s%-15s%-15s\n","        ","               ","|logtrack/6 |  ","               "
		printf "%-8s%-15s%-15s%-15s\n","        ","               "," ˉˉˉˉˉˉˉˉˉˉˉ   ","               "
		printf "%-8s%-15s%-15s%-15s\n","        "," ___________   "," _______       ","               "
		printf "%-8s%-15s%-15s%-15s\n","        ","|xmpdeploy/3|**","|backup |      ","               "
		printf "%-8s%-15s%-15s%-15s\n","        "," ˉˉˉˉˉˉˉˉˉˉˉ   ","|restore|      ","               "
		printf "%-8s%-15s%-15s%-15s\n","        ","               "," ˉˉˉˉˉˉˉ       ","               "
		printf "%-8s%-15s%-15s%-15s\n","        "," _______       "," _______       ","               "
		printf "%-8s%-15s%-15s%-15s\n","        ","|rsync/4|    **","|all    |      ","               "
		printf "%-8s%-15s%-15s%-15s\n","        "," ˉˉˉˉˉˉˉ       ","|allcode|      ","               "
		printf "%-8s%-15s%-15s%-15s\n","        ","               "," ˉˉˉˉˉˉˉ       ","               "
		}'
	exit 2
fi

#mkdir tbctemp
if [[ ! -d ~/tbctemp ]];then mkdir -v ~/tbctemp;fi;

#choose target tomcat xmldeploy 
case "$1" in
	#"all" | "1") #all /web/service/tomcats
	#	arrall=(`find $Tom -maxdepth 1 -type d | grep tomcat`)
	#	len=${#arrall[*]}
	#	for ((i=0;i<$len;i++))
	#	do
	#		echo -en "\033[32;1m $i \033[33;1m ${arrall[$i]}\n\033[0m"
	#	done
	#	arrtarget=("${arrall[@]}")
	#	;;
	"choose" | "1") #displaytochoose
		arrall=(`find $Tom -maxdepth 1 -type d | grep tomcat`)
		len=${#arrall[*]}
		for ((i=0;i<$len;i++))
		do
			echo -en "\033[32;1m $i \033[33;1m ${arrall[$i]}\n\033[0m"
		done
		#collect the tomcats 
		#User custom input 
		echo -en "Input your operation tomcat item\033[33;1m(e.g.:2,3)\033[0m " 
		read item
		#Judge the item 
		if [[ "$item" =~ ^([0-9]{1,2},)*[0-9]{1,2}$ ]];
		then
			 if [[ ! -z `echo $item | awk -v t=$len 'BEGIN{RS=","}{if ($0>=t) print $0}'` ]];then echo -e "\033[31;1mDOES ITEM GREAT THAN TOMCAT INDEX NUM!\033[0m" && exit 2;fi
		else
			 echo -e "\033[31;1mINPUT ITEM ERROR\033[0m" && exit 2 
		fi
		#generate new array
		arrtmp=(`echo $item | tr , " "`)
		lentmp=${#arrtmp[*]}
		for (( i=0;i<$lentmp;i++))
		do
			arrtarget[$i]=${arrall[${arrtmp[$i]}]}
		done
		
		len1=${#arrtarget[*]}
		for ((i=0;i<$len1;i++))
		do
			echo -en "\033[32;1m $i \033[33;1m ${arrtarget[$i]}\n\033[0m"
		done
		;;
	"regexp" | "2") #regular expression
		echo -ne "\033[33;1mJust input simple regexp:   \033[0m"
		read regexp
		if [[ -z $regexp ]]; then echo "No regular expression";exit;fi
		arrtarget=(`find $Tom -maxdepth 1 -type d | grep tomcat | grep -P $regexp`)
		len=${#arrtarget[*]}
		for ((i=0;i<$len;i++))
		do
			echo -en "\033[32;1m $i \033[33;1m ${arrtarget[$i]}\n\033[0m"
		done
		;;
	"xmldeploy" | "3") #xml deploy

		if [[ "$2" != "backup" ]] && [[ "$2" != "restore" ]];then echo -e "Please figure out your purpose to xml! \033[31;1mbackup or restore?\033[0m"; exit 2;fi; 
		arrtarget=(`find $Tom -maxdepth 1 -type d | grep tomcat`)
		lentarget=${#arrtarget[*]}
		bakfilename=~/tbctemp/xml.bakpoint
		if [[ "$2" == "backup" ]];then
			if [[ -f $bakfilename ]];then echo -e "backup point already exist please rename \033[31;1m$bakfilename \033[0mthen backup again";exit 2;fi
			touch $bakfilename
			for ((i=0;i<$lentarget;i++))
			do
				arrxml=`ls ${arrtarget[$i]}/conf/Catalina/localhost/ | grep -v manager | grep -P "\.xml$"`
				echo -n ${arrtarget[$i]}/conf/Catalina/localhost" " >> $bakfilename
				echo $arrxml >> $bakfilename
			done
			sed -i 's/\([a-zA-]*\).xml/\1/g' $bakfilename
			echo "Backup complete!"
		else
			if [[ ! -f $bakfilename ]];then echo "No backup point ,so .... exit 130";exit 130;fi
			echo -en "\033[31;1menvironment:test2 or test3 or pre or maj\033[0m";read env
			if [[ $env == "test2" ]];then envdir="/test2";elif [[ $env == "test3" ]];then envdir="/test3";else envdir="";fi
			#awk read from back write to xml
			awk -v t=$envdir '{   
    				for (k=2;k<=NF;k++)
    				{   
    				    if ($k ~ /svc/)
    				        printf("<Context path=\42/%s\42 docBase=\42/web/eln4share%s/svc/%s\42 >\n</Context>",$k,t,$k)> $1"/"$k".xml"
    				    else
    				        printf("<Context path=\42/%s\42 docBase=\42/web/eln4share%s/%s\42 >\n</Context>",$k,t,$k)> $1"/"$k".xml"
					}
    			}'  $bakfilename 
		fi
		;;
	"rsync" | "4") #rsync
		if [[ $2 == "all" ]];then	
			rsync -av --delete /eln4/eln4share/* /web/eln4share/
		else
			rsync -av --delete /eln4/eln4share/$2 /web/eln4share/
			rsync -av --delete /eln4/eln4share/svc/$2-svc /web/eln4share/svc
		fi
		;;
esac

#behavior to tomcat
case "$2" in
	"start" | "2")#start
		lentarget=${#arrtarget[*]}
		echo -n "these tomcat okay? y/n " 
		read inter1; if [[ $inter1 == "y" ]]; then echo -e "\033[44;32;1mgogogo......\033[0m"; else echo -e "\033[44;32;1mSir interrupt......\033[0m";exit 2;fi
		for ((i=0;i<$lentarget;i++))
		do
			rm -f ${arrtarget[$i]}/logs/*
			rm -f ${arrtarget[$i]}/log/*
			cd ${arrtarget[$i]}
			${arrtarget[$i]}/$Tomstart
		done
		;;
	"shutdown" | "3")#shutdown
		lentarget=${#arrtarget[*]}
		echo -n "these tomcat okay? y/n " 
		read inter1; if [[ $inter1 == "y" ]]; then echo -e "\033[44;32;1mgogogo......\033[0m"; else echo -e "\033[44;32;1mSir interrupt......\033[0m";exit 2;fi
		for ((i=0;i<$lentarget;i++))
		do
			${arrtarget[$i]}/$Tomshutdown
		done
		;;
	"restart" | "1")#restart
		lentarget=${#arrtarget[*]}
		echo -n "these tomcat okay? y/n " 
		read inter1; if [[ $inter1 == "y" ]]; then echo -e "\033[44;32;1mgogogo......\033[0m"; else echo -e "\033[44;32;1mSir interrupt......\033[0m";exit 2;fi
		for ((i=0;i<$lentarget;i++))
		do
			${arrtarget[$i]}/$Tomshutdown
			rm -f ${arrtarget[$i]}/logs/*
			rm -f ${arrtarget[$i]}/log/*
			cd ${arrtarget[$i]}
			${arrtarget[$i]}/$Tomstart
		done
		;;
	"logcheck" | "4")#logcheck
		lentarget=${#arrtarget[*]}
		echo -n "these tomcat okay? y/n " 
		if [[ $3 == "y" ]];then inter1="y";else read inter1;fi;
	    if [[ $inter1 == "y" ]]; then echo -e "\033[44;32;1mgogogo......\033[0m"; else echo -e "\033[44;32;1mSir interrupt......\033[0m";exit 2;fi
		for ((i=0;i<$lentarget;i++))
		do
			echo `echo ${arrtarget[$i]} | awk -F _ '{printf("%s-%s "),$2,$3}'`
			sed -n -e '/Server startup/p' -e '/startup failed due to previous/p' "${arrtarget[$i]}/logs/catalina.out"
		done
		;;
	"logbak" | "5")#logbak
		lentarget=${#arrtarget[*]}
		echo -n "these tomcat okay? y/n " 
		read inter1; if [[ $inter1 == "y" ]]; then echo -e "\033[44;32;1mgogogo......\033[0m"; else echo -e "\033[44;32;1mSir interrupt......\033[0m";exit 2;fi
		timepoint=`date -d "+0 day" "+%s"`
		for ((i=0;i<$lentarget;i++))
		do
			/bin/cp ${arrtarget[$i]}/logs/catalina.out ~/tbctemp/`echo ${arrtarget[$i]} | awk -F _ '{print $2"_"$3"catalina.out"}'`
			/bin/cp ${arrtarget[$i]}/logs/gc.log ~/tbctemp/`echo ${arrtarget[$i]} | awk -F _ '{print $2"_"$3"gc.log"}'`
		done
		;;
	"logtrack" | "6")#logtrack
		#set trap
		#trap "ps -ef | grep -v grep | grep tomcat6_os | grep tail | awk '{print$2}' | xargs kill -quit" 2
		trap "echo done" 2
		lentarget=${#arrtarget[*]}
		echo -n "these tomcat okay? y/n " 
		read inter1; if [[ $inter1 == "y" ]]; then echo -e "\033[44;32;1mgogogo......\033[0m"; else echo -e "\033[44;32;1mSir interrupt......\033[0m";exit 2;fi
		for ((i=0;i<$lentarget;i++))
		do
			echo -e "\033[35;1m ${arrtarget[$i]}     \033[0m logtarck"
			tail -f ${arrtarget[$i]}/logs/catalina.out
		done
		;;
esac

