#!/bin/bash
. swiftlib.sh
. ~/.swiftbash.sh

DEBUG=yes

if [ -z "$STORAGE_USER" ]; then
    STORAGE_USER='storage_6681_1'
fi

if [ -z "$STORAGE_KEY" ]; then
    STORAGE_KEY='ad4f23431fbd68512cd0s8929443baaa'
fi

CNT="$1"
MSK="$2"

if [ -z "$MSK" -o -z "$CNT" ]; then
    echo "Usage: $0 <container> <mask> [-d]"
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
long_obj_list_2file $CNT " " "$tmpfile"
echo -ne "done\n"

for objct in `grep -e "^${MSK}" $tmpfile`
do
    echo -ne "delete ${CNT}/${objct} "
    
    if [ "$3" == "-d" ]; then
        echo -ne " TEST\n"
        continue
    fi

    if delete_obj "${CNT}/${objct}" ; then
        echo -ne "OK\n"
    else
        echo -ne "FAIL\n"
    fi

done
    
rm -f $tmpfile

