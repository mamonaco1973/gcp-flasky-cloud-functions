
./check_env.ps1
$returnCode = $LASTEXITCODE

# Check if the return code indicates failure
if ($returnCode -ne 0) {
    Write-Host "ERROR: check_env.ps1 failed with exit code $returnCode. Stopping the script." -ForegroundColor Red
    exit $returnCode
}

cd 01-cloudfunctions
cd code

if (Test-Path ../functions.zip) { Remove-Item ../functions.zip -Force }
Compress-Archive -Path "*" -DestinationPath "../functions.zip" -Force

cd ..

terraform init
terraform apply -auto-approve

cd ..


