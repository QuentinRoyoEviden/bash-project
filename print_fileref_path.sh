#!/bin/bash

# my switchs will be "iswi1r2s5c0l2" and "iswi1r0s0c0l1"
# file_ref="/home/qroyo/bash_project1/ibnet.13022026"
# echo "The way to the reference file is : $file_ref"

FILEREF=$1
IBNET=$2
SWITCH=$3

LISTPORTSREF=$(mktemp /tmp/log.ibnetdiscoverref.XXXXXX)
LISTPORTS=$(mktemp /tmp//home/qroyo/bash_project1/log.ibnetdiscover.XXXXXX)

# CREATE A TEMPORARY FILE WITH ALL CORRECT PORTS OF $SWITCH
grep -P "(?=.*$SWITCH)(?=.*base port)" -A 100 ${FILEREF} | sed '/Mellanox Technologies Aggregation Node/q' > ${LISTPORTSREF}

# CREATE A TEMPORARY FILE WITH ALL MISSING PORTS OF $SWITCH
grep -P "(?=.*$SWITCH)(?=.*base port)" -A 100 ${IBNET} | sed '/Mellanox Technologies Aggregation Node/q' > ${LISTPORTS}

TMP=$(diff ${LISTPORTSREF} ${LISTPORTS})

echo ${TMP}

# rm -f $LISTPORTSREF
# rm -f $LISTPORTS
