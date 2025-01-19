#!/bin/bash

# Run the check_env.ps1 script and capture the exit code
./check_env.ps1
returnCode=$?

# Check if the return code indicates failure
if [ $returnCode -ne 0 ]; then
    echo "ERROR: check_env.ps1 failed with exit code $returnCode. Stopping the script."
    exit $returnCode
fi

echo "NOTE: Zipping cloud function source into functions.zip."

# Navigate to the 01-cloudfunctions/code directory
cd "01-cloudfunctions/code" || exit 1

# Remove the functions.zip file if it exists
if [ -f "../functions.zip" ]; then
    rm -f ../functions.zip
fi

# Create the ZIP archive
zip -r "../functions.zip" .

# Navigate back to the parent directory
cd ..

echo "NOTE: Building the cloud functions with Terraform."

# Initialize and apply Terraform
terraform init
terraform apply -auto-approve

# Navigate back to the root directory
cd ..

echo "NOTE: Validating the solution."

# Run the validate.ps1 script
./validate.ps1
