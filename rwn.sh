#!/bin/bash
#silly little arrow key graphic menu demo in bash
#use arrow keys to move, 'r' for random colors, 's' to save, 'k' to quack, 'q' to quit
#inspired by this thread (but heavily modified):
#https://stackoverflow.com/questions/10679188/casing-arrow-keys-in-bash
save () { printf "saving" ; }
quack1 () { ls; echo ""; } ;
quack2 () { ls; echo ""; } ;
recto () { tput cup "$(echo $ycsr)" "$(echo $xcsr)"; echo "$xcsr $ycsr";
tput cup "$(echo $((ycsr+1)))" "$(echo $xcsr)"; echo $( ls | head -c20 );
tput cup "$(echo $((ycsr+2)))" "$(echo $xcsr)"; echo $( ls | head -c20 );
tput cup "$(echo $((ycsr+3)))" "$(echo $xcsr)"; echo $(date); }

af=$RANDOM; ab=$RANDOM; tput setaf $af; tput setab $ab;
xcsr=0;ycsr=0;while [ "$ky" != "q" ];do clear; recto; read -sn1 -t 60 ky;
read -sn1 -t 0.0001 a;read -sn1 -t 0.0001 b;read -sn1 -t 0.0001 c;
ky+=${a}${b}${c}; case "$ky" in
    $'\e[A'|$'\e0A')((cur > 1)) && ((cur--)); ycsr=$((ycsr-1));;
    $'\e[D'|$'\e0D')((cur > 1)) && ((cur--)); xcsr=$((xcsr-1));;
    $'\e[B'|$'\e0B')((cur < $#-1)) && ((cur++)); ycsr=$((ycsr+1));;
    $'\e[C'|$'\e0C')((cur < $#-1)) && ((cur++)); xcsr=$((xcsr+1));;
    k)echo Kwak...; quack1; tput sgr0; exit;;
    l)echo Kwak2...; quack2; tput sgr0; exit;;
    r)echo Rand...; af=$RANDOM; ab=$RANDOM; tput setaf $af; tput setab $ab;;
    s)echo Saving...; save; tput sgr0; exit;;
    q)echo Bye!; tput sgr0; exit;; esac; done
