# Check if the file "./credentials.json" exists
if (-not (Test-Path "./credentials.json")) {
    Write-Host "ERROR: The file './credentials.json' does not exist." -ForegroundColor Red
    exit 1
}

# Run the gcloud authentication command
gcloud auth activate-service-account --key-file="./credentials.json"

# Execute the gcloud command and store the output in a variable
$IdentityToken = & gcloud auth print-identity-token

# Output the token to verify
Write-Host "NOTE: Bearer token if not deployed anonymous" -ForegroundColor Yellow
Write-Host ""
Write-Host "bearer $IdentityToken" -ForegroundColor Blue
Write-Host ""

# Extract the project_id using ConvertFrom-Json
$jsonContent = Get-Content "./credentials.json" -Raw | ConvertFrom-Json
$project_id = $jsonContent.project_id

$URL="https://us-central1-${project_id}.cloudfunctions.net"

Write-Output "NOTE: Health check endpoint is $URL/gtg?details=true"
.\01-cloudfunctions\test_candidates.ps1 $URL
