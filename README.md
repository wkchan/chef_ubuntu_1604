# chef_ubuntu_1604

This repo is an execise of provision an ubuntu VM automatically with 5 features:

1. provision an Ubuntu 16.04 server
2. carry out any configuration steps needed to allow login over ssh, securely and disable password based login
3. Setting up the firewall to only allow ingress on the ssh port and
4. only to allow password-less (certificate) based login
5. then display the MOTD including the text "Hello Assurity DevOps”.

# Runtime

## The runtime should be on a Mac OSX BigSur.

## Tested on
- MacOS X 11.2.3 with intel i7 10th gen
- MacOS X 11.2.3 with intel i5 5th gen

# To Run the installer

1. Git clone this repo
2. ```bash run.sh```
3. It is an account with sudo right for installing and uninstalling multipass

# Tech Stack

1. Multipass - A virtual machine provisionor that support Apple's native virtial machine
2. Chef - A IaC framework in rube for configuration management. It's written in ruby.
3. Git - Source code version control
4. Bash - Glue everything together

# Todo
1. More exception handling
2. Cleaner code
3. Other ideas
