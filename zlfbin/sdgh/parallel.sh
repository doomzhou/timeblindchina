#!/bin/bash
#first release by doom 12 may 2013
PATH=$PATH:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin:/web/zlfsoft:/web/zlfbin:/web/eln4share/test/new
export PATH

tmp_fifofile="/tmp/$.fifo"
mkfifo $tmp_fifofile      # 新建一个fifo类型的文件
exec 6<>$tmp_fifofile      # 将fd6指向fifo类型
rm $tmp_fifofile

echo -ne "\033[41;33;1mHost period (Default: 192.168.0) \033[0m"
if [[ -z $hostperiod ]];then hostperiod="192.168.0";fi
filenametime=`date -d "+0 day" "+%m-%d-%H-%M"`

thread=15 # 此处定义线程数
for ((i=0;i<$thread;i++));do 
echo
done >&6 # 事实上就是在fd6中放置了$thread个回车符


for ((i=1;i<=254;i++));do # 50次循环，可以理解为50个主机，或其他

read -u6 
# 一个read -u6命令执行一次，就从fd6中减去一个回车符，然后向下执行，
# fd6中没有回车符的时候，就停在这了，从而实现了线程数量控制

{ # 此处子进程开始执行，被放到后台
	  ping -c 1 -W 1 $hostperiod.$i > /dev/null && echo "$hostperiod.$i is alive"  >> ./shtemp/hostperiod$filenametime.t 
      echo >&6 # 当进程结束以后，再向fd6中加上一个回车符，即补上了read -u6减去的那个
} &
if [[ $hostperiod == "192.168.0" ]] && [[ $i == 254 ]];then i=1;hostperiod="192.168.1";fi

done

wait # 等待所有的后台子进程结束
exec 6>&- # 关闭df6


exit 0
