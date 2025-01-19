#!/bin/bash

# Check if the file "./credentials.json" exists
if [ ! -f "./credentials.json" ]; then
    echo "ERROR: The file './credentials.json' does not exist."
    exit 1
fi

# Run the gcloud authentication command
gcloud auth activate-service-account --key-file="./credentials.json"

# Execute the gcloud command and store the output in a variable
IdentityToken=$(gcloud auth print-identity-token)

# Output the token to verify
echo "NOTE: Bearer token if not deployed anonymous"
echo ""
echo "bearer $IdentityToken"
echo ""

# Extract the project_id using jq
project_id=$(jq -r '.project_id' "./credentials.json")

# Construct the URL
URL="https://us-central1-${project_id}.cloudfunctions.net"

# Output the health check endpoint
echo "NOTE: Health check endpoint is $URL/gtg?details=true"

# Run the test_candidates script
./01-cloudfunctions/test_candidates.py "$URL"
