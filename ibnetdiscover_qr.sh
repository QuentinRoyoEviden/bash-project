#!/bin/bash

FILEREF=""
SWITCH=""
LISTPORTSREF=$(mktemp /tmp/log.ibnetdiscoverref.XXXXXX)
LISTPORTS=$(mktemp /tmp/log.ibnetdiscover.XXXXXX)

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
if [[ -z $FILEREF || -z $SWITCH ]]; then
        echo "One or many arguments are empty. Verify the arguments and retry."
	exit 1
fi

# VERIFY IF THE REFERENCE FILE ARE TRUE
if [[ ! -f $FILEREF ]]; then
	echo "The reference file doesn't exist ($FILEREF). Verify the argument and retry."
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

# CREATE A TEMPORARY FILE WITH ALL CORRECT PORTS OF $SWITCH
grep -P "(?=.*$SWITCH)(?=.*base port)" -A 100 ${FILEREF} | sed '/Mellanox Technologies Aggregation Node/q' | sed 's/lid [0-9]*//g' > ${LISTPORTSREF}

# CREATE A TEMPORARY FILE WITH ALL MISSING PORTS OF $SWITCH
ibnetdiscover | grep -P "(?=.*$SWITCH)(?=.*base port)" -A 100 ${IBNET} | sed '/Mellanox Technologies Aggregation Node/q' | sed 's/lid [0-9]*//g' > ${LISTPORTS}

# COMPARE THE RESULTS OF THE TWO FILES AND DISPLAYS ONLY THE MISSING LINE(S)
TMP=$(diff ${LISTPORTSREF} ${LISTPORTS} | grep "HDR$" | cut -c 3-)

# DISPLAY THE RESULT OF THE COMPARISON IN THE TERMINAL
echo "$TMP"

# LET US KNOW WHEN THERE ARE NO DIFFERENCE BETWEEN THE FILES
if [[ -z "$TMP" ]]; then
        echo "No difference found for this switch ($SWITCH)."
fi

# DELETE TEMPORARY FILES TO AVOID OVERLOADING STORAGE
rm -f $LISTPORTSREF
rm -f $LISTPORTS
