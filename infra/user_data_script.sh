#!/bin/bash

#Update and install necessary packages
sudo apt update
sudo apt install -y docker.io jq

# Set GitLab access token and URL
ACCESS_TOKEN="glpat-s33TZsMwqzYaq3Z73NBf"
GITLAB_URL="https://gitlab.com"
PROJECT_NAME=29

# Get project details
project_info=$(curl --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "https://gitlab.com/api/v4/projects?search=$PROJECT_NAME")

# Parse project namespace and name from the response
PROJECT_ID=$(echo "$project_info" | jq -r '.[0].id')
REGISTRY_URL=$(echo "$project_info" | jq -r '.[0].namespace.full_path')


# Fetch variables from GitLab API using access token
LOGIN_USERNAME=$(curl --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/variables/LOGIN_USERNAME" | jq -r '.value')
LOGIN_PASSWORD=$(curl --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/variables/LOGIN_PASSWORD" | jq -r '.value')
DATABASE_IP=$(curl --header "PRIVATE-TOKEN: $ACCESS_TOKEN" "$GITLAB_URL/api/v4/projects/$PROJECT_ID/variables/DATABASE_IP" | jq -r '.value')


# Execute commands with fetched variables
echo $LOGIN_PASSWORD | sudo docker login -u $LOGIN_USERNAME --password-stdin registry.gitlab.com &&
sudo docker pull registry.gitlab.com/$REGISTRY_URL/$PROJECT_NAME/backend:latest &&
sudo docker tag registry.gitlab.com/$REGISTRY_URL/$PROJECT_NAME/backend:latest backend &&
sudo docker run -d --name backend -p 8080:8080 \
-e DB_USER=user \
-e DB_PASSWORD=password \
-e DB_HOST=$DATABASE_IP \
backend
