#Requires -Modules Hyper-V

<#
.SYNOPSIS
Creates and configures a new Windows Server 2022 Hyper-V Virtual Machine using an unattended XML file.

.DESCRIPTION
This script automates the creation of a Gen 2 Hyper-V VM, attaches a prepared template VHDX,
injects a customized unattend.xml file for initial OS configuration (hostname, network, admin password, etc.),
and starts the VM to begin the unattended installation.

Requires a sysprepped Windows Server 2022 template VHDX and a base unattend.xml file.

Ensure the Hyper-V role or management tools are installed on the machine running this script.
Run this script with elevated privileges.

.PARAMETER VMName
The desired name for the new Virtual Machine. This will also be set as the computer name inside the OS via unattend.xml.

.PARAMETER CpuCount
The number of virtual processors to assign to the VM.

.PARAMETER RAMCount
The amount of startup memory for the VM (e.g., 2GB, 4096MB).

.PARAMETER IPAddress
The static IPv4 address for the VM's primary network adapter.

.PARAMETER SubnetPrefixLength
The subnet prefix length (CIDR notation) for the IPAddress (e.g., 24 for 255.255.255.0).

.PARAMETER DefaultGateway
The default gateway address for the VM's network.

.PARAMETER DNSServer
The primary DNS server address for the VM's network.

.PARAMETER DNSDomain
The DNS domain name the machine will join or use for suffix search (optional).

.PARAMETER SwitchName
The name of the Hyper-V Virtual Switch to connect the VM's network adapter to.

.PARAMETER NetworkAdapterName
The name to assign to the VM's network adapter (e.g., "Ethernet", "Public"). This name MUST be referenced in the unattend.xml for network settings.

.PARAMETER AdminAccount
The name for the local administrator account (usually "Administrator").

.PARAMETER AdminPasswordSecure
A SecureString object containing the desired password for the local administrator account.
Use: $securePassword = Read-Host -AsSecureString "Enter Admin Password"

.PARAMETER Organization
The organization name to be set in the OS.

.PARAMETER AVMAKey
The Automatic Virtual Machine Activation (AVMA) key for the desired Windows Server 2022 edition (Datacenter, Standard).
Default is Server 2022 Datacenter. Verify this key is appropriate for your host and guest edition.

.PARAMETER VMPath
The base path where the VM configuration files will be stored. Defaults to the Hyper-V host's default VM path.

.PARAMETER TemplateVHDXPath
The full path to the generalized (sysprepped) Windows Server 2022 template VHDX file.

.PARAMETER BaseUnattendXmlPath
The full path to the base unattend.xml file containing placeholders to be replaced.

.PARAMETER AutoStartVM
Switch parameter. If present, the script will start the VM after configuration.

.EXAMPLE
PS C:\> $securePassword = Read-Host -AsSecureString "Enter Admin Password"
PS C:\> .\New-UnattendedVM.ps1 -VMName "MyServer2022" -AdminPasswordSecure $securePassword

.EXAMPLE
PS C:\> $securePassword = Read-Host -AsSecureString "Enter Admin Password"
PS C:\> .\New-UnattendedVM.ps1 -VMName "WebApp01" -CpuCount 4 -RAMCount 8GB -IPAddress "10.1.1.50" -SubnetPrefixLength 24 -DefaultGateway "10.1.1.1" -DNSServer "10.1.1.10" -SwitchName "ExternalSwitch" -TemplateVHDXPath "C:\Templates\WS2022_Template.vhdx" -BaseUnattendXmlPath "C:\Templates\unattend_ws2022_base.xml" -AdminPasswordSecure $securePassword -AutoStartVM

.NOTES
Requirements for base unattend.xml:
- Must be a valid unattend.xml file for Windows Server 2022 setup.
- Must contain unique placeholders that this script replaces. Recommended placeholders:
    @@AdminAccount@@
    @@AdminPassword@@
    @@ComputerName@@
    @@Organization@@
    @@ProductID@@
    @@IPAddress@@
    @@SubnetPrefixLength@@  (Or SubnetMask - adjust script/XML accordingly)
    @@DefaultGateway@@
    @@DNSServer@@
    @@DNSDomain@@
    @@NetworkAdapterName@@ (Used to target the correct adapter for static IP config within the XML)
