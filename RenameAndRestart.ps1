
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

# Prompt for the new computer name
$ComputerName = Read-Host "Enter the new computer name"

if ([string]::IsNullOrWhiteSpace($ComputerName)) {
    Write-Error "The computer name cannot be empty or contain only whitespace."
    exit 1
}

# Attempt to rename the computer
try {
    # Execute the rename command
    Rename-Computer -NewName $ComputerName -Force -Restart
    Write-Host "Initiated renaming computer to '$ComputerName'. The computer will restart to complete the renaming process."
} catch {
    Write-Error "Failed to rename the computer. Error: $_"
    exit 1
}
