#!/bin/ksh
# Sun Sep 25 20:32:00 
#5dec2021 UTC 2021;handyc
# handyc@sdf.org

######################################################################

installer_version="0.01"

######################################################################

username="$USER"
name_of_show=$username"_show"
user_id=$(id -u $username)
home_directory=$HOME
ANONRADIO=$HOME/anonradio
mpclocation="/usr/bin/mpc"
mpdlocation="/usr/bin/mpd"
bashlocation="/bin/bash"
sortlocation="/bin/sort"
soxlocation="/usr/bin/sox"
lamelocation="/usr/bin/lame"

######################################################################

scripts=$ANONRADIO"/scripts"
utils=$ANONRADIO"/utils"
headerwav="/tempheader.wav"
headertrack="/00000000header.mp3"

######################################################################

headerlengthminutes="10"
headerlengthseconds=$(echo "$headerlengthminutes * 60" | bc)

mpd_init_time_shift="-30"
update_time_shift="-24"
clearmpc_time_shift="-22"
updatempc_time_shift="-20"
addmpc_time_shift="-15"
showstart_time_shift="-"$headerlengthminutes
showend_time_shift="5"
mpd_halt_time_shift="10"

######################################################################

updateshow=$scripts"/updateshow"
clearmpc=$scripts"/clearmpc"
updatempc=$scripts"/updatempc"
addmpc=$scripts"/addmpc"
radioshow=$scripts"/radioshow"
haltradio=$scripts"/haltradio"
showlength=$scripts"/showlength"
weeklength=$scripts"/weeklength"
initializempd=$scripts"/initializempd"
haltmpd=$scripts"/haltmpd"
ncshow=$scripts"/ncshow"

######################################################################
## below variables will be changed by user input (where applicable)

dj_login="DJ_LOGIN"
dj_password="DJ_PASSWORD"

stream_type="shout"
stream_encoding="mp3"
stream_name="Title of your show"
stream_host="anonradio.net"
stream_port="8010"
stream_mount="/your_dj_mount"
stream_password="your password"
stream_bitrate="192"
stream_format="44100:16:1"
stream_protocol="icecast2"
stream_user="your username"
stream_description="A description of your stream"
stream_genre="Genre of your stream"
stream_public="no"
stream_timeout="100"
stream_url="STREAM_URL"

######################################################################
## mpd.conf variables
######################################################################

mpd_directory=$home_directory"/mpd"

mpd_music_directory=$home_directory"/mpd/music"
mpd_playlist_directory=$home_directory"/mpd/playlists"
mpd_db_file=$home_directory"/mpd/tag_cache"
mpd_log_file=$home_directory"/mpd/mpd.log"
mpd_pid_file=$home_directory"/mpd/pid"
mpd_state_file=$home_directory"/mpd/state"
mpd_sticker_file=$home_directory"/mpd/sticker.sql"
mpd_bind_to_address="127.0.0.1"
mpd_port=$user_id

######################################################################

Confirm(){
    echo -n $1"[Y/n]"
read  answer
case $answer in
    yes|Yes|YES|yEs|yES|yEs|yeS|YeS|y|"")
        #echo got a positive answer
        true
        ;;
    no|No|NO|nO|n)
        #echo got a 'no'
        false
        ;;
esac
}

