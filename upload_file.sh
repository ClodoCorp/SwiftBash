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

LFN="$1"
CNT="$2"
RFN="$3"

if [ -n "$4" ]; then
    PREF_SSIZE="$4"
fi

if [[ -z "$LFN" || -z "$RFN" ]]; then
    echo "Usage: $0 <local filename> <container> <remote objname> [segment size]"
    echo "Example: $0 /tmp/big.iso public debian6_amd64.iso"
    exit 1
fi

if [ ! -f "$LFN" ]; then
    error "Source file is not a file!"
    exit 2
fi

echo -ne "Authenticating..."
if authenticate $STORAGE_USER $STORAGE_KEY; then
    echo -ne "done\n"
else
    echo -ne "failed\n"
fi

if  ! check_container_exists "$CNT"; then
    error "Container $CNT does not exist"
    exit 2
fi

LSZ=`stat -c %s "$LFN"`
echo -ne "Upload ${CNT}/${RFN} ... "

if [ $(( $LSZ / $PREF_SSIZE)) -gt 2 ]; then
    debug "Need segmented upload."
    if put_obj_large  "$CNT" "$RFN" "$LFN" "$PREF_SSIZE"; then
        echo -ne "OK\n"
    else
        echo -ne "Retry in 10s\n"
        sleep 10
        if put_obj_large  "$CNT" "$RFN" "$LFN" "$PREF_SSIZE"; then
            echo -ne "OK\n"
        else
            echo -ne "FAIL\n"
        fi
    fi
else
    if put_obj "$CNT" "$RFN" "$LFN"; then
        echo -ne "OK\n"
    else
        echo -ne "Retry in 10s\n"
        sleep 10
        if put_obj "$CNT" "$RFN" "$LFN"; then
            echo -ne "OK\n"
        else
            echo -ne "FAIL\n"
        fi
    fi
fi


