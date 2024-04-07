#!/bin/bash

cd ~ || { echo "Failed to change directory"; exit 1; }

SSH_KEY="instance-ssh-v2.pem"
REMOTE_IP="54.213.56.5"
REMOTE_PATH="/home/ubuntu"

# Local file paths
LOCAL_FILE1="/mnt/c/DevOps/FinalAssignment/backend.tar"
LOCAL_FILE2="/mnt/c/DevOps/FinalAssignment/database.tar"
LOCAL_FILE3="/mnt/c/DevOps/FinalAssignment/docker-compose.yml"

# Upload files
scp -i "$SSH_KEY" "$LOCAL_FILE1" "ubuntu@$REMOTE_IP:$REMOTE_PATH"
scp -i "$SSH_KEY" "$LOCAL_FILE2" "ubuntu@$REMOTE_IP:$REMOTE_PATH"
scp -i "$SSH_KEY" "$LOCAL_FILE3" "ubuntu@$REMOTE_IP:$REMOTE_PATH"