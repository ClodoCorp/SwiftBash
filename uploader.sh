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
    echo -ne "$CNT/$FNM ... "
    if create_dir "$CNT" "$FNM"; then
        echo -ne "OK\n"
    else
        echo -ne "FAIL\n"
    fi
done

echo "Uploading files..."
for file in `find $DIR -type f`
do
    FNM=`echo $file | sed "s%$DIR%%"`
    echo -ne "$CNT/$FNM ... "
    if put_obj $CNT $FNM $file; then
        echo -ne "OK\n"
    else
        echo -ne "FAIL\n"
    fi

done
