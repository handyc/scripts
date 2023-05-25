#!/bin/ksh
# Thu Aug 4 14:02:00 UTC 2016;handyc
# handyc@sdf.org

ANONRADIO=$HOME/anonradio

Chkdir(){
if [ ! -d $ANONRADIO ]
then install -d -m u+rwx,go-rwx $ANONRADIO
#then echo "no dir"
else chmod go-rwx $ANONRADIO
fi

# then install -d -m u+rwx,go-rwx $ANONRADIO
#      touch $ANONRADIO/.pw
#      touch $ANONRADIO/.greylist
# else chmod go-rwx $ANONRADIO
#fi
}

Chkdir

#Result(){
#if [ "$1" -le "0" ]
#then /usr/pkg/bin/update-dns
#     /usr/local/bin/update
#fi
#}

Add(){
echo "add"  
}

Del(){
echo "del"  
}

Set(){
echo "set"  
}

Update(){
echo "update"  
}

Clear(){
echo "clear"  
}

Updatempc(){
  echo "updatempc"
}

Addmpc(){
  echo "addmpc"
}

Startshow(){
  echo "startshow"
}

Haltshow(){
  echo "haltshow"
}

#Relay(){
#Chkdir
#if [ "$1" = "" ]
#then IP=`echo $SSH_CLIENT|cut -d= -f2|awk '{print $1}'`
#     if [ "$IP" = "" ]
#     then echo "Unable to get IP"
#          exit 0
#     fi
#else case $1 in
#     *.*.*.*) ;;
#           *) echo "$1 is not a valid IP address" 
#              exit 0 ;;
#     esac
#     IP=$1
#fi
#echo "$IP" > $ANONRADIO/.relay
#echo "Relay set to $IP"
#Result $?
#}

#Add(){


#Chkdir
#user=`echo $1`
#if [ "$user" = "" ]
# then Usage
#fi

#if [ "`echo $user|grep @`" = "" ] && [ "$user" != "bit-bucket" ]
#then echo "$user is not a valid internet address."
#     exit 0
#fi

#if [ "`echo $user|cut -d@ -f1|grep "\."`" != "" ]
#then echo "The username may not contain a period."
#     exit 0
#fi
#if [ "`grep ^$user: $ANONRADIO/.pw`" = "" ]
# then /usr/pkg/sbin/htpasswd -d $ANONRADIO/.pw $user
#      Result $?
# else echo "$user already exists."
#fi
#}

#Mod(){
#user=`echo $1`
#if [ "$user" = "" ]
# then Usage
#fi
#Chkdir
#if [ "`grep ^$user: $ANONRADIO/.pw`" = "" ]
# then echo "$user doesn't seem to exist."
# else /usr/pkg/sbin/htpasswd -d $ANONRADIO/.pw $user
#      Result $?
#fi
#}

#Gry(){
#user=`echo $1`
#if [ "$user" = "" ]
# then Usage
#fi
#Chkdir
#touch -f $ANONRADIO/.greylist
#if [ "`grep ^$user: $ANONRADIO/.pw`" = "" ]
# then echo "$user doesn't seem to exist."
# else if [ "`grep ^$user: $ANONRADIO/.greylist`" = "" ]
#      then echo "$user:" >> $ANONRADIO/.greylist
#           echo "% Greylisting for $user is now disabled."
#           Result $?
#      else grep -v ^$user: $ANONRADIO/.greylist > $ANONRADIO/.$$
#           mv $ANONRADIO/.$$ $ANONRADIO/.greylist
#           echo "% Greylisting for $user is now enabled."
#           Result $?
#      fi
#fi
#}
        
#Del(){
#user=`echo $1`
#if [ "$user" = "" ]
# then Usage
#fi
#Chkdir
#if [ "`grep ^$user: $ANONRADIO/.pw`" = "" ]
# then echo "$user doesn't seem to exist."
# else grep -v ^$user: $ANONRADIO/.pw > $ANONRADIO/.$$
#      mv $ANONRADIO/.$$ $ANONRADIO/.pw
#      Result $?
#fi
#}

#Aka(){

#user=`echo $1`
#alias=`echo $2`
#wdom=`echo $user|cut -d@ -f2`

#if [ -f $ANONRADIO/.wildcard-$wdom ]
#then echo "% You have wildcarding on for $wdom.  Disable it first."
#     exit 0
#fi

#if [ "$alias" = "" ] || [ "$user" = "" ]
#then echo "example:  mkvpm aka someuser@mydomain.com $LOGNAME@sdf.lonestar.org"
#     exit 0
#fi
#Chkdir

#if [ "`echo $user|grep @`" = "" ]
#then echo "$user is not a valid internet address."
#     echo "example:  mkvpm aka someuser@mydomain.com $LOGNAME@sdf.lonestar.org"
#     exit 0
#fi

#if [ "`echo $alias|grep @`" = "" ]
#then echo "$alias is not a valid internet address."
#     echo "example:  mkvpm aka someuser@mydomain.com $LOGNAME@sdf.lonestar.org"
#     exit 0
#fi

