#!/bin/bash
ANSIBLE_VERSION="1.9.4"
ANSIBLE_BIN=$(which ansible)

if [ -z $ANSIBLE_BIN ]; then
	## Ansible missing
	sudo apt-get update
	sudo apt-get install python-markupsafe python-pip libffi-dev libssl-dev -q -qq -y
#	sudo pip install --upgrade setuptools
#	sudo pip install --upgrade pip
	echo "Installing Ansible $ANSIBLE_VERSION"
	sudo pip install ansible==$ANSIBLE_VERSION -q
    	ANSIBLE_BIN=$(which ansible)
fi;
