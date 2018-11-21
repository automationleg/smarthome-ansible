#!/bin/bash

SCRIPT_PATH=`dirname "$0"`
v_logfiledir=/var/log/openhab2/viessmann

TIMESTAMP=`date +%Y-%m-%d\_%H_%M_%S`

logfile="$v_logfiledir/viessmann.log"

log()
{
          # print to std out if second argument
          if [ $2 = 1 ]; then
                        echo "$1"
          fi
          echo "[`date +%Y-%m-%d\ %H:%M:%S`] $1" >>$logfile
}

    RESULT=`/usr/bin/vclient -h 127.0.0.1:3002 -f $SCRIPT_PATH/heating.cmd -t $SCRIPT_PATH/heating.tpl 2>&1`

    CODE=${PIPESTATUS[0]}

    if [ "$CODE" -ne 0 ] || [ -z "$RESULT" ]; then
        
        curl -s -X PUT -H "Content-Type: text/plain" -d Failure "http://{{openhab_ip_addr}}:8080/rest/items/Heating_Common_Fault/state"
        #printf "STATUS: %s\nRESULT: %s" "$CODE" "$RESULT" > "$v_logfiledir/viessmann_error_$(date +"%d.%m.%Y_%H:%M:%S")"
        log "Error in collecting data from vclient\nSTATUS: $CODE , RESULTS: $RESULT" 1
        
        if [[ $(pidof vcontrold | wc -w) > 0 ]]; then

            curl -s -X PUT -H "Content-Type: text/plain" -d 990 "http://{{openhab_ip_addr}}:8080/rest/items/Heating_Common_Fault/state"
            log "Restarting vcontrold service" 0
            sudo /etc/init.d/vcontrol stop

            sudo /etc/init.d/vcontrol start

        sleep 10
       fi
    else
      #write success status if no failure
      curl -s -X PUT -H "Content-Type: text/plain" -d OK "http://{{openhab_ip_addr}}:8080/rest/items/Heating_Common_Fault/state"
      Current_time=`date +%Y-%m-%d %H:%M:%S`
      curl -s -X PUT -H "Content-Type: text/plain" -d $Current_time "http://{{openhab_ip_addr}}:8080/rest/items/Last_Correct_Data_Receive_Time/state"
    fi


hasError=0
while IFS='|' read -r item value status; do
    if [ -z "$value" ] || [ -z "$status" ] || [ "$status" != "OK" ]; then
	hasError=1
    else
	#echo $item
	curl -s -X PUT -H "Content-Type: text/plain" -d $value "http://{{openhab_ip_addr}}:8080/rest/items/"$item"/state"
    fi
done <<< "$RESULT"

if [ "$hasError" -eq 1 ]; then
     log "Error in some status update\nSTATUS: $CODE , RESULTS: $RESULT" 1
fi