Chkdir(){
## check for existence of mpd music directory
if [ ! -d $mpd_music_directory ]
then
echo "no mpd music dir, installing"
install -d -m u+rwx,go-rwx $mpd_music_directory
#then echo "no dir"
else
echo "mpd music directory already present"
chmod go-rwx $mpd_music_directory
fi

## check for existence of mpd music directory
if [ ! -d $mpd_playlist_directory ]
then
echo "no mpd playlist dir, installing"
install -d -m u+rwx,go-rwx $mpd_playlist_directory
#then echo "no dir"
else
echo "mpd playlist directory already present"
chmod go-rwx $mpd_playlist_directory
fi

## check for existence of anonradio directory
if [ ! -d $ANONRADIO ]
then
echo "no anonradio dir, installing"
install -d -m u+rwx,go-rwx $ANONRADIO
install -d -m u+rwx,go-rwx $utils
install -d -m u+rwx,go-rwx $scripts
#then echo "no dir"
else
echo "anonradio directory already present"
chmod go-rwx $ANONRADIO
fi

## GENERATE SCRIPT TO COPY FILES FOR NEXT SHOW TO MPD DIRECTORY
echo "#!"$bashlocation > $updateshow
echo "rm "$mpd_music_directory"/*.*" >> $updateshow
echo "cp "$utils$headertrack" "$mpd_music_directory$headertrack >> $updateshow
echo 'cp '$ANONRADIO'/$1/$(date --date="tomorrow" +%Y_%m_%d)/*.mp3 '$mpd_music_directory >> $updateshow
echo 'cp '$ANONRADIO'/$1/$(date --date="today" +%Y_%m_%d)/*.mp3 '$mpd_music_directory >> $updateshow

##

## GENERATE SCRIPT TO CLEAR MPD DATABASE LINKS
echo "#!"$bashlocation > $clearmpc
echo $mpclocation" -p "$user_id" clear" >> $clearmpc
##

## GENERATE SCRIPT TO UPDATE MPD DATABASE LINKS
echo "#!"$bashlocation > $updatempc
echo $mpclocation" -p "$user_id" update" >> $updatempc
##

## GENERATE SCRIPT TO ADD SONGS TO MPD PLAYLIST
echo "#!"$bashlocation > $addmpc
echo $mpclocation" -p "$user_id" ls | "$sortlocation" | "$mpclocation" -p "$user_id" add" >> $addmpc
##

## GENERATE SCRIPT TO START SHOW
echo "#!"$bashlocation > $radioshow
echo $mpclocation" -p "$user_id" play" >> $radioshow
##

## GENERATE SCRIPT TO STOP SHOW
echo "#!"$bashlocation > $haltradio
echo $mpclocation" -p "$user_id" stop" >> $haltradio
##

## GENERATE SCRIPT TO QUERY SHOW LENGTH FOR ANY GIVEN DAY
echo "#!"$bashlocation > $showlength
echo 'TOTLENGTH=0; for f in $1/$2/*.mp3; do LENGTH=$(ffmpeg -i "$f" 2>&1 |
grep "Duration"| cut -d' >> $showlength
echo -n "' ' -f 4 | sed s/,// | sed " >> $showlength
echo -n "'s@\..*@@g' | awk '{ split($1, A, " >> $showlength
echo -n '":"); split(A[3], B, "."); print 3600*A[1] + 60*A[2] + B[1] }' >> $showlength
echo -n "'); TOTLENGTH=$(($TOTLENGTH + $LENGTH)); done; echo " >> $showlength
echo -n '"total length=$TOTLENGTH, target length is 3600 (1 hour)";' >> $showlength
##

## GENERATE SCRIPT TO QUERY SHOW LENGTH FOR ONE WEEK
echo "#!"$bashlocation > $weeklength
echo "COUNTER=0" >> $weeklength
echo 'while [ "$COUNTER" -le 7 ]; do' >> $weeklength
echo 'echo $(date --date="$COUNTER day" +%Y_%m_%d)' >> $weeklength
echo $showlength' $1 $(date --date="$COUNTER day" +%Y_%m_%d)' >> $weeklength
echo "let COUNTER=COUNTER+1" >> $weeklength
echo 'echo " "' >> $weeklength
echo "done" >> $weeklength
##

## GENERATE SCRIPT TO START MPD
echo "#!"$bashlocation > $initializempd
echo -n $mpdlocation" $ANONRADIO/\$1/mpd.conf" >> $initializempd
##

## GENERATE SCRIPT TO STOP MPD
echo "#!"$bashlocation > $haltmpd
echo $mpdlocation" --kill" >> $haltmpd
##

## GENERATE SCRIPT TO CALL NCMPC SHOW MONITOR
echo "#!"$bashlocation > $ncshow
echo "ncmpc -p "$user_id >> $ncshow
##

# update permissions on above scripts

chmod 700 $updateshow
chmod 700 $clearmpc
chmod 700 $updatempc
chmod 700 $addmpc
chmod 700 $radioshow
chmod 700 $haltradio
chmod 700 $showlength
chmod 700 $weeklength
chmod 700 $initializempd
chmod 700 $haltmpd
chmod 700 $ncshow

chmod 755 $mpd_directory
chmod 700 $mpd_music_directory
chmod 700 $mpd_playlist_directory


if [ ! -f $utils$headertrack ]
  then
$soxlocation -r 44100 -n $HOME$headerwav synth $headerlengthseconds sine
300-500
$lamelocation -h $HOME$headerwav $utils$headertrack
rm $HOME$headerwav
else
echo $utils$headertrack" exists, not creating"
fi

#####

}

