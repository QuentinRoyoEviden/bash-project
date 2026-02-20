#!/bin/bash

# EXAMPLES :
# FILEREF="/home/qroyo/bash_project1/ibnet.13022026"
# IBNET="/home/qroyo/bash_project1/ibnet.error"

LISTPORTSREF=$(mktemp /tmp/log.ibnetdiscoverref.XXXXXX)
LISTPORTS=$(mktemp /tmp/log.ibnetdiscover.XXXXXX)

# FLAGS DEFINED
while [[ $# -gt 0 ]]; do
        case $1 in
                --ibnet_ref=)
                        IBNETREF=$2
                        shift
                        shift
                        ;;
                --ibnet=)
                        IBNET=$2
                        shift
                        shift
                        ;;
                --switchs=)
                        SWITCHS=$2
                        shift
                        shift
                        ;;
				--help)
						echo "usage: ./ibnetdiscover_qr_twofiles.sh [--help] --ibnet_ref= REFERENCE-FILE [--ibnet= NEW-FILE] --switchs= SWITCH-NAME"
						exit 1
						;;
        *)
                        echo "Unknown flag $1 Please retry with good arguments"
                        exit 1
                        ;;
        esac
done

# echo "SWITCHS = $SWITCHS"
if [[ -z $IBNETREF ]]; then
        echo "Please give a reference file"
        exit 1
fi

# VERIFY IF THE REFERENCE FILE ARE TRUE
if [[ ! -f $IBNETREF ]]; then
        echo "The reference file doesn't exist ($IBNETREF). Verify the argument and retry."
        exit 1
fi

# VERIFY IF THE SWITCH ARGUMENT IS GIVEN
if [[ -z $SWITCHS ]]; then
        echo "Please give a switch name"
        exit 1
fi

# VERIFY IF THE SWITCH NAME EXISTS IN THE REFERENCE FILE
if ! grep -q "$SWITCHS" "$IBNETREF"; then
        echo "This switch $SWITCHS is not found in the reference file."
		exit 1
fi

# VERIFY IF THE NEW FILE IS TRUE
#if [[ ! -f $IBNET ]]; then
#       ibnetdiscover | grep -P "(?=.*$SWITCH)(?=.*base port)" -A 100 ${IBNET} | sed '/Mellanox Technologies Aggregation Node/q' | sed 's/lid [0-9]*//g' > ${LISTPORTS}
#       echo "Launching ibnetdisover"
#fi

if [[ ! -z $IBNET ]]; then
        if [[ ! -f $IBNET ]]; then
                echo "$IBNET not found"
                exit 1
        fi
else
        echo "launching ibnetdiscover"
        exit 1
fi

# VERIFY IF THE FORMAT OF THE SWITCH NAME IS AS EXPECTED
if ! grep -qP "^iswi[0-9]r[0-9]s[0-9]c[0-9]l[0-9]$" <<< "$SWITCHS"; then
        echo "This switch $SWITCHS is not the expected format."
        exit 1
fi

# CREATE A TEMPORARY FILE WITH ALL CORRECT PORTS OF $SWITCH
grep -P "(?=.*$SWITCHS)(?=.*base port)" -A 100 ${IBNETREF} | sed '/Mellanox Technologies Aggregation Node/q' | sed 's/lid [0-9]*//g' > ${LISTPORTSREF}

# CREATE A TEMPORARY FILE WITH ALL MISSING PORTS OF $SWITCH
grep -P "(?=.*$SWITCHS)(?=.*base port)" -A 100 ${IBNET} | sed '/Mellanox Technologies Aggregation Node/q' | sed 's/lid [0-9]*//g' > ${LISTPORTS}

# COMPARE THE RESULTS OF THE TWO FILES AND DISPLAYS ONLY THE MISSING LINE(S)
TMP=$(diff ${LISTPORTSREF} ${LISTPORTS} | grep "HDR$" | cut -c 3-)

# DISPLAY THE RESULT OF THE COMPARISON IN THE TERMINAL
echo "$TMP"

# LET US KNOW WHEN THERE ARE NO DIFFERENCE BETWEEN THE FILES
if [[ -z "$TMP" ]]; then
        echo "No difference found for this switch ($SWITCHS)."
fi

# DELETE TEMPORARY FILES TO AVOID OVERLOADING STORAGE
rm -f $LISTPORTSREF
rm -f $LISTPORTS
