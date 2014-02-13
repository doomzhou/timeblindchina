#!/bin/bash 
#First release to solve ssh reload problem by doom.zhou 1july

/web/haproxy/sbin/haproxy -f /web/haproxy/sbin/haproxy.cfg -sf `cat /web/haproxy/haproxy.pid`

statu=$?

[[ $statu -eq 0 ]] && echo -e "\033[32;1mHaproxy reload sucessful\033[0m"
