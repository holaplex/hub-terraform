#!/bin/bash
IFS=$'\n' 
credentials=$(gsutil cat gs://prod-holaplex-hub-tf-state/terraform/state/default.tfstate \
  | jq -r '.resources[].instances[].attributes | {instance: .instance, username: .name, password: .password } | select(.password != null) | [.instance, .username, .password] | @tsv') 
for line in $credentials; do 
  IFS=$'\t' read -ra values <<< "$line" 
  instance="${values[0]}" 
  username="${values[1]}" 
  password="${values[2]}" 

  echo -ne "$password" | gcloud secrets create "$instance-db-creds" --data-file=- --labels=user="$username"
  IFS=$'\n'
done 
