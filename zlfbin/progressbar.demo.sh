#!/bin/bash
# File Name : progressbar.demo.sh
# Purpose :
# Creation Date : 12-12-2013
# Last Modified : Thu 12 Dec 2013 03:49:14 PM CST
# Release By : Doom.zhou

#set variables

C="0" # count
while [ $C -lt 20 ]
do
    case "$(($C % 4))" in
        0) char="/"
        ;;
        1) char="-"
        ;;
        2) char="\\"
        ;;
        3) char="|"
        ;;
    esac

    sleep .2
    echo -ne $char "\r"
    C=$[$C+1]
done
echo -e 'done\r'
#end

####################################################################################################
echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'

####################################################################################################
trap 'kill $BG_PID;echo;exit' 1 2 3 15
function dots
{
stty -echo >/dev/null 2>&1
while true
do
  echo -e ".\c"
  sleep 1
done
stty echo
echo
}

dots &
BG_PID=$!
sleep 10
kill $BG_PID



echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#############             (66%)\r'
sleep 1
echo -ne '#######################   (100%)\r'
echo -ne '\n'
