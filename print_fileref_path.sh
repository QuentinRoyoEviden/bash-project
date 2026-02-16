#!/bin/bash

# my switchs will be "iswi1r2s5c0l2" and "iswi1r0s0c0l1"
# file_ref="/home/qroyo/bash_project1/ibnet.13022026"
# echo "The way to the reference file is : $file_ref"

FILEREF=""
IBNET=""
SWITCH=""

while [[ $# -gt 0 ]]; do
        case $1 in
                --file_ref:)
                        FILEREF=$2
                        shift
                        shift
                        ;;
                --new_file:)
                        IBNET=$2
                        shift
                        shift
                        ;;
                --switch:)
                        SWITCH=$2
                        shift
                        shift
                        ;;
        *)
                        echo "Unknown argument option $1 Please retry with good arguments"
                        exit 1
                        ;;
        esac
done

# VERIFY THAT ALL ARGUMENTS ARE FULLFILED
if [[ -z $FILEREF || -z $IBNET || -z $SWITCH ]]; then
        echo "One or many arguments are empty. Verify the arguments and retry."
	exit 1
fi

# VERIFY THAT ALL ARGUMENTS ARE TRUE
if [[ -f $FILEREF || -f $IBNET || -f $SWITCH ]]; then
        echo "One or many arguments are false. Verify the arguments and retry."
	exit 1
fi

LISTPORTSREF=$(mktemp /tmp/log.ibnetdiscoverref.XXXXXX)
LISTPORTS=$(mktemp /tmp/log.ibnetdiscover.XXXXXX)

# CREATE A TEMPORARY FILE WITH ALL CORRECT PORTS OF $SWITCH
grep -P "(?=.*$SWITCH)(?=.*base port)" -A 100 ${FILEREF} | sed '/Mellanox Technologies Aggregation Node/q' > ${LISTPORTSREF}

# CREATE A TEMPORARY FILE WITH ALL MISSING PORTS OF $SWITCH
grep -P "(?=.*$SWITCH)(?=.*base port)" -A 100 ${IBNET} | sed '/Mellanox Technologies Aggregation Node/q' > ${LISTPORTS}

# COMPARE THE RESULTS OF THE TWO FILES AND DISPLAYS ONLY THE MISSING LINE(S)
TMP=$(diff ${LISTPORTSREF} ${LISTPORTS} | grep "HDR$" | cut -c 3-)

echo "$TMP"

# rm -f $LISTPORTSREF
# rm -f $LISTPORTS
