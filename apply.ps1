
./check_env.ps1
$returnCode = $LASTEXITCODE

# Check if the return code indicates failure
if ($returnCode -ne 0) {
    Write-Host "ERROR: check_env.ps1 failed with exit code $returnCode. Stopping the script." -ForegroundColor Red
    exit $returnCode
}

Write-Host "NOTE: Zipping cloud function source into functions.zip."  -ForegroundColor Green
Set-Location "01-cloudfunctions"
Set-Location "code"

if (Test-Path ../functions.zip) { Remove-Item ../functions.zip -Force }
Compress-Archive -Path "*" -DestinationPath "../functions.zip" -Force

Set-Location ".."

Write-Host "NOTE: Building the cloud functions with terraform."  -ForegroundColor Green

terraform init
terraform apply -auto-approve

Set-Location ".."

Write-Host "NOTE: Validating the solution."   -ForegroundColor Green

./validate.ps1

