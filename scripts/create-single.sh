#!/bin/bash
if [ -z $1 ];then
	echo "Usage: ./create-secret.sh <secret-name> <app> <secret-file>"
else
  # Get the instance id 
gcloud secrets create "$1" --labels "app=$2" --data-file "$3"
fi
