#!/bin/bash
. swiftlib.sh
. ~/.swiftbash.sh

if [ -z "$STORAGE_USER" ]; then
    STORAGE_USER='storage_6681_1'
fi

if [ -z "$STORAGE_KEY" ]; then
STORAGE_KEY='ad4f23431fbd68512cd0s8929443baaa'
fi

DIR="$1"
CNT="$2"

if [ -z "$DIR" -o -z "$CNT" ]; then
    echo "Usage: $0 <local dir> <remote cont>"
    exit 1
fi

authenticate $STORAGE_USER $STORAGE_KEY

for dir in `find $DIR -type d`
do
    FNM=`echo $dir | sed "s%$DIR%%"`
    echo $FNM
    curl -f -X PUT -s -H "X-Storage-Token: $API_TOKEN" -H "Content-Type: application/directory" -H "Content-Length: 0" $API_URL/$CNT/$FNM > /dev/null
    if [ "$?" -eq "22" ]; then
        authenticate $STORAGE_USER $STORAGE_KEY
        curl -X PUT -s -H "X-Storage-Token: $API_TOKEN" -H "Content-Type: application/directory" -H "Content-Length: 0" $API_URL/$CNT/$FNM > /dev/null    
    fi
done

for file in `find $DIR`
do
    FNM=`echo $file | sed "s%$DIR%%"`
    echo $FNM
    curl -f -I -s -T $file -H "X-Storage-Token: $API_TOKEN" $API_URL/$CNT/$FNM > /dev/null
    if [ "$?" -eq "22" ]; then
        authenticate $STORAGE_USER $STORAGE_KEY
        curl -I -s -T $file -H "X-Storage-Token: $API_TOKEN" $API_URL/$CNT/$FNM > /dev/null
    fi
done
