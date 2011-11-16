#!/bin/bash
. swiftlib.sh
. ~/.swiftbash.sh

echo "User: $STORAGE_USER"
echo "Key: $STORAGE_KEY"

if authenticate $STORAGE_USER $STORAGE_KEY ; then
    echo "+ AUTH Passed"
#    echo "Token: $API_TOKEN"
#    echo "URL: $API_URL"
else
    echo "+ AUTH Failed"
    exit -1
fi

acc_meta=$(get_acct_meta)
if echo "$acc_meta" | grep "X-Account-Object-Count:" > /dev/null ; then
    echo "+ ACC_meta Passed"
else
    echo "+ ACC_meta Failed"
fi

acc_bytes=$(get_acct_bytes_used)
acc_conts=$(get_acct_cont_count)

CONTLIST=$(get_cont_list)
cont_num=$(echo "$CONTLIST" | wc -l)

if [ "$cont_num" -eq "$acc_conts" ]; then
    echo "+ ACC_cont_list Passed"
else
    echo "+ ACC_cont_list Failed"
fi

CONT=$(echo "$CONTLIST"|tail -n1)

cont_meta=$(get_cont_meta $CONT)
if echo "$cont_meta" | grep "X-Container-Object-Count:" > /dev/null ; then
    echo "+ CONT_meta Passed"
else
    echo "+ CONT_meta Failed"
fi

obj_count=$(get_obj_count $CONT)
OBJLIST=$(get_obj_list $CONT)
obj_num=$(echo "$OBJLIST" | wc -l)

if [ "$obj_num" -eq "$obj_count" ]; then
    echo "+ CONT_obj_list Passed"
else
    echo "+ CONT_obj_list Failed"
fi

if create_cont "testAAA" ; then
    echo "+ CONT_create Passed"
else
    echo "+ CONT_create Failed"
fi

if delete_cont "testAAA" ; then
    echo "+ CONT_delete Passed"
else
    echo "+ CONT_delete Failed"
fi

