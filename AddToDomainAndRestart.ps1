
# Ensure the script is run with appropriate execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

param([switch]$Elevated)

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-not (Test-Admin)) {
    if ($Elevated) {
        # Elevation attempt failed, aborting
        Write-Host "Failed to elevate privileges. Aborting."
        exit 1
    } else {
        # Restart script with elevation
        $arguments = "-NoProfile -NoExit -File `"$PSCommandPath`" -Elevated"
        Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs
        exit
    }
}

'Running as Administrator'

# Prompt for the domain password
$DomainPassword = Read-Host "Enter the domain password" -AsSecureString

# Set the domain credentials (username is fixed)
$DomainUsername = "Domain\User"
$DomainCredentials = New-Object System.Management.Automation.PSCredential ($DomainUsername, $DomainPassword)

# Prompt for the domain name
$DomainName = 'Domain.Local'

# Add the computer to the domain
try {
    Add-Computer -DomainName $DomainName -Credential $DomainCredentials -Restart
    Write-Host "Computer successfully added to the domain. The computer will restart to complete the domain join process."
} catch {
    Write-Error "Failed to add computer to the domain. Error: $_"
    exit 1
}
