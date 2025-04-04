<#
.SYNOPSIS
Scans a network subnet for active hosts using PowerShell Core 7+. Attempts cross-platform compatibility.

.DESCRIPTION
This script pings a range of IP addresses within a specified subnet to identify online hosts.
For reachable hosts, it attempts to resolve their hostname using .NET DNS methods and retrieve
their MAC address using platform-specific commands (Get-NetNeighbor on Windows, ip/arp on Linux/macOS).
It leverages PowerShell 7+ parallel processing for speed.

.PARAMETER Subnet
The first three octets of the IPv4 subnet to scan (e.g., "192.168.1.").
Defaults to "192.168.0.".

.PARAMETER StartRange
The starting number for the last octet (e.g., 1).
Defaults to 1.

.PARAMETER EndRange
The ending number for the last octet (e.g., 254).
Defaults to 254.

.PARAMETER TimeoutSeconds
The time in seconds to wait for a ping response from each host.
Defaults to 1.

.PARAMETER ThrottleLimit
The maximum number of parallel threads to use for pinging. Adjust based on system resources.
Defaults to 32.

.EXAMPLE
.\Scan-Subnet-CrossPlatform.ps1 -Subnet "192.168.0." -StartRange 1 -EndRange 100 -Verbose

.EXAMPLE
.\Scan-Subnet-CrossPlatform.ps1 -Subnet "10.1.10."

.OUTPUTS
PSCustomObject objects containing IPAddress, Status, Hostname, MACAddress, and ResponseTime properties for reachable hosts.

.NOTES
Requires PowerShell 7.0 or higher for ForEach-Object -Parallel and automatic OS variables ($IsWindows, etc.).
Hostname resolution uses .NET DNS methods.
MAC address retrieval depends on OS-specific commands and local ARP/neighbor cache population.
Run with elevated privileges (Administrator/sudo) for potentially more reliable results, especially for MAC lookup.
MAC address parsing for Linux/macOS relies on specific output formats of 'ip' or 'arp' commands.
#>
param(
    [Parameter(Mandatory=$false)]
    [string]$Subnet = "192.168.0.",

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,254)]
    [int]$StartRange = 1,

    [Parameter(Mandatory=$false)]
    [ValidateRange(1,254)]
    [int]$EndRange = 254,

    [Parameter(Mandatory=$false)]
    [int]$TimeoutSeconds = 1,

    [Parameter(Mandatory=$false)]
    [int]$ThrottleLimit = 32
)

# Ensure the subnet string ends with a dot
if (-not $Subnet.EndsWith('.')) {
    $Subnet += '.'
}

Write-Verbose "Scanning subnet $($Subnet)$($StartRange) - $($Subnet)$($EndRange)"
Write-Verbose "Timeout: $($TimeoutSeconds)s | Parallelism: $ThrottleLimit"
Write-Verbose "Operating System: $($PSVersionTable.OS)"

$ipRange = $StartRange..$EndRange | ForEach-Object { "$($Subnet)$_" }

# --- Phase 1: Ping Scan (Parallel) ---
Write-Host "Phase 1: Pinging IPs..." -ForegroundColor Cyan
$pingResults = $ipRange | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
    # Variables needed inside the parallel scriptblock must be passed using $using:
    $currentTarget = $_
    $timeout = $using:TimeoutSeconds

    # Test-Connection is generally cross-platform in PS 7+
    $pingSuccess = Test-Connection -ComputerName $currentTarget -Count 1 -TimeoutSeconds $timeout -Quiet -ErrorAction SilentlyContinue

    if ($pingSuccess) {
        # Getting response time requires not using -Quiet, handle potential errors
        $responseTime = $null # Default value
        try {
             # Use -TimeToLive to potentially speed up failure detection slightly if needed, but focus on TimeoutSeconds
             $detailedPing = Test-Connection -ComputerName $currentTarget -Count 1 -TimeoutSeconds $timeout -ErrorAction Stop
             if ($detailedPing) { # Ensure we got an object back
                $responseTime = $detailedPing.ResponseTime
             }
        } catch {
            # If detailed ping fails after Quiet succeeded (rare), mark as 0 or handle
             # Assign error message to variable before using in Write-Warning
             $errorMessage = $_.Exception.Message
             Write-Warning "Detailed ping failed for $currentTarget after initial success: $errorMessage"
             $responseTime = 0 # Or $null, or specific error indicator
        }
        # Output an object for successful pings
        [PSCustomObject]@{
            IPAddress    = $currentTarget
            PingStatus   = 'Online'
            ResponseTime = $responseTime # In milliseconds
        }
    } else {
        # Optionally output offline status if needed, otherwise just skip
        # [PSCustomObject]@{ IPAddress = $currentTarget; PingStatus = 'Offline'; ResponseTime = $null }
    }
} # End Parallel Foreach

