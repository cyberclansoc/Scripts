# Ensure PsFalcon module is loaded
if (-not (Get-Module -ListAvailable -Name PsFalcon)) {
    Install-Module -Name PsFalcon -Force -SkipPublisherCheck
}
Import-Module PsFalcon

# Function to fetch the AID from the registry
function Get-AIDFromRegistry {
    $aid = [System.BitConverter]::ToString( ((Get-ItemProperty 'HKLM:\SYSTEM\CrowdStrike\{9b03c1d9-3138-44ed-9fae-d9f4c034b88d}\{16e0423f-7058-48c9-a204-725362b67639}\Default' -Name AG).AG)).ToLower() -replace '-',''
    return $aid
}

# Function to obtain uninstallation token from CrowdStrike API
function Get-UninstallationToken {
    param (
        [Parameter(Mandatory=$true)][string]$clientId,
        [Parameter(Mandatory=$true)][string]$clientSecret,
        [Parameter(Mandatory=$true)][string]$aid
    )

    # Authenticate and obtain access token
    Request-FalconToken -ClientId $clientId -ClientSecret $clientSecret

    #Request uninstallation token
    $tokenResponse = Get-FalconUninstallToken -Id $aid
    return $tokenResponse.uninstall_token
}

# Main script execution
$clientId = "chnageme"
$clientSecret = "chnageme"

# Fetch AID
$aid = Get-AIDFromRegistry

if ($aid) {
    Write-Host "Host AID:" $aid
    # Get uninstallation token
    $uninstallToken = Get-UninstallationToken -clientId $clientId -clientSecret $clientSecret -aid $aid

    if ($uninstallToken) {
        Write-Host "Uninstall Token:" $uninstallToken
        # Construct download URL for uninstaller (this URL is hypothetical and needs to be replaced with the actual one provided by CrowdStrike)
        $uninstallerUrl = "https://github.com/cyberclansoc/Scripts/raw/main/CsUninstallTool.exe"
        
        # Download the uninstaller - replace with actual download command/method
        $uninstallerPath = "C:\Uninstaller.exe"
        Invoke-WebRequest -Uri $uninstallerUrl -OutFile $uninstallerPath

        # Execute the uninstaller
        Start-Process -FilePath $uninstallerPath -ArgumentList "MAINTENANCE_TOKEN=$uninstallToken /quiet" -Wait

        # De-auth
        Revoke-FalconToken
    }
    else {
        Write-Host "Failed to obtain uninstallation token."
    }
}
else {
    Write-Host "AID not found in registry."
}
