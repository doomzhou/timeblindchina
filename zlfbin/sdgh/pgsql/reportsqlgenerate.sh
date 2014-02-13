#!/bin/bash
#First release by doom 13-May-2013 | 2nd by doom 22-May | 3rd by doom 27-May
#shell name tbc.sh
#env
PATH=/db/jdk1.6.0_22/bin:/bin:/usr/local/snmp/sbin:/usr/local/snmp/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/lib64/ccache:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/opt/pgsql/bin:/usr/local/net-snmp/bin:/opt/pgsql/bin:/usr/local/net-snmp/bin:/root/bin:/web/zlfsoft:/web/zlfbin:/root/bin:
export PATH

#set variable
if [[ $1 == "" ]] || [[ $2 == "" ]];then echo -e "\033[32;1mUsage\033[0m : $0 Startyear Corpcode"; exit 2;fi
if [[ ! $1 =~ ^[1-9][0-9]{3}-(0[1-9]|1[0-2]|[1-9])-([1-9]|0[1-9]|[1-2][0-9]|3[0-1])$ ]];then echo "NOT A YYYY-mm-dd!" && exit 2;fi
syear=`echo $1 | awk -F - '{print$1}'`;
smonth=`echo $1 | awk -F - '{print$2}'`;
sday=`echo $1 | awk -F - '{print$3}'`;
year=`date "+%Y"`; month=`date "+%_m"`; day=`date -d "1 day ago" "+%_d"`

if [[ $syear == $year ]];then
	for ((j=$smonth;j<=$month;j++))
	do
		if [[ $j == $smonth ]];then
			d=`cal $j $year |xargs |awk '{print $NF}'`
			echo -e "SELECT study_report_range_caller('$2','$year-$j-$sday','$year-$j-$d');" >> /root/$2.sql
		elif [[ $j == `echo $month | sed 's/ //g'` ]];then	
			echo -e "SELECT study_report_range_caller('$2','$year-$j-01','$year-$j-$day');" >> /root/$2.sql
		else
			d=`cal $j $year |xargs |awk '{print $NF}'`
			echo -e "SELECT study_report_range_caller('$2','$year-$j-01','$year-$j-$d');" >> /root/$2.sql
		fi
	done
	exit 2;
fi
for (( i=$syear;i<=$year;i++ ))
do
	if [[ $i == $year ]];then
		for (( j=1;j<=$month ;j++ ))
			do
				if [[ $j == `echo $month | sed 's/ //g'` ]];then	
					echo -e "SELECT study_report_range_caller('$2','$i-$j-01','$i-$j-$day');" >> /root/$2.sql
				else
					d=`cal $j $i |xargs |awk '{print $NF}'`
					echo -e "SELECT study_report_range_caller('$2','$i-$j-01','$i-$j-$d');" >> /root/$2.sql
				fi
			done
	elif [[ $i == $syear ]];then
		for (( j=$smonth;j<=12 ;j++ ))
			do
				if [[ $j == $smonth ]];then
					d=`cal $j $i |xargs |awk '{print $NF}'`
					echo -e "SELECT study_report_range_caller('$2','$i-$j-$sday','$i-$j-$d');" >> /root/$2.sql
				else
					d=`cal $j $i |xargs |awk '{print $NF}'`
					echo -e "SELECT study_report_range_caller('$2','$i-$j-01','$i-$j-$d');" >> /root/$2.sql
				fi
			done
	else
		for (( j=1;j<=12 ;j++ ))
			do
				d=`cal $j $i |xargs |awk '{print $NF}'`
				echo -e "SELECT study_report_range_caller('$2','$i-$j-01','$i-$j-$d');" >> /root/$2.sql
			done
	fi
done
