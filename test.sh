#!/bin/bash
. swiftlib.sh
. ~/.swiftbash.sh

echo "Input Auth data..."
echo "User: $STORAGE_USER"
echo "Key: $STORAGE_KEY"

echo "Calling Auth..."
authenticate $STORAGE_USER $STORAGE_KEY

echo "Token: $API_TOKEN"
echo "URL: $API_URL"

echo "Account Bytes used: $(get_acct_bytes_used)"
echo "Account Container count: $(get_acct_cont_count)"

echo "Account MetaData:"
get_acct_meta

echo "Account containers:"
CONTLIST=$(get_cont_list)
echo "$CONTLIST"

echo "Account containers in JSON:"
get_cont_list "json"
echo -ne "\n-------------------------\n"

echo "Account containers in XML:"
get_cont_list "xml"
echo -ne "\n-------------------------\n"

CONT=$(echo "$CONTLIST"|tail -n1)

echo "Object list for $CONT:"
OBJLIST=$(get_obj_list $CONT)
echo "$OBJLIST"


echo "Create container testAAA"
if create_cont "testAAA" ; then
    echo "Created testAAA"
else
    echo "Error creating testAAA"
    exit -1
fi

echo "Container testAAA MetaData:"
get_cont_meta "testAAA"

echo "DELETE container testAAA"
if delete_cont "testAAA" ; then
    echo "Deleted testAAA"
else
    echo "Error deleting testAAA"
    exit -1
fi

