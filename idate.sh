#!/bin/sh
# Command-line world clock
# Taken from  http://stackoverflow.com/questions/370075/command-line-world-clock

# .worldclock.zones file looks like:
# US/Pacific
# Europe/Berlin
# Chile/Continental

: ${WORLDCLOCK_ZONES:=$HOME/.worldclock.zones}
: ${WORLDCLOCK_FORMAT:='+%a %d %b %Y %H:%M:%S %Z'}
#Thu  4 Aug 2016 17:33:05 EDT
#: ${WORLDCLOCK_FORMAT:='+%Y-%m-%d %H:%M:%S %Z'}

#while true
#do
    #clear
    while read zone displayname
    do 
    echo $displayname '!' $(TZ=$zone date "$WORLDCLOCK_FORMAT")
    done < $WORLDCLOCK_ZONES |
    awk -F '!' '{ printf "%-13s  %s\n", $1, $2;}'
    #echo $zone '!' $(TZ=$zone date "$WORLDCLOCK_FORMAT") < $WORLDCLOCK_ZONES |
    #awk -F '!' '{ printf "%-20s  %s\n", $1, $2;}'
    
    #sleep 1
#done