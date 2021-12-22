#!/bin/bash


USAGE="Usage: $0 --public_key /your_path/keyname.pub "
PUBLIC_KEY=""

if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

while (( "$#" )); do

    case $1 in

    "--public_key")
        PUBLIC_KEY=$2
        shift
        ;;

    *)
        shift
        ;;
    esac
done


if [[ -f $PUBLIC_KEY ]]
then
    cat $PUBLIC_KEY >> ${HOME}/.ssh/authorized_keys
else
    echo "Key not found: ${PUBLIC_KEY}"
fi