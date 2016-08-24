#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Expected exactly one parameter: playbook name";
  exit 1;
fi;

ANSIBLE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";

# Install ansible first if it is not already installed
$ANSIBLE_DIR/install_pip_ansible.sh
INSTALL_ANSIBLE=$?;
if [ $INSTALL_ANSIBLE -ne 0 ]; then 
	echo "Failed to install Ansible. Aborting..."
	exit $?;
fi;


## Setup soruce dirs
ANSIBLE_SOURCE_DIR_DIST="$ANSIBLE_DIR/dist";
ANSIBLE_SOURCE_DIR_PROJECT="/opt/dev-project/source/ansible"
ANSIBLE_SOURCE_DIR_ASSETS="/project_assets"

## Setup playbook name
ANSIBLE_PLAYBOOK="$1";

## Setup file names
ANSIBLE_FILE_NAME_PLAYBOOK="$ANSIBLE_PLAYBOOK.yml";
ANSIBLE_FILE_NAME_PLAYBOOK_VARS="$ANSIBLE_PLAYBOOK-vars.yml";
ANSIBLE_FILE_NAME_DEFAULT_VARS="default-playbook-vars.yml";
ANSIBLE_FILE_NAME_HOSTS="hosts";

## Environment definition
export ANSIBLE_ROLES_PATH="$ANSIBLE_DIR/roles:$ANSIBLE_SOURCE_DIR_PROJECT/roles:$ANSIBLE_SOURCE_DIR_ASSETS/roles"
export PYTHONUNBUFFERED=1;
export ANSIBLE_FORCE_COLOR=1;

## Creating temporary directory
ANSIBLE_TEMPORARY_WORK_DIR=$(tempfile);
rm $ANSIBLE_TEMPORARY_WORK_DIR;
mkdir $ANSIBLE_TEMPORARY_WORK_DIR;

## Creating temporary playbook files
ANSIBLE_MISSING_FILES=0
ANSIBLE_COPY_DIR_ORDER=($ANSIBLE_SOURCE_DIR_DIST $ANSIBLE_SOURCE_DIR_ASSETS $ANSIBLE_SOURCE_DIR_PROJECT);
ANSIBLE_COPY_FILE_ORDER=($ANSIBLE_FILE_NAME_PLAYBOOK $ANSIBLE_FILE_NAME_PLAYBOOK_VARS $ANSIBLE_FILE_NAME_DEFAULT_VARS "php-config.yml" "sql-config.yml" "message-queue-config.yml" "project-config.yml");

## Colors available for printf
COLOR_NONE="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_BLUE="\033[0;34m"
COLOR_PURPLE="\033[0;35m"

## Notify 
echo "";
printf "Preparing to run Ansible playbook $(echo $COLOR_PURPLE) \"$ANSIBLE_PLAYBOOK\" $(echo $COLOR_NONE)\n";
echo "";

echo "Searching for ansible playbook files in following locations:"
for (( idx=${#ANSIBLE_COPY_DIR_ORDER[@]}-1 ; idx>=0 ; idx-- )) ; do
    printf "$(echo $COLOR_YELLOW) %s $(echo $COLOR_NONE)\n" "${ANSIBLE_COPY_DIR_ORDER[idx]}"
done 
echo ""

ANSIBLE_FLIE_NAME_MAX_LENGTH=0;
for ANSIBLE_COPY_FILE in "${ANSIBLE_COPY_FILE_ORDER[@]}"
do
    ANSIBLE_COPY_FILE_NAME_LENGTH=${#ANSIBLE_COPY_FILE}
	if [ $ANSIBLE_COPY_FILE_NAME_LENGTH -gt $ANSIBLE_FLIE_NAME_MAX_LENGTH ]; then
		ANSIBLE_FLIE_NAME_MAX_LENGTH=$ANSIBLE_COPY_FILE_NAME_LENGTH;
	fi;
done

echo "Copying Ansible files to use:"
for ANSIBLE_COPY_FILE in "${ANSIBLE_COPY_FILE_ORDER[@]}"
do
	ANSIBLE_SOURCE_FILE="";
	ANSIBLE_TARGET_FILE="$ANSIBLE_TEMPORARY_WORK_DIR/$ANSIBLE_COPY_FILE";
	for ANSIBLE_COPY_DIR in "${ANSIBLE_COPY_DIR_ORDER[@]}"
	do
		ANSIBLE_ASSUMED_SOURCE_FILE="$ANSIBLE_COPY_DIR/$ANSIBLE_COPY_FILE";
		if [ -f $ANSIBLE_ASSUMED_SOURCE_FILE ]; then
			ANSIBLE_SOURCE_FILE="$ANSIBLE_ASSUMED_SOURCE_FILE";
		fi;
	done
	
	DISPLAY_FILE=$(echo $ANSIBLE_COPY_FILE);
	DISPLAY_DIR=$(dirname "$ANSIBLE_SOURCE_FILE");
	
	if [ -z $ANSIBLE_SOURCE_FILE ]; then
		ANSIBLE_MISSING_FILES=$[$ANSIBLE_MISSING_FILES + 1];
		printf "[$(echo $COLOR_RED)FAIL$(echo $COLOR_NONE)] $(echo $COLOR_RED)%s$(echo $COLOR_NONE)\n" "$DISPLAY_FILE"
		printf "     ..... MISSING\n" 
	else
		
		printf "[$(echo $COLOR_GREEN) OK $(echo $COLOR_NONE)] $(echo $COLOR_GREEN)%s$(echo $COLOR_NONE)\n" "$DISPLAY_FILE"
		printf "     found in $(echo $COLOR_YELLOW)%s$(echo $COLOR_NONE)\n" "$DISPLAY_DIR"
		cp $ANSIBLE_SOURCE_FILE $ANSIBLE_TARGET_FILE;
		chmod 644 $ANSIBLE_TARGET_FILE;
	fi;
	
done

echo "";

## Copy hosts file
cp $ANSIBLE_DIR/$ANSIBLE_FILE_NAME_HOSTS $ANSIBLE_TEMPORARY_WORK_DIR/$ANSIBLE_FILE_NAME_HOSTS;
chmod 644 $ANSIBLE_TEMPORARY_WORK_DIR/$ANSIBLE_FILE_NAME_HOSTS;

## Execute
if [ "$ANSIBLE_MISSING_FILES" -eq 0 ]; then
	printf "Roles path set to: $(echo $COLOR_YELLOW) \n$(echo $ANSIBLE_ROLES_PATH | tr ":" "\n") $(echo $COLOR_NONE)\n\n";
	printf "Running Ansible playbook $(echo $COLOR_PURPLE) \"$ANSIBLE_PLAYBOOK\" $(echo $COLOR_NONE)\n\n";
	ansible-playbook -i $ANSIBLE_TEMPORARY_WORK_DIR/$ANSIBLE_FILE_NAME_HOSTS $ANSIBLE_TEMPORARY_WORK_DIR/$ANSIBLE_FILE_NAME_PLAYBOOK;
	ANSIBLE_RESULT=$?;
else
	printf "$(echo $COLOR_RED)NOT ALL ANSIBLE FILES FOUND!$(echo $COLOR_YELLOW) ABORTING! $(echo $COLOR_NONE)\n\n";
fi;

## Clear temporary directory

rm -R $ANSIBLE_TEMPORARY_WORK_DIR

## Exit
if [ "$ANSIBLE_MISSING_FILES" -eq 0 ]; then
	exit $ANSIBLE_RESULT;
else
	exit 1;
fi;
