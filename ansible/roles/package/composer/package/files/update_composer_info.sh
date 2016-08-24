#!/bin/bash
if [[ "$#" -lt 2 ]]; then
        echo "Need composer.phar path and age in seconds"
        exit 1
fi

UPDATE=1;
echo "Composer path:  $1"

if [[ -f $1 ]]; then
        echo "Composer found: Yes"

else
        echo "Composer found: No"
fi;

echo "-----------------------------------------------"

if [[ -f $1 ]]; then
        COMPOSER_DATE=$("$1" -V | egrep "^Composer version (.*) [0-9]{4}-[0-9]{2}-[0-9]{2} [0-2][0-9]:[0-5][0-9]:[0-5][0-9]$" | egrep "[0-9]{4}-[0-9]{2}-[0-9]{2} [0-2][0-9]:[0-5][0-9]:[0-5][0-9]" -o);
        SYSTEM_DATE=$(date "+%Y-%m-%d %H:%M:%S")
        COMPOSER_TIMESTAMP=$(date -d "$COMPOSER_DATE" +%s)
        SYSTEM_TIMESTAMP=$(date -d "$SYSTEM_DATE" +%s)

        DIFF_AGE=$(($SYSTEM_TIMESTAMP - $COMPOSER_TIMESTAMP))
        DIFF_SEC=$DIFF_AGE
        DIFF_MIN=$(($DIFF_SEC / 60))
        DIFF_SEC=$(($DIFF_SEC - ($DIFF_MIN * 60) ))
        DIFF_HOUR=$(($DIFF_MIN / 60))
        DIFF_MIN=$(($DIFF_MIN - ($DIFF_HOUR * 60) ))
        DIFF_DAY=$(($DIFF_HOUR / 24))
        DIFF_HOUR=$(($DIFF_HOUR - ($DIFF_DAY * 24) ))

        echo "Composer date:  $COMPOSER_DATE ($COMPOSER_TIMESTAMP)"
        echo "System date:    $SYSTEM_DATE ($SYSTEM_TIMESTAMP)"
        echo "Difference:     $DIFF_DAY day(s)  $DIFF_HOUR:$DIFF_MIN:$DIFF_SEC ($DIFF_AGE)"
        if [[ "$DIFF_AGE" -lt "$2" ]]; then
                UPDATE=0
        fi
fi

if [[ $UPDATE -gt 0 ]]; then
        UPDATE_STRING="Yes"
else
        UPDATE_STRING="No"
fi
echo "-----------------------------------------------"
echo "Update: $UPDATE_STRING"

if [[ $UPDATE -gt 0 ]]; then
        exit 10
else
        exit 0
fi
