#!/bin/bash
usage()
{
cat << EOF
usage: $0 -t <0|1|2|3|4>

This script run the test1 or test2 over a machine.

OPTIONS:
   -t <0|1|2|3|4>  Switch to mode 0,1,2,3 or 4
   -h                Show this message
EOF
}

Current_time=`date +%Y-%m-%dT%H:%M:%S`

TYPE=
while getopts “ht:r:p:v” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         t)
             TYPE=$OPTARG
             ;;
         ?)
             usage
             exit
             ;;
     esac
done

if [[ -z $TYPE ]] || [[ $TYPE -lt 0 ]] || [[ $TYPE -gt 4 ]]
then
    usage
    exit 1
fi
CMD="/usr/local/bin/vclient -h 127.0.0.1:3002 -c 'setBetriebsartTo"$TYPE"'"
# curl -s -X PUT -H "Content-Type: text/plain" -d $TYPE "http://192.168.1.20:8080/rest/items/Vies_Tryb_Pracy_num/state"

eval $CMD

