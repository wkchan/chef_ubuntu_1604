#!/bin/bash


USAGE="Usage: $0 --deb_url https://somewhere.com/path/package.deb --localpath /your_path/ --filename package.deb"
DEB_URL=""
LOCAL_PATH=""
FILE_NAME=""

if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

while (( "$#" )); do

    case $1 in

    "--deb_url")
        DEB_URL=$2
        shift
        ;;

    "--localpath")
        LOCAL_PATH=$2 
        shift
        ;;

    "--filename")
        FILE_NAME=$2
        shift
        ;;

    *)
        shift
        ;;
    esac
done


curl ${DEB_URL} -o ${LOCAL_PATH}/${FILE_NAME}
cd ${LOCAL_PATH}
dpkg -i ${FILE_NAME}