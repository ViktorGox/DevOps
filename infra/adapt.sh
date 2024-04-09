#!/bin/bash

failed_action() {
    echo -e "Requires access token. Provide as first argument."
    exit 1
}

# Verify argument validity
if [ "$#" != 1 ]; then
    failed_action
fi

PROJECT_NAME=29
TOKEN=$1

declare -A env_vars

env_vars["SCHEME"]="HTTP"

terraform init
terraform apply -auto-approve
env_vars["INSTANCE_IP"]=$(terraform output -json instance_ip | jq -r '.')
env_vars["BUCKET_URL"]=$(terraform output -json bucket_website_endpoint | jq -r '.')

aws_ssh_key=$(terraform output -raw ssh_private_key)
env_vars["AWS_SSH_KEY"]=$(echo "$aws_ssh_key" | tr -d '\n')

response=$(curl --header "PRIVATE-TOKEN: $TOKEN" "https://gitlab.com/api/v4/projects?search=$PROJECT_NAME")

project_id=$(echo "$response" | jq -r '.[0].id')

for key in "${!env_vars[@]}"; do
  curl --request DELETE \
    --header "PRIVATE-TOKEN: $TOKEN" \
   "https://gitlab.com/api/v4/projects/$project_id/variables/$key"

  echo "${env_vars[$key]}"

  curl --request POST \
    --header "PRIVATE-TOKEN: $TOKEN" \
    --header "Content-Type: application/json" \
    --data "{\"key\": \"$key\", \"value\": \"${env_vars[$key]}\"}" \
    "https://gitlab.com/api/v4/projects/$project_id/variables"
done