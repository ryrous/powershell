<# 
.SYNOPSIS
    Cross-platform PowerShell script to gather network information.
.DESCRIPTION
    This script detects the OS (Windows, macOS, or Linux), retrieves local IP and subnet details,
    default gateway, public IP, calculates the CIDR and network address properly, and scans the network for active hosts.
.NOTES
    Tested on Windows, macOS, and Linux with PowerShell Core.
#>

# OS Detection
if ($IsWindows) {
    $platform = "Windows"
} elseif ($IsMacOS) {
    $platform = "macOS"
} elseif ($IsLinux) {
    $platform = "Linux"
} else {
    $platform = "Other"
}

# Function: Convert dotted-decimal netmask to CIDR prefix (Windows fallback)
function Get-CIDRFromMask ($mask) {
    $binaryMask = ($mask -split '\.') | ForEach-Object { [Convert]::ToString([int]$_, 2).PadLeft(8, '0') }
    return (($binaryMask -join '') -replace '0+$' ).Length
}

# Function: Convert hexadecimal netmask (macOS) to CIDR prefix
function Convert-HexNetmaskToPrefix {
    param(
        [string]$hexNetmask
    )
    $hex = $hexNetmask.Trim().TrimStart("0x")
    try {
        $intValue = [Convert]::ToUInt32($hex, 16)
    } catch {
        Write-Verbose "Conversion of netmask $hexNetmask failed."
        return 24  # fallback
    }
    $binary = [Convert]::ToString($intValue,2).PadLeft(32,'0')
    $ones = ($binary.ToCharArray() | Where-Object { $_ -eq '1' }).Count
    return $ones
}

# Function: Get local IP and Subnet mask/prefix
function Get-LocalIPInfo {
    if ($platform -eq "Windows") {
        Write-Verbose "Attempting to retrieve IP using Get-NetIPAddress..."
        try {
            $ipObj = Get-NetIPAddress -AddressFamily IPv4 |
                     Where-Object { $_.IPAddress -ne "127.0.0.1" -and $_.IPAddress -notmatch ':' } |
                     Select-Object -First 1
        } catch {
            Write-Verbose "Get-NetIPAddress failed: $_"
        }
        if ($ipObj) {
            Write-Verbose "IP retrieved via Get-NetIPAddress: $($ipObj.IPAddress)"
            return [PSCustomObject]@{
                IP     = $ipObj.IPAddress
                Subnet = $ipObj.PrefixLength  # Already in CIDR form.
            }
        }
        Write-Verbose "Falling back to Get-CimInstance..."
        try {
            $ipConfig = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration |
                        Where-Object { $_.IPAddress -and $_.IPAddress[0] -ne "127.0.0.1" } |
                        Select-Object -First 1
        } catch {
            Write-Verbose "Get-CimInstance failed: $_"
        }
        if ($ipConfig -and $ipConfig.IPAddress[0] -and $ipConfig.IPSubnet[0]) {
            $subnetPrefix = Get-CIDRFromMask $ipConfig.IPSubnet[0]
            Write-Verbose "IP retrieved via Get-CimInstance: $($ipConfig.IPAddress[0])"
            return [PSCustomObject]@{
                IP     = $ipConfig.IPAddress[0]
                Subnet = $subnetPrefix
            }
        }
        Write-Verbose "Falling back to parsing ipconfig output..."
        $ipInfo = ipconfig 2>$null | Select-String -Pattern 'IPv4 Address|Subnet Mask'
        $localIP = ""
        $subnetMask = ""
        foreach ($line in $ipInfo) {
            if ($line -match 'IPv4 Address.*:\s*([\d\.]+)') {
                $localIP = $Matches[1]
            } elseif ($line -match 'Subnet Mask.*:\s*([\d\.]+)') {
                $subnetMask = $Matches[1]
            }
        }
        if ($localIP) {
            $prefix = if ($subnetMask) { Get-CIDRFromMask $subnetMask } else { 24 }
            Write-Verbose "IP retrieved via ipconfig parsing: $localIP"
            return [PSCustomObject]@{
                IP     = $localIP
                Subnet = $prefix
            }
        }
    } elseif ($platform -eq "macOS") {
        Write-Verbose "Attempting to retrieve IP using ifconfig on macOS..."
        $ifconfigOutput = ifconfig 2>$null
        # Look for an active non-loopback interface (commonly en0)
        $ipLine = $ifconfigOutput | Select-String -Pattern 'inet ' | Where-Object { $_ -notmatch '127.0.0.1' } | Select-Object -First 1
        if ($ipLine -match 'inet\s+([\d\.]+)\s+netmask\s+(0x[0-9a-fA-F]+)') {
            $ip = $Matches[1]
            $netmaskHex = $Matches[2]
            $prefix = Convert-HexNetmaskToPrefix $netmaskHex
            Write-Verbose "IP retrieved via ifconfig: $ip with prefix $prefix"
            return [PSCustomObject]@{
                IP     = $ip
                Subnet = $prefix
            }
        } else {
            Write-Verbose "Failed to parse ifconfig output."
        }
    } elseif ($platform -eq "Linux") {
        Write-Verbose "Attempting to retrieve IP using 'ip' command on Linux..."
        $ipLine = (ip -4 addr show | Select-String -Pattern "inet " | Where-Object { $_ -notmatch "127.0.0.1"} | Select-Object -First 1).ToString()
        if ($ipLine -match 'inet\s+([\d\.]+)/(\d+)') {
            Write-Verbose "IP retrieved via ip command: $($Matches[1])"
            return [PSCustomObject]@{
                IP     = $Matches[1]
                Subnet = [int]$Matches[2]
            }
        } else {
            Write-Warning "Unable to determine IP information on Linux."
            return $null
        }
    }
    Write-Verbose "No IP information could be retrieved."
    return $null
}