InstallShow(){
name_of_show=$1
number_of_days=$2
days_but_one=`expr $number_of_days - 1`
show=$ANONRADIO/$1
settings=$show"/mkradio.conf"
mpdconf=$show"/mpd.conf"

echo "handyc anonradio autoshow autoinstaller version "$installer_version

echo "Home directory is: "$home_directory
echo "username is: "$username
echo "user id is: "$user_id

echo "Creating new radioshow "$name_of_show" for "$number_of_days" days"
echo "Path is "$show
install -d -m u+rwx,go-rwx $show

if [ $number_of_days -gt "0" ]
then
echo "Creating directory structure for "$name_of_show" from "$(date
--date="today" +%Y_%m_%d)" to "$(date --date="$days_but_one day"
+%Y_%m_%d)

COUNTER=0
         while [ $COUNTER -lt $number_of_days ]; do
         episode=$show/$(date --date="$COUNTER day" +%Y_%m_%d)
         #echo "episode path is "$episode
         if [ ! -d "$episode" ]
              then
             install -d -m u+rwx,go-rwx $episode
             echo "Created "$episode
            else
             echo $episode" already exists, skipping"
            fi
             let COUNTER=COUNTER+1
         done
else
echo "No directories created."
fi

######################################################################

if [ ! -f $settings ]
  then
    echo "Creating new "$settings" file..."
else
    echo $settings" exists!"

    echo "Import current settings? (Y/N)"

    echo "Creating backup of current settings..."
    echo "copying "$settings" to "$settings$(date --date="today"
+%Y_%m_%d)".old"
    cp $settings $settings$(date --date="today" +%Y_%m_%d)".old"
fi
touch $settings

######################################################################

echo "This script checks the existence of the mpd.conf file."
echo "Checking..."
if [ -f $mpdconf ]
  then
    echo "mpd.conf exists."
    echo "copying mpd.conf to mpdYYYYMMDD.old"
    ## actually do the copying
else
######################################################################
echo "Creating custom mpd.conf file"
######################################################################

######################################################################
# set up mpd.conf
######################################################################

#check for general mpd.conf file
# if none, prompt for general settings
# echo "Now we will set up a general mpd.conf file for your show(s)."
# echo "This file will be used in the absence of a specific mpd.conf"
# echo "file."

# if general mpd.conf file exists, prompt for specific mpd.conf
#echo -n "Do you want to use your general mpd.conf file for this show?"

#echo "Now we will set up your mpd.conf file for this specific show."

echo "Now we will set up your mpd.conf file"

echo -n "DJ login name (e.g., handyc): "
read dj_login
stream_mount="/"$dj_login
stream_user=$dj_login

echo -n "DJ password (e.g., X122Ert35): "
read dj_password
stream_password=$dj_password

echo -n "Name of show (e.g., The Potato Show): "
#stream_name="STREAM_NAME"
read stream_name

echo -n "Show description (e.g., music and educational programming): "
#stream_name="STREAM_DESCRIPTION"
read stream_description

echo -n "Genre (e.g., technopop): "
#stream_genre="STREAM_GENRE"
read stream_genre

echo -n "Display URL (e.g., http://anonradio.net): "
#stream_url="STREAM_URL"
read stream_url

######################################################################

######################################################################
echo -e "#mpd configuration file" > $mpdconf
echo -e "music_directory\t\""$mpd_music_directory"\"" >> $mpdconf
echo -e "playlist_directory\t\""$mpd_playlist_directory"\"" >> $mpdconf
echo -e "db_file\t\""$mpd_db_file"\"" >> $mpdconf
echo -e "log_file\t\""$mpd_log_file"\"" >> $mpdconf
echo -e "pid_file\t\""$mpd_pid_file"\"" >> $mpdconf
echo -e "state_file\t\""$mpd_state_file"\"" >> $mpdconf
echo -e "sticker_file\t\""$mpd_sticker_file"\"" >> $mpdconf
echo -e "bind_to_address\t\""$mpd_bind_to_address"\"" >> $mpdconf
echo -e "port\t\""$mpd_port"\"" >> $mpdconf

echo -e "\ninput {" >> $mpdconf
echo -e "plugin \"curl\"" >> $mpdconf
echo -e "proxy \"proxy.isp.com:8080\"" >> $mpdconf
echo -e "proxy_user \"user\"" >> $mpdconf
echo -e "proxy_password \"password\"" >> $mpdconf
echo -e "}" >> $mpdconf

echo -e "\naudio_output {" >> $mpdconf
echo -e "type\t\""$stream_type"\"" >> $mpdconf
echo -e "encoding\t\""$stream_encoding"\"" >> $mpdconf
echo -e "name\t\""$stream_name"\"" >> $mpdconf
echo -e "host\t\""$stream_host"\"" >> $mpdconf
echo -e "port\t\""$stream_port"\"" >> $mpdconf
echo -e "mount\t\""$stream_mount"\"" >> $mpdconf
echo -e "password\t\""$stream_password"\"" >> $mpdconf
echo -e "bitrate\t\""$stream_bitrate"\"" >> $mpdconf
echo -e "format\t\""$stream_format"\"" >> $mpdconf
echo -e "protocol\t\""$stream_protocol"\"" >> $mpdconf
echo -e "user\t\""$stream_user"\"" >> $mpdconf
echo -e "description\t\""$stream_description"\"" >> $mpdconf
echo -e "genre\t\""$stream_genre"\"" >> $mpdconf
echo -e "public\t\""$stream_public"\"" >> $mpdconf
echo -e "timeout\t\""$stream_timeout"\"" >> $mpdconf
echo -e "}" >> $mpdconf

## done with mpdconf file
fi

# set permissions for mpd.conf
chmod 644 $mpdconf

######################################################################

echo -n "Start time of your show as HH:MM in UTC (e.g., 13:22): "
IFS=": " read -r start_hour start_minute
echo "Time read as "$start_hour":"$start_minute

#
#echo -n "Ending hour of your show: "
#read end_hour
#echo -n "Ending minute of your show: "
#read end_minute

# use bitwise shifting to mark days on one byte
# 0  0  0  0  0  0  0  0
# Su Mo Tu We Th Fr Sa Su
# mark Sunday twice

echo -n "Ending time of your show as HH:MM in UTC (e.g., 14:22): "
IFS=": " read -r end_hour end_minute
echo "Time read as "$end_hour":"$end_minute

#echo "debug"

show_total_minutes=$(echo "(($end_hour * 60) + ($end_minute)) - (($start_hour * 60) + ($start_minute))" | bc)

#echo $start_hour $end_hour $start_minute $end_minute
#echo "(($end_hour * 60) + ($end_minute)) - (($start_hour * 60) + ($start_minute))"
echo $show_total_minutes "minute show"
## warning: above calculation does not work properly with shows spanning multiple days (e.g., begin at 23:40 and end at 1:20 the following day)
## this feature can be added later by modifying the scheduling function
## alternative option is to ask for start time and running length

# now calculate suitable termination times for mpc and mpd
showend_time_minutes=$(echo "$show_total_minutes + $showend_time_shift" | bc)
mpd_halt_time_minutes=$(echo "$show_total_minutes + $mpd_halt_time_shift" | bc)


# the following byte represents days the show will air
#   Su Mo Tu We Th Fr Sa Su
#    0  0  0  0  0  0  0  0
#  128 64 32 16  8  4  2  1

showdays_byte="0"

######################################################################


# Now set the value of above byte by querying user

if Confirm "Does your show air on Monday?";
then
showdays_byte=$(echo "$showdays_byte + 64" | bc)
echo "adding Monday: $showdays_byte"
fi

if Confirm "Does your show air on Tuesday?";
then
showdays_byte=$(echo "$showdays_byte + 32" | bc)
echo "adding Tuesday: $showdays_byte"
fi

#compute Tuesday shifted time

if Confirm "Does your show air on Wednesday?";
then
showdays_byte=$(echo "$showdays_byte + 16" | bc)
echo "adding Wednesday: $showdays_byte"
fi

#compute Wednesday shifted time

if Confirm "Does your show air on Thursday?";
then
showdays_byte=$(echo "$showdays_byte + 8" | bc)
echo "adding Thursday: $showdays_byte"
fi

#compute Thursday shifted time

if Confirm "Does your show air on Friday?";
then
showdays_byte=$(echo "$showdays_byte + 4" | bc)
echo "adding Friday: $showdays_byte"
fi

#compute Friday shifted time

if Confirm "Does your show air on Saturday?";
then
showdays_byte=$(echo "$showdays_byte + 2" | bc)
echo "adding Saturday: $showdays_byte"
fi

#compute Saturday shifted time

if Confirm "Does your show air on Sunday?";
then
showdays_byte=$(echo "$showdays_byte + 129" | bc)
echo "adding Sunday: $showdays_byte"
fi

#echo "Show airs on these days (byte): $showdays_byte"

######################################################################

# ConvertDayTime "0" "4" "35" "-12"

echo ""
echo "The following information should be added to your crontab:"
echo ""
echo "#########################################################################"
echo "# mpd init"
ConvertDayTime $showdays_byte $start_hour $start_minute $mpd_init_time_shift
echo " "$initializempd" "$name_of_show

echo "# show update"
ConvertDayTime $showdays_byte $start_hour $start_minute $update_time_shift
echo " "$updateshow" "$name_of_show

echo "# mpc clear"
ConvertDayTime $showdays_byte $start_hour $start_minute $clearmpc_time_shift
echo " "$clearmpc

echo "# mpc update"
ConvertDayTime $showdays_byte $start_hour $start_minute $updatempc_time_shift
echo " "$updatempc

echo "# mpc add"
ConvertDayTime $showdays_byte $start_hour $start_minute $addmpc_time_shift
echo " "$addmpc

echo "# show init"
ConvertDayTime $showdays_byte $start_hour $start_minute $showstart_time_shift
echo " "$radioshow

echo "# show halt"
ConvertDayTime $showdays_byte $start_hour $start_minute $showend_time_minutes
echo " "$haltradio

echo "# mpd halt"
ConvertDayTime $showdays_byte $start_hour $start_minute $mpd_halt_time_minutes
echo " "$haltmpd
echo "#########################################################################"


#if Confirm "Would you like this information added to your crontab
#automatically?";
#then
#back up old crontab
#crontab -l > oldcron_MMDDYY
#echo "now updating crontab..."
#crontab -l > mycron
#echo "00 09 * * 1-5 echo hello" >> mycron
#crontab mycron
### update crontab with above
#fi

#automatically add to crontab
#echo $(crontab -l)

#write out current crontab
#crontab -l > mycron
#echo new cron into cron file
#echo "00 09 * * 1-5 echo hello" >> mycron
#install new cron file
#crontab mycron
#rm mycron
}

