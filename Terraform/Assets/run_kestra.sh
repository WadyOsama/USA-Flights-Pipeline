#!/bin/bash

# Extract the arguments
GCP_PROJECT_ID="$1"
GCP_LOCATION="$2"
GCP_BUCKET="$3"
GCP_DATASET="$4"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list
sudo apt-get update

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Download Kestra compose file
curl -o docker-compose.yml https://raw.githubusercontent.com/kestra-io/kestra/develop/docker-compose.yml

# Run Kestra container in detached mode
sudo docker compose -p kestra up -d

# Wait for Kestra to be up and running
while ! sudo docker logs kestra-kestra-1 | grep "Server Running"; do
    sleep 5
done
sleep 20

# Post the pipeline flow to Kestra
curl -X POST http://localhost:8080/api/v1/flows \
     -H "Content-Type: application/x-yaml" \
     --data-binary "@/home/$USER/kestra_flow.yaml"

# Set the GCP project ID in Kestra namespace KV Store
curl -X PUT "http://localhost:8080/api/v1/namespaces/dezoomcamp.project/kv/GCP_PROJECT_ID" \
     -H "Content-Type: application/json" \
     -d "\"$GCP_PROJECT_ID\""

# Set the GCP location in Kestra namespace KV Store
curl -X PUT "http://localhost:8080/api/v1/namespaces/dezoomcamp.project/kv/GCP_LOCATION" \
     -H "Content-Type: text/plain" \
     -d "\"$GCP_LOCATION\""

# Set the GCP bucket name in Kestra namespace KV Store
curl -X PUT "http://localhost:8080/api/v1/namespaces/dezoomcamp.project/kv/GCP_BUCKET" \
     -H "Content-Type: application/json" \
     -d "\"$GCP_BUCKET\""

# Set the GCP dataset name in Kestra namespace KV Store
curl -X PUT "http://localhost:8080/api/v1/namespaces/dezoomcamp.project/kv/GCP_DATASET" \
     -H "Content-Type: text/plain" \
     -d "\"$GCP_DATASET\""

# Set the GCP credentials in Kestra namespace KV Store
curl -X PUT "http://localhost:8080/api/v1/namespaces/dezoomcamp.project/kv/GCP_CREDS" \
     -H "Content-Type: application/json" \
     --data-binary "@/home/$USER/gcp_creds.json"

# Run the pipeline flow
curl -X POST http://localhost:8080/api/v1/executions/dezoomcamp.project/flights_pipeline