Write-Host "Phase 1 Complete: Found $($pingResults.Count) responsive hosts." -ForegroundColor Green

# --- Phase 2: Gather Details (Hostname & MAC) ---
Write-Host "Phase 2: Resolving Hostnames and MAC Addresses..." -ForegroundColor Cyan
$finalResults = foreach ($result in $pingResults) {
    $ip = $result.IPAddress
    $hostname = "N/A" # Default value
    $macAddress = "N/A" # Default value

    # --- Attempt DNS Resolution (Cross-Platform) ---
    try {
        Write-Verbose "Resolving hostname for $ip"
        # Use .NET DNS resolution - generally works cross-platform
        $dnsEntry = [System.Net.Dns]::GetHostEntry($ip)
        if ($dnsEntry -and $dnsEntry.HostName -ne $ip) { # Check if hostname is different from IP
            $hostname = $dnsEntry.HostName
        } else {
            $hostname = "N/A (No PTR Record)"
        }
    } catch [System.Net.Sockets.SocketException] {
        # Specific exception for DNS lookup failures
        # Assign error message to variable before using in Write-Verbose
        $errorMessage = $_.Exception.Message
        Write-Verbose "DNS lookup failed for ${ip}: $errorMessage"
        $hostname = "N/A (DNS Lookup Failed)"
    } catch {
        # Catch other potential errors during DNS lookup
        # Assign error message to variable before using in Write-Warning
        $errorMessage = $_.Exception.Message
        Write-Warning "Error resolving hostname for ${ip}: $errorMessage"
        $hostname = "N/A (Error)"
    }

    # --- Attempt MAC Address Retrieval (OS Specific) ---
    try {
        Write-Verbose "Getting MAC address for $ip"

        if ($IsWindows) {
            # Try Get-NetNeighbor first (modern Windows)
            try {
                 # Filter by IP and ensure state is Reachable or Stale (often still valid)
                 # Use -ErrorAction Stop to catch if the cmdlet itself is missing
                $neighbor = Get-NetNeighbor -IPAddress $ip -ErrorAction Stop | Where-Object {$_.State -in 'Reachable', 'Stale', 'Permanent'}
                if ($neighbor) {
                    # Select the first entry if multiple exist (unlikely for a single IP)
                    $macAddress = ($neighbor[0].LinkLayerAddress.ToUpper() -replace '[\-:]','').Trim()
                } else {
                    $macAddress = "N/A (Not in Cache)"
                }
            } catch {
                 # Assign error message to variable before using in Write-Warning
                 $errorMessage = $_.Exception.Message
                 Write-Warning "Get-NetNeighbor failed for $ip (may not be available or require elevation): $errorMessage"
                 # Fallback to arp -a parsing if Get-NetNeighbor fails or isn't found
                 Write-Verbose "Falling back to 'arp -a' for $ip on Windows"
                 $arpOutput = arp -a $ip | Select-String -Pattern $ip # Find the line containing the IP
                 if ($arpOutput -match '([0-9A-Fa-f]{2}[-:]){5}[0-9A-Fa-f]{2}') { # Regex to find MAC
                     $macAddress = ($Matches[0].ToUpper() -replace '[\-:]','').Trim()
                 } else {
                     $macAddress = "N/A (ARP Failed)"
                 }
            }

        } elseif ($IsLinux) {
            # Try 'ip neigh' first (modern Linux)
            $ipNeighOutput = ip neigh show $ip 2>$null # Redirect errors
            if ($ipNeighOutput -match 'lladdr\s+(([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2})') {
                $macAddress = ($Matches[1].ToUpper() -replace ':','').Trim()
            } else {
                # Fallback to 'arp -n'
                Write-Verbose "Falling back to 'arp -n' for $ip on Linux"
                $arpOutput = arp -n $ip 2>$null | Select-String -Pattern $ip
                # Example arp -n output: ? (192.168.1.1) at 00:11:22:aa:bb:cc [ether] on eth0
                if ($arpOutput -match '\s+(([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2})\s+') {
                     $macAddress = ($Matches[1].ToUpper() -replace ':','').Trim()
                } else {
                    $macAddress = "N/A (ip/arp Failed)"
                }
            }

        } elseif ($IsMacOs) {
            # Use 'arp -n' on macOS
            $arpOutput = arp -n $ip 2>$null | Select-String -Pattern $ip
            # Example arp -n output: ? (192.168.1.1) at 0:11:22:aa:bb:cc on en0 ifscope [ethernet]
            if ($arpOutput -match '\s+(([0-9a-fA-F]{1,2}:){5}[0-9a-fA-F]{1,2})\s+') { # MAC format can vary slightly
                 $macAddress = ($Matches[1].ToUpper() -replace ':','').Trim()
                 # Pad single hex digits with leading zero if necessary (e.g., 0: instead of 00:)
                 $macAddress = ($macAddress.Split(':') | ForEach-Object { $_.PadLeft(2,'0') }) -join ''
            } else {
                $macAddress = "N/A (ARP Failed)"
            }
        } else {
            # Unsupported OS for automatic MAC lookup
            $macAddress = "N/A (OS Unsupported)"
        }

        # Final check if MAC is empty or just whitespace after processing
        if ([string]::IsNullOrWhiteSpace($macAddress) -or $macAddress -like "N/A*") {
             $macAddress = "N/A (Not Found)"
        }

    } catch {
        # Catch errors during MAC lookup process
        # Assign error message to variable before using in Write-Warning
        $errorMessage = $_.Exception.Message
        Write-Warning "Error getting MAC for ${ip}: $errorMessage"
        $macAddress = "N/A (Error)"
    }

    # Output the combined object
    [PSCustomObject]@{
        IPAddress    = $ip
        Status       = $result.PingStatus
        Hostname     = $hostname
        MACAddress   = $macAddress
        ResponseTime = $result.ResponseTime
    }
}

