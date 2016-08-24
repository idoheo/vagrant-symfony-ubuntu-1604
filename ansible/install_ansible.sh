#!/bin/bash

## Environment definition
INSTALL_ANSIBLE_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

## Commands definition
COMMAND_ADD_ANSIBLE="$INSTALL_ANSIBLE_SCRIPT_DIR/add_ppa_repository.sh ansible/ansible-1.9"
COMMAND_INSTALL_ANSIBLE="sudo apt-get -y --force-yes --no-install-recommends -q -qq install ansible"

## Execute add ansible PPA
eval $COMMAND_ADD_ANSIBLE
RESULT=$?;
if [ $RESULT -ne 0 ]; then
	exit $RESULT;
fi;

## Execute install ansible
eval $COMMAND_INSTALL_ANSIBLE;
RESULT=$?;
if [ $RESULT -ne 0 ]; then
	exit $RESULT;
fi;


exit 0;
