#!/bin/bash


USAGE="Usage: $0 --chefhome /your_path/ --nodejson node.json"
CHEF_HOME=""
NODE_JSON=""

if [ "$#" == "0" ]; then
	echo "$USAGE"
	exit 1
fi

while (( "$#" )); do

    case $1 in

    "--chefhome")
        CHEF_HOME=$2
        shift
        ;;

    "--nodejson")
        NODE_JSON=$2
        shift
        ;;

    *)
        shift
        ;;
    esac
done


cd ${CHEF_HOME}
chef-client --chef-license=accept -z -j ${CHEF_HOME}/${NODE_JSON}