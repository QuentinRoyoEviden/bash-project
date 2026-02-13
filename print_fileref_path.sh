#!/bin/bash

# my switchs will be "iswi1r2s5c0l2" and "iswi1r0s0c0l1"
# file_ref="/home/qroyo/bash_project1/ibnet.13022026"
# echo "The way to the reference file is : $file_ref"

FILEREF=$1
SWITCH=$2
SWITCHTITLE=$(grep $SWITCH $FILEREF | grep "base port")
NBPORT=$(grep $SWITCH $FILEREF | grep "base port" | awk '{print $2}')

echo "FILEREF is $1 and SWITCH is $2"

PRINT=$(grep -P '(?=.*$SWITCH)(?=.*base port)' -A 12 $FILEREF)

#echo "$SWITCHTITLE"
echo "$NBPORT"
echo "$PRINT"