#if [ "$alias" = "$user" ]
#then echo "You can not point $alias to itself"
#     echo "example:  mkvpm aka someuser@mydomain.com $LOGNAME@sdf.lonestar.org"
#     exit 0
#fi

#if [ "`grep ^$user: $ANONRADIO/.pw`" != "" ]
#then echo "You need to run 'mkvpm del $user' to delete the mailbox"
#     echo "for $user before creating an alias with the same name."
#     exit 0
#fi
#if [ "`grep ^$alias%$user: $ANONRADIO/.pw`" = "" ]
#then echo "$alias%$user:" >> $ANONRADIO/.pw
#     Result $?
#     echo "% Adding $user -> $alias"
#else grep -v ^$alias%$user: $ANONRADIO/.pw > $ANONRADIO/.$$
#     mv $ANONRADIO/.$$ $ANONRADIO/.pw
#     Result $?
#     echo "% Removing $user -> $alias"
#fi
#}

#Secret(){

#secret=`echo $1|awk '{print $1}'`

#if [ "$secret" = "" ]
#then Usage
#     exit 0
#fi
#Chkdir
#echo "smtpauth=$secret" > $ANONRADIO/.auth
#Result $?
#}

Usage(){
echo
echo "mkradio - Allows you to add/mod/del automated shows for your"
echo "        anonradio account."
echo
echo "usage examples:"
echo
echo "  mkradio add         <show>     create show"
echo "  mkradio del         <show>     delete show"
echo "  mkradio set         <show>     set current show"
echo "  mkradio update      <show>     update mpc data with today's show"
echo "  mkradio start       <show>     begin transmission of a show"
echo "  mkradio halt        <show>     end transmission of a show"
echo "  mkradio updatempc              update mpc playlist"
echo "  mkradio clearmpc               clear mpc playlist"
echo "  mkradio addmpc                 add to mpc playlist"

echo
if [ -f $ANONRADIO/.pw ] && [ "`awk 'END {print NR}' $ANONRADIO/.pw`" -gt "0" ]
then echo "Your ANONRADIO Configuration:\n"
     for i in `cut -d: -f1 $ANONRADIO/.pw`
     do
      case $i in
     *@*%*) alias=`echo $i|cut -d% -f1`
            user=`echo $i|cut -d% -f2`
            echo "forward : $user -> $alias"|awk '{printf("%s %s %-20s %2s  %20s\n", $1, $2, $3, $4, $5)}' ;;
       *%*) alias=`echo $i|cut -d% -f1`
            user=`echo $i|cut -d% -f2`
            echo "forward : $alias -> $user"|awk '{printf("%s %s %-20s %2s  %20s\n", $1, $2, $3, $4, $5)}';;
         *) echo "mailbox : $i";;
      esac
     done
fi
if [ -f $ANONRADIO/.auth ]
then echo "secret  : `head -1 $ANONRADIO/.auth|cut -d= -f2`"
fi
if [ -f $ANONRADIO/.relay ]
then echo "relay ip: `head -1 $ANONRADIO/.relay`"
fi
cd $ANONRADIO
WILDCARD=`ls .wildcard.* 2>/dev/null`
if [ "$WILDCARD" != "" ]
then echo "wildcarding enabled for:  \c"
     for i in $WILDCARD
     do
       echo "`echo $i|cut -d. -f3,4,5`, "
     done
fi
echo
exit 0
}

#All(){
#Chkdir
#if [ "$1" = "" ]
#then echo "% you must specify an email address to toggle wildcarded email."
#     exit 0
#fi
#if [ "`grep ^$1: $ANONRADIO/.pw`" = "" ]
#then echo "% you must first run 'mkvpm add $1' before enabling wildcarding."
#     exit 0
#fi
#wdomain=`echo $1|cut -d@ -f2`
#wuser=`echo $1|cut -d@ -f1`
#if [ "`grep % $ANONRADIO/.pw|grep $wdomain`" != "" ]
#then echo "% You have aliases defined."
#     echo "  Please toggle them off before enabling wildcarding."
#     exit 0
#fi

#if [ -f $ANONRADIO/.wildcard.$wdomain ]
#then rm -f $ANONRADIO/.wildcard.$wdomain
#     echo "Wildcarding for $wdomain will now be disabled."
#     /usr/local/bin/update
#else echo $wuser > $ANONRADIO/.wildcard.$wdomain
#     echo "Wildcarding for $wdomain with delivery to $wuser@$wdomain."
#     /usr/local/bin/update
#fi
#}
 
case $1 in

  add) Add $2;;
  del) Del $2;;
  set) Set $2;;
  gry) Gry $2;;
  mod) Mod $2;;
  aka) Aka $2 $3;; 
  relay) Relay ;;
  all) All $2 ;;
  update) Update $2 ;;
  clearmpc) Clear $2 ;;
  updatempc) Updatempc $2 ;;
  addmpc) Addmpc $2 ;;
  startshow) Startshow $2 ;;
  haltshow) Haltshow $2 ;;
  *) Usage;;

esac