Write-Host "Phase 2 Complete." -ForegroundColor Green

# --- Display Output ---
Write-Host "`nScan Results:" -ForegroundColor Yellow
# Filter out results where MAC address lookup failed if desired
# $finalResults | Where-Object {$_.MACAddress -ne "N/A (Not Found)"} | Format-Table
$finalResults | Format-Table

# --- Optional: Output to CSV ---
# $FileOut = "C:\Temp\ScannedComputers_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
# # On Linux/macOS, you might want a different default path:
# # $FileOut = "./ScannedComputers_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
# try {
#     $finalResults | Export-Csv -Path $FileOut -NoTypeInformation -Encoding UTF8 -ErrorAction Stop
#     Write-Host "`nResults exported to $FileOut" -ForegroundColor Green
# } catch {
#     Write-Error "Failed to export results to $FileOut: $($_.Exception.Message)"
# }


# --- Optional: Output to GridView (Requires GUI environment, primarily Windows) ---
# Out-GridView is typically Windows-only or requires specific X11 setup on Linux/macOS
# if ($IsWindows) {
#     try {
#         Write-Host "`nOpening results in Out-GridView..." -ForegroundColor Green
#         $finalResults | Out-GridView -Title "Network Scan Results"
#     } catch {
#         Write-Warning "Out-GridView might not be available or failed: $($_.Exception.Message)"
#     }
# } else {
#      Write-Host "`nOut-GridView skipped (non-Windows environment)." -ForegroundColor Yellow
# }
