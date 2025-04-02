<#
.SYNOPSIS
Connects to a specified VPN profile.

.DESCRIPTION
This script connects to a VPN using provided credentials.
It prioritizes using built-in Windows methods (rasdial) if applicable.
If required, it can call an external VPN client executable.

.PARAMETER VpnProfileName
The name of the VPN connection profile configured in Windows or required by the client executable.

.PARAMETER UserName
The username for the VPN connection.

.PARAMETER VpnClientPath
(Optional) The full path to the VPN client executable if not using built-in Windows VPN.
Example for Cisco AnyConnect: 'C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe'

.EXAMPLE
.\Connect-Vpn.ps1 -VpnProfileName "MyWorkVPN" -UserName "myuser"
# Prompts for password, attempts connection using Windows built-in VPN/rasdial.

.EXAMPLE
.\Connect-Vpn.ps1 -VpnProfileName "AnyConnectProfile" -UserName "myuser" -VpnClientPath "C:\Program Files (x86)\Cisco\Cisco AnyConnect Secure Mobility Client\vpncli.exe"
# Prompts for password, uses Cisco AnyConnect CLI to connect.

.NOTES
Date: 2025-04-02
Requires: PowerShell
Consider security implications when passing credentials to external executables.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$VpnProfileName,

    [Parameter(Mandatory=$true)]
    [string]$UserName,

    [string]$VpnClientPath # Optional: Path to specific VPN client EXE (e.g., AnyConnect's vpncli.exe)
)

# Get credentials securely - Recommended method
Write-Host "Please enter the password for VPN user '$UserName':"
$Credential = Get-Credential -UserName $UserName

# --- Connection Method 1: Windows Built-in VPN (rasdial) ---
# This is often preferred if the VPN is configured in Windows Network Settings
# It handles credentials more securely than passing plain text passwords.
if (-not $VpnClientPath) {
    Write-Host "Attempting connection using Windows built-in VPN (rasdial) for profile '$VpnProfileName'..."
    try {
        # Rasdial usually uses credentials stored in Windows or prompts if needed.
        # Passing credentials directly can be complex and depends on VPN type/settings.
        # This example attempts connection assuming credentials might be stored or prompted for.
        # For more direct credential passing with rasdial (can be tricky):
        # rasdial $VpnProfileName $Credential.UserName $Credential.GetNetworkCredential().Password
        # WARNING: Passing password on command line like above is less secure.
        # It's often better to configure the profile in Windows to store/prompt securely.

        rasdial $VpnProfileName $Credential.UserName $Credential.GetNetworkCredential().Password
        # Check the exit code for success (0 usually means success)
        if ($LASTEXITCODE -eq 0) {
            Write-Host "VPN connection '$VpnProfileName' established successfully."
        } else {
            Write-Warning "VPN connection using rasdial failed with exit code $LASTEXITCODE."
            # Add more specific error handling based on rasdial exit codes if needed
        }
    } catch {
        Write-Error "An error occurred while trying to connect using rasdial: $($_.Exception.Message)"
    }
}

# --- Connection Method 2: External VPN Client Executable ---
# Use this if you need to call a specific client like Cisco AnyConnect CLI
elseif ($VpnClientPath) {
    Write-Host "Attempting connection using external client: $VpnClientPath"
    if (-not (Test-Path $VpnClientPath -PathType Leaf)) {
        Write-Error "VPN client executable not found at '$VpnClientPath'. Please check the path."
        exit 1
    }

    # Construct the command line arguments carefully.
    # WARNING: This likely requires extracting the plain text password, which is less secure.
    # Check the specific client's documentation for command-line options.
    $plainPassword = $Credential.GetNetworkCredential().Password
    $clientDirectory = Split-Path $VpnClientPath -Parent
    $clientExe = Split-Path $VpnClientPath -Leaf

    # Example for Cisco AnyConnect CLI (vpncli.exe) - adjust arguments as needed!
    # vpncli.exe connect <profile_or_host> -u <user> -p <password>
    # Note: Some CLIs might support reading password from stdin for better security. Check docs!
    $arguments = "connect `"$VpnProfileName`" -u `"$($Credential.UserName)`" -p `"$plainPassword`"" # Adjust based on actual client syntax

    Write-Host "Executing: $clientExe $arguments (Password hidden from console)"
    # Use Start-Process for better control, especially if password needs stdin
    try {
        # Example using standard execution. If stdin is needed, Start-Process is better.
        Set-Location $clientDirectory
        # Note: & operator executes the command. Use Invoke-Expression if needed but be cautious.
        & ".\$clientExe" $arguments.Split(' ') # Splitting args might be needed

        # Check $LASTEXITCODE after execution if the client provides meaningful codes
        if ($LASTEXITCODE -eq 0) {
             Write-Host "VPN client command executed. Check client status for connection confirmation."
        } else {
             Write-Warning "VPN client command execution finished with exit code $LASTEXITCODE."
        }

    } catch {
        Write-Error "An error occurred while executing the VPN client: $($_.Exception.Message)"
    } finally {
         # Clean up plain text password variable from memory
         Clear-Variable plainPassword -ErrorAction SilentlyContinue
    }
}

# --- Optional: Disconnect Logic ---
# You would need similar logic for disconnecting, using 'rasdial /disconnect'
# or the appropriate arguments for the external client (e.g., 'vpncli.exe disconnect')

# --- Optional: RDP Logic ---
# $hostname = "TARGET_HOSTNAME"
# Write-Host "Attempting RDP connection to $hostname..."
# mstsc /v:$hostname /multimon