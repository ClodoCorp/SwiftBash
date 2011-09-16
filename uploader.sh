#!/bin/bash

AUTH_URL='http://testapi.clodo.ru/v1'
STORAGE_USER='storage_6681_1'
STORAGE_KEY='857a63980c5b3640f3053cdb80156b7e'
API_URL=""
API_TOKEN=""

DIR="$1"
CNT="$2"

if [ -z "$DIR" -o -z "$CNT" ]; then
    echo "Usage: $0 <local dir> <remote cont>"
    exit 1
fi

function auth() {
    AUTH_DAT="$(curl -I -s -H "X-Auth-User: $STORAGE_USER" -H "X-Auth-Key: $STORAGE_KEY" $AUTH_URL)"

    if [ -z "$AUTH_DAT" ]; then
        echo "ERROR: Can't find Cloud Storage server"
        exit 1
    fi

    ERR=`echo "$AUTH_DAT" | grep 'Unauthorized'`
    if [ $? -eq 0 ]; then
        echo "ERROR: Unauthorized!"
        exit 1
    fi

    API_URL=`echo "$AUTH_DAT" | grep 'X-Storage-Url'|sed 's/X-Storage-Url: \(.*\)\r/\1/'`
    if [ -z "$API_URL" ]; then
        echo "ERROR: Error getting API URL"
        exit 1
    fi

    API_TOKEN=`echo "$AUTH_DAT" | grep 'X-Storage-Token' | sed 's/X-Storage-Token: \(.*\)\r/\1/'`
    if [ -z "$API_TOKEN" ]; then
        echo "ERROR: Error getting API TOKEN"
        exit 1
    fi
}

auth


for dir in `find $DIR -type d`
do
    FNM=`echo $dir | sed "s%$DIR%%"`
    echo $FNM
    curl -f -X PUT -s -H "X-Storage-Token: $API_TOKEN" -H "Content-Type: application/directory" -H "Content-Length: 0" $API_URL/$CNT/$FNM > /dev/null
    if [ "$?" -eq "22" ]; then
        auth
        curl -X PUT -s -H "X-Storage-Token: $API_TOKEN" -H "Content-Type: application/directory" -H "Content-Length: 0" $API_URL/$CNT/$FNM > /dev/null    
    fi

done

for file in `find $DIR`
do
    FNM=`echo $file | sed "s%$DIR%%"`
    echo $FNM
    curl -f -I -s -T $file -H "X-Storage-Token: $API_TOKEN" $API_URL/$CNT/$FNM > /dev/null
    if [ "$?" -eq "22" ]; then
        auth
        curl -I -s -T $file -H "X-Storage-Token: $API_TOKEN" $API_URL/$CNT/$FNM > /dev/null
    fi
done
