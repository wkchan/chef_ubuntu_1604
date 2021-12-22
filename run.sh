#!/bin/bash

# Setup working directories

TMP_DIR=${HOME}/.chef_ubuntu_1604
SECRETS_DIR=${TMP_DIR}/.secrets
COOKBOOK_DIR=${TMP_DIR}/cookbooks
DEFAULT_VM_NAME="ubuntu1604"
VM_NAME=${DEFAULT_VM_NAME}
UBUNTU_VERSION='16.04'
KEY_NAME="id_ed25519_${VM_NAME}"
VM_USERNAME="ubuntu"
CHEF_DEB_URL="https://packages.chef.io/files/stable/chef-workstation/21.10.640/ubuntu/16.04/chef-workstation_21.10.640-1_amd64.deb"
CHEF_DEB_FILENAME="chef-workstation_21.10.640-1_amd64.deb"


function print_working_folders() {
   echo $TMP_DIR
   echo $SECRETS_DIR
}
# check folders exist
function create_working_folder_if_not_exist(){

    if [[ ! -d $TMP_DIR ]]
    then
        mkdir $TMP_DIR
    else
        echo "${TMP_DIR} is already exist."
    fi

    if [[ ! -d $SECRETS_DIR ]]
    then
        mkdir $SECRETS_DIR
    else
        echo "${SECRETS_DIR} is already exist."
    fi

    if [[ ! -d $COOKBOOK_DIR ]]
    then
        mkdir $COOKBOOK_DIR
    else
        echo "${COOKBOOK_DIR} is already exist."
    fi

}

# create ssh keys
function create_ssh_key_pair(){
    ssh-keygen -o -a 100 -t ed25519 -f ${SECRETS_DIR}/${KEY_NAME} -N "" -C "ubuntu@${VM_NAME}" -q 
}

function copy_ssh_scripts(){
    cp -p copy_ssh_keys.sh ${TMP_DIR}/.
}

function authorise_public_key(){
    multipass exec $1 -- bash ${TMP_DIR}/copy_ssh_keys.sh --public_key ${SECRETS_DIR}/${KEY_NAME}.pub 
}


# verify multipass
function is_multipass_installed(){
    value=`which multipass`
    if [[ -f $value ]]
    then
        echo 'multipass is installed.'
    else
        echo 'multipass is not installed.'
        echo 'Script is installing multipass.'
        install_multipass
    fi

}

function install_multipass(){
    brew install --cask multipass
}

# create an ubuntu1604 VM
function create_virtual_machine(){
    echo 'Creating VM with multipass.'
    multipass launch --name $1 $2
    multipass mount ${TMP_DIR} $1

}

#preflight check
function setenv(){
    print_working_folders
    create_working_folder_if_not_exist
    create_ssh_key_pair
    copy_ssh_scripts
    is_multipass_installed

}


#apt update and ugprade
function apt_update_and_upgrade(){

    multipass exec $1 -- sudo apt update
    multipass exec $1 -- sudo apt upgrade -y
}

# install chef
function install_chef(){
    cp install_chef.sh ${TMP_DIR}/.
    multipass exec $1 -- sudo bash ${TMP_DIR}/install_chef.sh --deb_url $CHEF_DEB_URL --localpath ${TMP_DIR} --filename ${CHEF_DEB_FILENAME}
    #multipass exec $1 -- cd ${TMP} && sudo dpkg -i ${CHEF_DEB_FILENAME}
#    multipass exec $1 -- sudo dpkg -i ${TMP_DIR}/${CHEF_DEB_FILENAME}
}


# setup chef resources
function setup_chef_resources(){
    cp -p node.json ${TMP_DIR}/.
    cp -p execute_chef_runlist.sh ${TMP_DIR}/.
}

function git_clone_recipe(){
    multipass exec $1 -- git clone https://github.com/wkchan/motd.git ${COOKBOOK_DIR}/motd
    multipass exec $1 -- git clone https://github.com/wkchan/ufw.git ${COOKBOOK_DIR}/ufw
    multipass exec $1 -- git clone https://github.com/wkchan/firewall.git ${COOKBOOK_DIR}/firewall
}

function run_chef_runlist(){
    multipass exec $1 -- sudo find /etc/update-motd.d/ -type f -delete
    multipass exec $1 -- sudo bash ${TMP_DIR}/execute_chef_runlist.sh --chefhome ${TMP_DIR} --nodejson node.json
}

function main(){
    create_virtual_machine $VM_NAME $UBUNTU_VERSION
    apt_update_and_upgrade $VM_NAME
    install_chef $VM_NAME
    setup_chef_resources $VM_NAME
    git_clone_recipe $VM_NAME
    run_chef_runlist $VM_NAME
    authorise_public_key $VM_NAME
}

function cleanup(){
    multipass stop $VM_NAME
    multipass delete $VM_NAME
    multipass purge
    rm -rf ${TMP_DIR}
}

function wrapup(){
    VM_IP=`multipass exec ubuntu1604 -- hostname -I`
#    KEY_PATH=`echo ${SECRETS_DIR)"/"${KEY_NAME}`
    echo "To run ssh to the Virtual Machine, please run the commnad below:"
    echo "ssh -o \"UserKnownHostsFile=/dev/null\" -o \"StrictHostKeyChecking=no\" -i ${SECRETS_DIR}/${KEY_NAME} -l ${VM_USERNAME} ${VM_IP}"
    
}

cleanup
setenv
main
wrapup