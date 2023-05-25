#!/usr/pkg/bin/bash
# Com logger without entry

now=$(date +%Y_%m_%d_%H%M%S)
room=$1

/usr/pkg/bin/expect /sdf/arpa/gm/h/handyc/scripts/cobbiescript.txt $room
tail -r /sdf/arpa/gm/h/handyc/scripts/coblog > /sdf/arpa/gm/h/handyc/comlogs/$1_$now.txt
rm /sdf/arpa/gm/h/handyc/scripts/coblog
