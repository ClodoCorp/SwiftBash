#!/bin/bash
. swiftlib.sh
. ~/.swiftbash.sh

DEBUG=no

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

D1=`dirname $DIR`
D2=`basename $DIR`
DIR="$D1/$D2"

echo -ne "Authenticating..."
if authenticate $STORAGE_USER $STORAGE_KEY; then
    echo -ne "done\n"
else
    echo -ne "failed\n"
fi

echo "Creating directories from $DIR..."

for dir in `find $DIR -type d | sed "s%$DIR%%" | sed "s%^/%%"`
do
    echo -ne "$CNT/$dir ... "
    if create_dir "$CNT" "$dir"; then
        echo -ne "OK\n"
    else
        echo -ne "FAIL\n"
    fi
done

echo "Uploading files..."
for file in `find $DIR -type f | sed "s%$DIR/%%"`
do
    echo -ne "$CNT/$file ... "
    if put_obj "$CNT" "$file" "$DIR/$file"; then
        echo -ne "OK\n"
    else
        echo -ne "Retry in 10s\n"
        sleep 10
        if put_obj "$CNT" "$file" "$DIR/$file"; then
            echo -ne "OK\n"
        else
            echo -ne "FAIL\n"
        fi
    fi

done
