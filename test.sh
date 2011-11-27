#!/bin/bash
. swiftlib.sh
. ~/.swiftbash.sh

DEBUG=yes

if authenticate $STORAGE_USER $STORAGE_KEY ; then
    echo "+ AUTH Passed"
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
if [ -z "$OBJLIST" ]; then
    obj_num=0
fi

if [ "$obj_num" -eq "$obj_count" ]; then
    echo "+ CONT_obj_list Passed"
else
    echo "+ CONT_obj_list Failed"
fi

UCONT="testAAA"
if create_cont "$UCONT" ; then
    echo "+ CONT_create Passed"
else
    echo "+ CONT_create Failed"
fi

tmpfile=`mktemp`
OBJ_TCONT="Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." 
echo "${OBJ_TCONT}"> $tmpfile
OBJ="lorem.txt"

if put_obj "$UCONT" "$OBJ" "$tmpfile"; then
    echo "+ OBJ_put Passed"
else
    echo "+ OBJ_put Failed"
fi

OBJ_CONT=`curl -s -H "X-Storage-Token: $API_TOKEN" $API_URL/"${UCONT}"/"${OBJ}"`
if [ "$OBJ_CONT" == "$OBJ_TCONT" ]; then
    echo "+ OBJ_get Passed"
else
    echo "+ OBJ_get Failed"
fi

if delete_obj "${UCONT}"/"${OBJ}"; then
    echo "+ OBJ_delete Passed"
else
    echo "+ OBJ_delete Failed"
fi

if delete_cont "$UCONT" ; then
     echo "+ CONT_delete Passed"
 else
     echo "+ CONT_delete Failed"
fi

