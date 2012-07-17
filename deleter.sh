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

CNT="$1"
MSK="$2"

if [[ -z "$MSK" || -z "$CNT" ]]; then
    echo "Usage: $0 <container> <mask> [-d]"
    echo "Example: $0 public \".*\" -d"
    exit 1
fi

echo -ne "Authenticating..."
if authenticate $STORAGE_USER $STORAGE_KEY; then
    echo -ne "done\n"
else
    echo -ne "failed\n"
fi

tmpfile=`mktemp`

if [ ! -f $tmpfile ]; then
    touch /tmp/tmp.list${CNT}
    tmpfile="/tmp/tmp.list${CNT}"
fi

debug "Using temporary file $tmpfile"

echo -ne "Getting container filelist "
get_obj_list_long "$CNT" "$tmpfile"
echo -ne "done\n"

objlist=`grep -e "${MSK}" $tmpfile`
echo "$objlist" | while read objct 
do
    echo -ne "delete ${CNT}/${objct} "
    
    if [[ "$3" == "-d" ]]; then
        echo -ne " TEST\n"
        continue
    fi

    if delete_obj "${CNT}/${objct}" ; then
        echo -ne "OK\n"
    else
        echo -ne "Retry in 10s\n"
        sleep 10
        if delete_obj "${CNT}/${objct}" ; then
            echo -ne "OK\n"
        else
            echo -ne "FAIL\n"
        fi
    fi
done
    
rm -f $tmpfile

