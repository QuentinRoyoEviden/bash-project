#!/bin/bash

# my switchs will be "iswi1r2s5c0l2" and "iswi4r4s1c7l1"
# FILEREF="/home/qroyo/bash_project1/ibnet.13022026"
# IBNET="/home/qroyo/bash_project1/ibnet.error"
# echo "The way to the reference file is : $FILEREF"
# These examples helped me to realise the format of the switch condtion : grep '^foo$' filename and grep '[vV][iI][Vv][Ee][kK]' filename

FILEREF=""
IBNET=""
SWITCH=""

# ARGUMENT OPTIONS DEFINED
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

# VERIFY THAT ALL ARGUMENTS ARE FULLFILLED
if [[ -z $FILEREF || -z $IBNET || -z $SWITCH ]]; then
        echo "One or many arguments are empty. Verify the arguments and retry."
	exit 1
fi

# VERIFY IF THE REFERENCE FILE ARE TRUE
if [[ ! -f $FILEREF ]]; then
	echo "The reference file doesn't exist ($FILEREF). Verify the argument and retry."
	exit 1
fi

# VERIFY IF THE NEW FILE ARE TRUE
if [[ ! -f $IBNET ]]; then
        echo "The new file doesn't exist ($IBNET). Verify the argument and retry."
        exit 1
fi

# VERIFY IF THE SWITCH NAME EXISTS IN THE REFERENCE FILE
if ! grep -q "$SWITCH" "$FILEREF"; then
	echo "this switch $SWITCH doesn't exist in the file, please verify your argument and retry."
	exit 1
fi

# VERIFY IF THE FORMAT OF THE SWITCH NAME IS AS EXPECTED
if ! grep -qP "^iswi[0-9]r[0-9]s[0-9]c[0-9]l[0-9]$" <<< "$SWITCH"; then
        echo "this switch $SWITCH is not the expected format, please verify your argument and retry."
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
