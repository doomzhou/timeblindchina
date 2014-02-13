#!/bin/bash
#	File Name : 1.sh
#	Purpose :
#	Creation Date : 06-12-2013
#	Last Modified : Fri 06 Dec 2013 02:20:08 PM CST
#	Release By : Doom.zhou

#set variable
if [ $1 == "gen" ]
then
	arr=("a" `echo $[ $RANDOM % 9 + 1 ]` `echo $[ $RANDOM % 9 + 1 ]` `echo $[ $RANDOM % 9 + 1 ]` `echo $[ $RANDOM % 9 + 1 ]`)
else
	arr=("a" $1 $2 $3 $4);
fi
t=1;
str=null;

#function
function total () {
	for (( l=1;l<=4;l++ )) #{{{
	do
		for (( m=1;m<=4;m++ ))
			do
			if [[ $m -eq $l ]];then continue ;fi
				for (( n=1;n<=4;n++ ))
					do
					if [ $n -eq $m  -o $n -eq $l ];then continue ;fi
						for (( o=1;o<=4;o++ ))
							do
								if [ $o -eq $n -o $o -eq $m -o $o -eq $l ];then continue ;fi
								n1=${arr[$l]}; n2=${arr[$m]}; n3=${arr[$n]}; n4=${arr[$o]};
								for i in  + - \* / #{{{
								do
									t=`echo "$n1$i$n2" | bc`;str=$n1$i$n2;
									for j in  + - \* / 
									do
										t=`echo "$t$j$n3" | bc`;str=$str$j$n3;
										for k in  + - \* / 
										do
											f=`echo "$t$k$n4" | bc`;str=$str$k$n4;
											if [[ $f -eq 24 ]] 
											then
												if [[ $1 == "all" ]]
												then 
													echo -n
													echo -n $f"="; echo -e "\033[32;1m$n1$i$n2$j$n3$k$n4\033[0m";
												else
													echo  -e "\033[33;1m$n1 $n2 $n3 $n4\033[0m";
													echo -en "\033[33;1mAnswer type Enter!\033[0m"; read
													echo -n $f"="; echo -e "\033[32;1m$n1$i$n2$j$n3$k$n4\033[0m";
													break 7;
												fi
											fi
										done
									done
									t=1;str="";
								done
								#}}}

							done
					done
			done
	done
#}}}
}


#main 
total $2


#end
			#echo -e "\033[32;1m$i"苏"$j"珊"$k\033[0m";
