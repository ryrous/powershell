# Cross-platform Temp Cleanup Script
# Requires PowerShell 6+ (Core)

function Ensure-Elevated {
    if ($IsWindows) {
        # Check if the current process is running as Administrator.
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
            Write-Host "Not running as Administrator. Attempting to re-launch with elevated privileges..."
            
            # Re-run this script as Administrator:
            Start-Process pwsh -Verb runAs -ArgumentList @(
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-File", "`"$PSCommandPath`""
            )
            
            # Exit this non-elevated process.
            exit
        }
    }
    elseif ($IsLinux -or $IsMacOS) {
        # Check if the current process is running as root (id -u == 0).
        $userId = & id -u
        if ($userId -ne 0) {
            Write-Host "Not running as root. Attempting to re-launch with sudo..."
            
            # Re-run this script with sudo:
            sudo pwsh -NoProfile -ExecutionPolicy Bypass -File "$PSCommandPath"
            
            # Exit this non-elevated process.
            exit
        }
    }
    else {
        Write-Warning "Unrecognized operating system. Cannot attempt elevation."
    }
}

# Call the function to ensure we have elevated privileges.
Ensure-Elevated

Write-Host "Script is running with elevated privileges."

# --- Now continue with your cleanup logic ---

if ($IsWindows) {
    Write-Output "Detected Windows OS. Cleaning temporary directories..."
    
    $windowsPaths = @(
        "C:\Windows\Temp",
        "C:\Windows\SoftwareDistribution\Download",
        "C:\Users\$Env:USERNAME\AppData\Local\Temp",
        "C:\Users\$Env:USERNAME\Downloads",
        "C:\Users\$Env:USERNAME\Desktop"
    )
    
    foreach ($path in $windowsPaths) {
        if (Test-Path $path) {
            try {
                Get-ChildItem -Path $path -Recurse -Force |
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                Write-Output "Cleaned: $path"
            }
            catch {
                Write-Warning "Failed to clean $($path): $($_)"
            }
        }
        else {
            Write-Output "Path not found: $path"
        }
    }
}
elseif ($IsLinux -or $IsMacOS) {
    Write-Output "Detected Linux/macOS. Cleaning temporary directories..."
    
    $tempPaths = @(
        "/tmp",
        "/var/tmp"
    )
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            try {
                Get-ChildItem -Path $path -Recurse -Force |
                    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                Write-Output "Cleaned: $path"
            }
            catch {
                Write-Warning "Failed to clean $($path): $($_)"
            }
        }
        else {
            Write-Output "Path not found: $path"
        }
    }
}
else {
    Write-Warning "Unrecognized operating system. Exiting script."
}