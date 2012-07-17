#!/bin/bash
. hooks/swiftlib.sh
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

################################################################################
# This is a simple git-hook for generating static sites with jekyll and
# uploading them to CloudStorage.
################################################################################


DEBUG=no

# CloudStorage access credentials 
STORAGE_USER='<storage_id>'
STORAGE_KEY='<key>'

# Target CloudStorage container
CNT="public"

# Branch to genereate content from
DBRANCH="master"

# Deploy method. 
# simple - Just regenerate and reupload all content. Don't delete anyting.
# updel  - Upload everything and then delete unnecessary objects form CS.
DMETH="updel"

################################################################################
# Don't edit anything below this line until you know what you are doing
################################################################################

if [[ "$*" =~ "refs/heads/${DBRANCH}" ]]; then
    echo "We have update for $DBRANCH. Need to regenerate and deploy."
else
    exit 0
fi

TMPCLONE=`mktemp -d`
git archive --format=tar $DBRANCH | tar x -C $TMPCLONE
rm -rf $TMPCLONE/_site/*

pushd $TMPCLONE
if ! jekyll --no-auto $TMPCLONE $TMPCLONE/_site ; then
    error "Can't find jekyll to generate"
    exit 0
fi
popd

DIR="${TMPCLONE}/_site"

D1=`dirname "$DIR"`
D2=`basename "$DIR"`
DIR="$D1/$D2"

echo -ne "Authenticating..."
if authenticate $STORAGE_USER $STORAGE_KEY; then
    echo -ne "done\n"
else
    echo -ne "failed\n"
    exit 1
fi

echo "Uploading files..."
flist=`find "$DIR" -type f | sed "s%$DIR/%%"`
echo "$flist" | while read file
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

if [ "$DMETH" == "updel" ]; then
    echo "Removing unnecessary objects."
    RLIST=`get_obj_list "$CNT" | sort`
    LLIST=`find "$DIR" -type f | sed "s%$DIR/%%" | sort`
    DLIST=$(diff -u <(echo "$RLIST") <(echo "$LLIST") |egrep -v "^---" | grep "^-"| sed "s/^-//")
    echo "$DLIST" | while read objct 
    do
        echo -ne "delete ${CNT}/${objct} "
        if delete_obj "${CNT}/${objct}" ; then
            echo -ne "OK\n"
        else
            echo -ne "FAIL\n"
        fi
    done
fi

rm -rf $TMPCLONE
