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

if [ -n "$4" ]; then
    PREF_SSIZE="$4"
fi

if [[ -z "$DIR" || -z "$CNT" ]]; then
    echo "Usage: $0 <local dir> <remote cont> [segment size]"
    echo "Example: $0 /usr/share public"
    exit 1
fi

D1=`dirname $DIR`
D2=`basename $DIR`
DIR="$D1/$D2"

if [[ ! -d $DIR ]]; then
    echo "$DIR is not a directory"
    exit 1
fi

echo -ne "Authenticating..."
if authenticate $STORAGE_USER $STORAGE_KEY; then
    echo -ne "done\n"
else
    echo -ne "failed\n"
    exit 1
fi

if  ! check_container_exists "$CNT"; then
    error "Container $CNT does not exist"
    exit 2
fi

echo "Creating directories from $DIR..."
dirlist=`find $DIR -type d | sed "s%$DIR%%" | sed "s%^/%%"`
echo "$dirlist" | while read dir 
do
    echo -ne "$CNT/$dir ... "
    if create_dir "$CNT" "$dir"; then
        echo -ne "OK\n"
    else
        echo -ne "FAIL\n"
    fi
done

echo "Uploading files..."
flist=`find $DIR -type f | sed "s%$DIR/%%"`
echo "$flist" | while read file 
do
    echo -ne "$CNT/$file ... "

    # check if filesize more than segment size
    LSZ=`stat -c %s "$DIR/$file"`
    if [ $(( $LSZ / $PREF_SSIZE)) -gt 2 ]; then
        if put_obj_large "$CNT" "$file" "$DIR/$file" "$PREF_SSIZE"; then
            echo -ne "OK\n"
        else
            echo -ne "Retry in 10s\n"
            sleep 10
            if put_obj_large "$CNT" "$file" "$DIR/$file" "$PREF_SSIZE"; then
                echo -ne "OK\n"
            else
                echo -ne "FAIL\n"
            fi
        fi
    else    
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
    fi
done