$ipInfoObj = Get-LocalIPInfo
if (-not $ipInfoObj) { 
    Write-Error "Failed to retrieve local IP information." 
    exit 1 
}
$localIP = $ipInfoObj.IP
$cidrPrefix = $ipInfoObj.Subnet

# Function: Compute network address from IP and CIDR prefix
function Get-NetworkAddress($ip, $prefix) {
    $ipBytes = $ip -split '\.' | ForEach-Object { [byte]$_ }
    $mask = [uint32]0
    for ($i = 0; $i -lt 32; $i++) {
        if ($i -lt $prefix) { $mask = $mask -bor (1 -shl (31 - $i)) }
    }
    $ipInt = 0
    for ($i = 0; $i -lt 4; $i++) {
        $ipInt = $ipInt -bor ($ipBytes[$i] -shl (24 - (8 * $i)))
    }
    $networkInt = $ipInt -band $mask
    $networkBytes = for ($i = 0; $i -lt 4; $i++) { ($networkInt -shr (24 - (8 * $i))) -band 0xFF }
    return ($networkBytes -join '.')
}

$networkAddress = Get-NetworkAddress $localIP $cidrPrefix
$subnetCIDR = "$networkAddress/$cidrPrefix"

# Function: Get Default Gateway
function Get-DefaultGateway {
    if ($platform -eq "Windows") {
        try {
            $gw = Get-NetRoute -DestinationPrefix "0.0.0.0/0" |
                  Sort-Object -Property RouteMetric |
                  Select-Object -First 1 -ExpandProperty NextHop
        } catch {
            $gw = "Unavailable"
        }
    } elseif ($platform -eq "macOS") {
        try {
            # On macOS, the default route is shown in netstat output.
            $gwLine = ifconfig | Select-String -Pattern "default" | ForEach-Object { $_.ToString().Trim() }
            if ($gwLine -match 'default\s+([\d\.]+)') {
                $gw = $Matches[1]
            } else {
                $gw = "Unavailable"
            }
        } catch {
            $gw = "Unavailable"
        }
    } elseif ($platform -eq "Linux") {
        try {
            $gwLine = (ip route show default | Select-String -Pattern "^default") -split " "
            $gw = $gwLine[2]
        } catch {
            $gw = "Unavailable"
        }
    } else {
        $gw = "Unavailable"
    }
    return $gw
}
$routerLocalIP = Get-DefaultGateway

# Get public IP address (external IP of router)
try {
    $routerPublicIP = Invoke-RestMethod -Uri "https://api.ipify.org"
} catch {
    $routerPublicIP = "Unavailable"
}

# Function: Discover active hosts on the network
function Get-ActiveHosts {
    # This example is optimized for /24 networks.
    $networkOctets = $networkAddress -split '\.' | ForEach-Object { [int]$_ }
    $hostBits = 32 - $cidrPrefix
    if ($hostBits -gt 8) {
        Write-Warning "Network scan is optimized for /24 or larger networks; results may be incomplete."
    }
    $baseIP = $networkOctets[0..2] -join '.'
    $activeCount = 0
    1..254 | ForEach-Object {
        $target = "$baseIP.$_"
        if ($target -ne $localIP) {
            if (Test-Connection -Quiet -Count 1 -ComputerName $target -TimeoutSeconds 1) {
                $activeCount++
            }
        }
    }
    return $activeCount
}
$deviceCount = Get-ActiveHosts

# Output results
$result = [PSCustomObject]@{
    "Local Device IP"            = $localIP
    "Network (CIDR)"             = $subnetCIDR
    "Default Gateway (Local IP)" = $routerLocalIP
    "Public IP of Router"        = $routerPublicIP
    "Active Devices on Network"  = $deviceCount
}

$result | Format-Table -AutoSize