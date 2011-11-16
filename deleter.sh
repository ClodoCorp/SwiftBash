#!/bin/bash
. swiftlib.sh
. ~/.swiftbash.sh

if [ -z "$STORAGE_USER" ]; then
    STORAGE_USER='storage_6681_1'
fi

if [ -z "$STORAGE_KEY" ]; then
    STORAGE_KEY='ad4f23431fbd68512cd0s8929443baaa'
fi

CNT="$1"
MSK="$2"

if [ -z "$MSK" -o -z "$CNT" ]; then
    echo "Usage: $0 <container> <mask>"
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
    touch /tmp/tmp.list$cont
    tmpfile="/tmp/tmp.list$cont"
fi

echo -ne "Getting container filelist "
long_obj_list_2file $CNT " " "$tmpfile"
echo -ne "done\n"

for objct in `grep -e "^${MSK}" $file`
do
    echo -ne "delete ${CNT}/${objct} "
    if delete_obj "${CNT}/${objct}" ; then
        echo -ne "OK\n"
    else
        echo -ne "FAIL\n"
    fi
done
    
rm -f $tmpfile

