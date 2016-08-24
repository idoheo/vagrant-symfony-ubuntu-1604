#!/bin/bash

if [[ $# -lt 1 ]]; then
	echo "Not provided ElasticSearch bin path"
	exit 1
fi

if [[ ! -f $1 ]]; then
	echo 0
	exit
fi

"$1" --version | egrep "^[[:space:]]*(V|v)ersion[[:space:]]*(:|)[[:space:]]*[0-9]+(.[0-9]+)*" -o | egrep "[0-9]+(.[0-9]+)*$" -o | egrep "^[0-9]+" -o