- The network configuration section in the unattend.xml *must* target the adapter by interface name (using the placeholder @@NetworkAdapterName@@) rather than MAC address.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$VMName,

    [int]$CpuCount = 2,

    [string]$RAMCount = "2GB", # Use standard units like GB, MB

    [Parameter(Mandatory=$true)]
    [System.Net.IPAddress]$IPAddress,

    [int]$SubnetPrefixLength = 24,

    [Parameter(Mandatory=$true)]
    [System.Net.IPAddress]$DefaultGateway,

    [Parameter(Mandatory=$true)]
    [System.Net.IPAddress]$DNSServer,

    [string]$DNSDomain = "", # Optional

    [Parameter(Mandatory=$true)]
    [string]$SwitchName,

    [string]$NetworkAdapterName = "Ethernet",

    [string]$AdminAccount = "Administrator",

    [Parameter(Mandatory=$true)]
    [System.Security.SecureString]$AdminPasswordSecure,

    [string]$Organization = "My Organization",

    # --- Windows Server 2022 AVMA Keys ---
    # Datacenter: WX4NM-KYWYW-QJJR4-XV3QB-6VM33
    # Standard:   VDYBN-27WPP-V4HQT-9VMD4-VMK7H
    # Essentials: B69WH-PRNHK-BXVK3-P9XF7-XD84W
    [string]$AVMAKey = "WX4NM-KYWYW-QJJR4-XV3QB-6VM33", # Default: Server 2022 Datacenter

    [string]$VMPath = (Get-VMHost).VirtualMachinePath,

    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$TemplateVHDXPath,

    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$BaseUnattendXmlPath,

    [switch]$AutoStartVM
)

# Convert SecureString password to plain text for XML injection ( unavoidable for unattend.xml)
$AdminPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($AdminPasswordSecure)
)

# --- Derived Variables ---
$VMDirectory = Join-Path -Path $VMPath -ChildPath $VMName
$VHDPath = Join-Path -Path $VMDirectory -ChildPath ($VMName + ".vhdx")
$UnattendTargetPath = Join-Path -Path $VMDirectory -ChildPath "unattend.xml" # Store generated XML with VM files

# --- Start Script ---
Write-Verbose "Starting VM Creation Process for '$VMName'"
Write-Verbose "Validating parameters and prerequisites..."

# Check if VM already exists
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    Write-Error "A Virtual Machine with the name '$VMName' already exists. Aborting."
    return
}

# Check if Hyper-V switch exists
if (-not (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue)) {
    Write-Error "Hyper-V switch '$SwitchName' not found. Aborting."
    return
}

# Create VM Directory if it doesn't exist
if (-not (Test-Path -Path $VMDirectory -PathType Container)) {
    Write-Verbose "Creating VM directory: $VMDirectory"
    New-Item -Path $VMDirectory -ItemType Directory -Force | Out-Null
}

Write-Host "Creating new Generation 2 VM: '$VMName'" -ForegroundColor Green