Add(){
echo "add $1"
Chkdir

if [ -d $ANONRADIO/$1 ]
then
echo "$1 already present"
chmod go-rwx $ANONRADIO/$1
else
echo "Now adding show: $1"
install -d -m u+rwx,go-rwx $ANONRADIO/$1
fi

dayscount=0
echo -n "Number of days from today to create show: "
read dayscount
InstallShow $1 $dayscount
}

Del(){
echo "feature not yet available"
}

Usage(){
echo
echo "mkradio - Allows you to add/del automated shows for your anonradio
account."
echo
echo "usage examples:"
echo
echo "  mkradio add         <show>     create show"
echo "  mkradio del         <show>     delete show"
#echo "  mkradio update                 update scripts"
echo

#/usr/bin/crontab -l

exit 0
}

ConvertDayTime(){
input_day=$1
input_hour=$2
input_minute=$3
#display_factor="1"

# day as byte, 0 0 0 0 0 0 0 0 = Su Mo Tu We Th Fr Sa Su

#set today, yesterday, tomorrow
yesterday_string=0
tomorrow_string=0

total_days="0"

## input day is Monday (yesterday: Sunday; tomorrow: Tuesday)
#echo -n "Mo: "
if [ $(($input_day & 2)) == 2 ]
then
#echo "yes"
yesterday_string=$(echo "$yesterday_string + 129" | bc)
tomorrow_string=$(echo "$tomorrow_string + 4" | bc)

if [ $total_days -gt 0 ]
    then
    showdays_yesterday=$showdays_yesterday",Sun"
    showdays_today=$showdays_today",Mon"
    showdays_tomorrow=$showdays_tomorrow",Tue"
    else
    showdays_yesterday="Sun"
    showdays_today="Mon"
    showdays_tomorrow="Tue"
    fi
total_days=$total_days+1

#else
#echo "no"
fi

## input day is Tuesday (yesterday: Monday; tomorrow: Wednesday)
#echo -n "Tu: "
if [ $(($input_day & 4)) == 4 ]
then
#echo "yes"
yesterday_string=$(echo "$yesterday_string + 2" | bc)
tomorrow_string=$(echo "$tomorrow_string + 8" | bc)

if [ $total_days -gt 0 ]
    then
    showdays_yesterday=$showdays_yesterday",Mon"
    showdays_today=$showdays_today",Tue"
    showdays_tomorrow=$showdays_tomorrow",Wed"
    else
    showdays_yesterday="Mon"
    showdays_today="Tue"
    showdays_tomorrow="Wed"
    fi
total_days=$total_days+1

#else
#echo "no"
fi

## input day is Wednesday (yesterday: Tuesday; tomorrow: Thursday)
#echo -n "We: "
if [ $(($input_day & 8)) == 8 ]
then
#echo "yes"
yesterday_string=$(echo "$yesterday_string + 4" | bc)
tomorrow_string=$(echo "$tomorrow_string + 16" | bc)

if [ $total_days -gt 0 ]
    then
    showdays_yesterday=$showdays_yesterday",Tue"
    showdays_today=$showdays_today",Wed"
    showdays_tomorrow=$showdays_tomorrow",Thu"
    else
    showdays_yesterday="Tue"
    showdays_today="Wed"
    showdays_tomorrow="Thu"
    fi
total_days=$total_days+1

#else
#echo "no"
fi

## input day is Thursday (yesterday: Wednesday; tomorrow: Friday)
#echo -n "Th: "
if [ $(($input_day & 16)) == 16 ]
then
#echo "yes"
yesterday_string=$(echo "$yesterday_string + 8" | bc)
tomorrow_string=$(echo "$tomorrow_string + 32" | bc)

if [ $total_days -gt 0 ]
    then
    showdays_yesterday=$showdays_yesterday",Wed"
    showdays_today=$showdays_today",Thu"
    showdays_tomorrow=$showdays_tomorrow",Fri"
    else
    showdays_yesterday="Wed"
    showdays_today="Thu"
    showdays_tomorrow="Fri"
    fi
total_days=$total_days+1

#else
#echo "no"
fi

## input day is Friday (yesterday: Thursday; tomorrow: Saturday)
#echo -n "Fr: "
if [ $(($input_day & 32)) == 32 ]
then
#echo "yes"
yesterday_string=$(echo "$yesterday_string + 16" | bc)
tomorrow_string=$(echo "$tomorrow_string + 64" | bc)

if [ $total_days -gt 0 ]
    then
    showdays_yesterday=$showdays_yesterday",Thu"
    showdays_today=$showdays_today",Fri"
    showdays_tomorrow=$showdays_tomorrow",Sat"
    else
    showdays_yesterday="Thu"
    showdays_today="Fri"
    showdays_tomorrow="Sat"
    fi
total_days=$total_days+1

#else
#echo "no"
fi

## input day is Saturday (yesterday: Friday; tomorrow: Sunday)
#echo -n "Sa: "
if [ $(($input_day & 64)) == 64 ]
then
#echo "yes"
yesterday_string=$(echo "$yesterday_string + 32" | bc)
tomorrow_string=$(echo "$tomorrow_string + 129" | bc)

if [ $total_days -gt 0 ]
    then
    showdays_yesterday=$showdays_yesterday",Fri"
    showdays_today=$showdays_today",Sat"
    showdays_tomorrow=$showdays_tomorrow",Sun"
    else
    showdays_yesterday="Fri"
    showdays_today="Sat"
    showdays_tomorrow="Sun"
    fi
total_days=$total_days+1

#else
#echo "no"
fi

## input day is Sunday (yesterday: Saturday; tomorrow: Monday)
if [ $(($input_day & 129)) == 129 ]
then
#echo "yes"
yesterday_string=$(echo "$yesterday_string + 64" | bc)
tomorrow_string=$(echo "$tomorrow_string + 2" | bc)

if [ $total_days -gt 0 ]
    then
    showdays_yesterday=$showdays_yesterday",Sat"
    showdays_today=$showdays_today",Sun"
    showdays_tomorrow=$showdays_tomorrow",Mon"
    else
    showdays_yesterday="Sat"
    showdays_today="Sun"
    showdays_tomorrow="Mon"
    fi
total_days=$total_days+1

#else
#echo "no"
fi

######################################################################

total_minutes=$(echo "(60 * $input_hour) + $input_minute" | bc)
#echo "input time: "$input_hour":"$input_minute
#echo "total minutes: "$total_minutes

input_shift=$4
#shift in minutes

new_minutes=$(echo "$total_minutes + $input_shift" | bc)
#echo "shift of "$input_shift" results in new minutes: "$new_minutes

#convert hour + minutes to minutes
#include day in this computation
if [ "$new_minutes" -lt "0" ]
then
#echo -n "(previous day)"
set_minutes=$(echo "1440 + $new_minutes" | bc)
#output_day=$yesterday_string
output_day=$showdays_yesterday
#echo -n $set_minutes
elif [ "$new_minutes" -ge "1440" ]
then
#echo -n "(next day)"
set_minutes=$(echo "$new_minutes - 1440" | bc)
#output_day=$tomorrow_string
output_day=$showdays_tomorrow
#echo -n $set_minutes
else
set_minutes=$new_minutes
#output_day=$input_day
output_day=$showdays_today
fi

#output_hour=$(echo "$input_hour" | bc)
#output_minute=$(echo "$input_minute + $input_shift" | bc)

output_hour=$(echo "$set_minutes / 60" | bc)
output_minute=$(echo "$set_minutes % 60" | bc)

######################################################################

#echo "converted date: "
echo -n "$output_minute $output_hour * * $output_day"
#return "0"
}

case $1 in

  add) Add $2;;
  del) Del $2;;
  *) Usage;;

esac
