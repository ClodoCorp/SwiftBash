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

echo -ne "Authenticating..."
if authenticate $STORAGE_USER $STORAGE_KEY; then
    echo -ne "done\n"
else
    echo -ne "failed\n"
fi

echo "Creating directories..."

for dir in `find $DIR -type d`
do
    FNM=`echo $dir | sed "s%$DIR%%"`
    echo -ne "$API_URL/$CNT$FNM ..."
    curl -f -X PUT -s -H "X-Storage-Token: $API_TOKEN" -H "Content-Type: application/directory" -H "Content-Length: 0" $API_URL/$CNT$FNM > /dev/null
    RET=$?
    if [ "$RET" -eq 22 ]; then
        authenticate $STORAGE_USER $STORAGE_KEY
        curl -X PUT -s -H "X-Storage-Token: $API_TOKEN" -H "Content-Type: application/directory" -H "Content-Length: 0" $API_URL/$CNT$FNM > /dev/null    
    fi
    if [ "$RET" -eq 0 ]; then
        echo -ne "OK\n"
    else
        echo -ne "ERROR\n"
    fi
done

echo "Uploading files..."
for file in `find $DIR -type f`
do
    FNM=`echo $file | sed "s%$DIR%%"`
    echo -ne "$API_URL/$CNT$FNM ..."
    curl -f -I -s -T $file -H "X-Storage-Token: $API_TOKEN" $API_URL/$CNT$FNM > /dev/null
    RET=$?
    if [ "$RET" -eq "22" ]; then
        authenticate $STORAGE_USER $STORAGE_KEY
        curl -I -s -T $file -H "X-Storage-Token: $API_TOKEN" $API_URL/$CNT$FNM > /dev/null
    fi
    if [ "$RET" -eq 0 ]; then
        echo -ne "OK\n"
    else
        echo -ne "ERROR\n"
    fi
done