try {
    # Create the VM without a VHD initially
    New-VM -Name $VMName -Path $VMPath -MemoryStartupBytes $RAMCount -Generation 2 -NoVHD -ErrorAction Stop

    Write-Verbose "Setting VM Processor Count to $CpuCount"
    Set-VM -Name $VMName -ProcessorCount $CpuCount -ErrorAction Stop

    Write-Verbose "Configuring Automatic Start/Stop Actions"
    Set-VM -Name $VMName -AutomaticStartAction Start -AutomaticStopAction ShutDown -AutomaticStartDelay 5 -ErrorAction Stop

    Write-Verbose "Removing default network adapter (if any)"
    Get-VMNetworkAdapter -VMName $VMName | Remove-VMNetworkAdapter -ErrorAction SilentlyContinue # Ignore error if none exists

    Write-Verbose "Adding Network Adapter '$NetworkAdapterName' connected to '$SwitchName'"
    Add-VMNetworkAdapter -VMName $VMName -SwitchName $SwitchName -Name $NetworkAdapterName -DeviceNaming On -ErrorAction Stop # Use DeviceNaming

    Write-Verbose "Copying template VHDX '$TemplateVHDXPath' to '$VHDPath'"
    Copy-Item -Path $TemplateVHDXPath -Destination $VHDPath -Force -ErrorAction Stop

    Write-Verbose "Attaching VHDX '$VHDPath' to VM '$VMName'"
    Add-VMHardDiskDrive -VMName $VMName -ControllerType SCSI -Path $VHDPath -ErrorAction Stop

    Write-Verbose "Setting first boot device to the attached VHDX"
    $HardDiskDrive = Get-VMHardDiskDrive -VMName $VMName | Where-Object { $_.Path -eq $VHDPath }
    if ($HardDiskDrive) {
        Get-VMFirmware -VMName $VMName | Set-VMFirmware -FirstBootDevice $HardDiskDrive -ErrorAction Stop
    } else {
        Write-Error "Could not find the attached VHD drive object for '$VMName'. Cannot set boot order."
        # Consider removing the VM here if this fails critically
        # Remove-VM -Name $VMName -Force
        return
    }

    Write-Host "Preparing Unattend.xml file..." -ForegroundColor Green
    Write-Verbose "Reading base unattend file: $BaseUnattendXmlPath"
    $UnattendContent = Get-Content -Path $BaseUnattendXmlPath -Raw -ErrorAction Stop

    Write-Verbose "Replacing placeholders in unattend.xml content..."
    $UnattendContent = $UnattendContent -replace '@@AdminAccount@@', $AdminAccount `
                                         -replace '@@AdminPassword@@', $AdminPasswordPlain `
                                         -replace '@@ComputerName@@', $VMName `
                                         -replace '@@Organization@@', $Organization `
                                         -replace '@@ProductID@@', $AVMAKey `
                                         -replace '@@IPAddress@@', $IPAddress.IPAddressToString `
                                         -replace '@@SubnetPrefixLength@@', $SubnetPrefixLength `
                                         -replace '@@DefaultGateway@@', $DefaultGateway.IPAddressToString `
                                         -replace '@@DNSServer@@', $DNSServer.IPAddressToString `
                                         -replace '@@DNSDomain@@', $DNSDomain `
                                         -replace '@@NetworkAdapterName@@', $NetworkAdapterName

    Write-Verbose "Saving customized unattend.xml to: $UnattendTargetPath"
    Set-Content -Path $UnattendTargetPath -Value $UnattendContent -Encoding UTF8 -Force -ErrorAction Stop # Ensure UTF8 for XML

    Write-Host "Injecting Unattend.xml into VHDX..." -ForegroundColor Green
    Write-Verbose "Mounting VHDX: $VHDPath"
    $MountResult = Mount-Vhd -Path $VHDPath -Passthru -ErrorAction Stop

    # Find the Windows volume drive letter within the mounted VHD
    $VolumeDriveLetter = $null
    $Disk = $MountResult | Get-Disk
    $Partitions = $Disk | Get-Partition | Where-Object { $_.Type -ne 'Recovery' -and $_.IsBoot -eq $false -and $_.DriveLetter } # Try to find non-boot, non-recovery with a letter
    if ($Partitions.Count -eq 1) {
        $Volume = $Partitions | Get-Volume
        $VolumeDriveLetter = $Volume.DriveLetter
        Write-Verbose "Found mounted volume at drive letter: $VolumeDriveLetter"
    } else {
        # Fallback: Find the largest NTFS partition with a drive letter
        $Volume = $MountResult | Get-Disk | Get-Partition | Where-Object { $_.DriveLetter -and $_.Type -ne 'Recovery' } | Get-Volume | Where-Object { $_.FileSystem -eq 'NTFS' } | Sort-Object Size -Descending | Select-Object -First 1
         if ($Volume) {
            $VolumeDriveLetter = $Volume.DriveLetter
            Write-Verbose "Found volume (fallback method) at drive letter: $VolumeDriveLetter"
         } else {
            Write-Error "Could not determine the correct drive letter for the mounted VHDX system volume."
            Dismount-Vhd -Path $VHDPath -ErrorAction SilentlyContinue
            # Remove-VM -Name $VMName -Force # Optional cleanup
            return
         }
    }

    $TargetUnattendPath = Join-Path -Path ($VolumeDriveLetter + ":\") -ChildPath "unattend.xml"
    Write-Verbose "Copying '$UnattendTargetPath' to '$TargetUnattendPath'"
    Copy-Item -Path $UnattendTargetPath -Destination $TargetUnattendPath -Force -ErrorAction Stop

    Write-Verbose "Dismounting VHDX: $VHDPath"
    Dismount-Vhd -Path $VHDPath -ErrorAction Stop

    Write-Host "VM '$VMName' created and configured successfully." -ForegroundColor Green

    if ($AutoStartVM) {
        Write-Host "Starting VM '$VMName'..." -ForegroundColor Green
        Start-VM -Name $VMName
    } else {
        Write-Host "VM '$VMName' is ready. Start it manually to begin unattended setup."
    }

} catch {
    Write-Error "An error occurred during VM creation or configuration for '$VMName':"
    Write-Error $_.Exception.Message
    Write-Error "Script execution halted."

    # Optional: Attempt cleanup if VM exists partially
    if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
        Write-Warning "Attempting cleanup: Removing VM '$VMName' due to error..."
        Stop-VM -Name $VMName -Force -ErrorAction SilentlyContinue # Stop first if running
        # Ensure VHD is dismounted before deleting VM files
        if ( (Get-VHD -Path $VHDPath -ErrorAction SilentlyContinue).Attached ) {
             Dismount-Vhd -Path $VHDPath -Force -ErrorAction SilentlyContinue
        }
        Remove-VM -Name $VMName -Force -ErrorAction SilentlyContinue
        if (Test-Path -Path $VMDirectory -PathType Container) {
            Write-Warning "Removing VM directory: $VMDirectory"
            Remove-Item -Path $VMDirectory -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
} finally {
    # Clean up plain text password variable from memory
    if ($AdminPasswordPlain) {
        Clear-Variable AdminPasswordPlain
    }
    # Ensure VHD is dismounted in case of script exit/failure after mount
     if ($VHDPath -and (Test-Path $VHDPath) -and (Get-VHD -Path $VHDPath -ErrorAction SilentlyContinue).Attached ) {
         Write-Verbose "Ensuring VHD is dismounted: $VHDPath"
         Dismount-Vhd -Path $VHDPath -Force -ErrorAction SilentlyContinue
     }
}

Write-Verbose "Script finished for '$VMName'."