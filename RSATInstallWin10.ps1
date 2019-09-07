<#
.SYNOPSIS
    Install RSAT features for Windows 10 1809 or 1903
    
.DESCRIPTION
    Install RSAT features for Windows 10 1809 or 1903. All features are installed online from Microsoft Update thus the script requires Internet access

.PARAM All
    Installs all the features within RSAT. This takes several minutes, depending on your Internet connection

.PARAM Basic
    Installs ADDS, DHCP, DNS, GPO, ServerManager

.PARAM ServerManager
    Installs ServerManager

.PARAM Uninstall
    Uninstalls all the RSAT features

.NOTES
    Filename: Install-RSATv1809v1903.ps1
    Version: 1.1
    Author: Martin Bengtsson
    Blog: www.imab.dk
    Twitter: @mwbengtsson
   
#> 

[CmdletBinding()]
param(
    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [switch]$All,
    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [switch]$Basic,
    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [switch]$ServerManager,
    [parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [switch]$Uninstall
)

# Check for administrative rights
if (-NOT([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning -Message "The script requires elevation"
    break
}

# Windows 10 1809 build
$1809Build = "17763"
# Windows 10 1903 build
$1903Build = "18362"
# Get running Windows build
$WindowsBuild = (Get-WmiObject -Class Win32_OperatingSystem).BuildNumber
# Getting executing directory - considering including the source files for RSAT to be installed from local source
#$runningDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

if (($WindowsBuild -eq $1809Build) -OR ($WindowsBuild -eq $1903Build)) {
    Write-Verbose -Verbose "Running correct Windows 10 build number for installing RSAT with Features on Demand. Build number is: $WindowsBuild"
    if ($PSBoundParameters["All"]) {
        Write-Verbose -Verbose "Script is running with -All parameter. Installing all available RSAT features"
        $Install = Get-WindowsCapability -Online | Where-Object {$_.Name -like "Rsat*" -AND $_.State -eq "NotPresent"}
        if ($null -ne $Install) {
            foreach ($Item in $Install) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Adding $RsatItem to Windows"
                try {
                    Add-WindowsCapability -Online -Name $RsatItem
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }
        }
        else {
            Write-Verbose -Verbose "All RSAT features seems to be installed already"
        }
    }

    if ($PSBoundParameters["Basic"]) {
        Write-Verbose -Verbose "Script is running with -Basic parameter. Installing basic RSAT features"
        # Querying for what I see as the basic features of RSAT. Modify this if you think something is missing. :-)
        $Install = Get-WindowsCapability -Online | Where-Object {$_.Name -like "Rsat.ActiveDirectory*" -OR $_.Name -like "Rsat.DHCP.Tools*" -OR $_.Name -like "Rsat.Dns.Tools*" -OR $_.Name -like "Rsat.GroupPolicy*" -AND $_.State -eq "NotPresent" }
        if ($null -ne $Install) {
            foreach ($Item in $Install) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Adding $RsatItem to Windows"
                try {
                    Add-WindowsCapability -Online -Name $RsatItem
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }
        }
        else {
            Write-Verbose -Verbose "The basic features of RSAT seems to be installed already"
        }
    }

    if ($PSBoundParameters["ServerManager"]) {
        Write-Verbose -Verbose "Script is running with -ServerManager parameter. Installing Server Manager RSAT feature"
        $Install = Get-WindowsCapability -Online | Where-Object {$_.Name -like "Rsat.ServerManager*" -AND $_.State -eq "NotPresent"} 
        if ($null -ne $Install) {
            $RsatItem = $Install.Name
            Write-Verbose -Verbose "Adding $RsatItem to Windows"
            try {
                Add-WindowsCapability -Online -Name $RsatItem
            }
            catch [System.Exception] {
                Write-Verbose -Verbose "Failed to add $RsatItem to Windows"
                Write-Warning -Message $_.Exception.Message ; break
            }
        }
        else {
            Write-Verbose -Verbose "$RsatItem seems to be installed already"
        }
    }

    if ($PSBoundParameters["Uninstall"]) {
        Write-Verbose -Verbose "Script is running with -Uninstall parameter. Uninstalling all RSAT features"
        # Querying for installed RSAT features first time
        $Installed = Get-WindowsCapability -Online | Where-Object {$_.Name -like "Rsat*" -AND $_.State -eq "Installed" -AND $_.Name -notlike "Rsat.ServerManager*" -AND $_.Name -notlike "Rsat.GroupPolicy*" -AND $_.Name -notlike "Rsat.ActiveDirectory*"} 
        if ($null -ne $Installed) {
            Write-Verbose -Verbose "Uninstalling the first round of RSAT features"
            # Uninstalling first round of RSAT features - some features seems to be locked until others are uninstalled first
            foreach ($Item in $Installed) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Uninstalling $RsatItem from Windows"
                try {
                    Remove-WindowsCapability -Name $RsatItem -Online
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to uninstall $RsatItem from Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            }       
        }
        # Querying for installed RSAT features second time
        $Installed = Get-WindowsCapability -Online | Where-Object {$_.Name -like "Rsat*" -AND $_.State -eq "Installed"}
        if ($null -ne $Installed) { 
            Write-Verbose -Verbose "Uninstalling the second round of RSAT features"
            # Uninstalling second round of RSAT features
            foreach ($Item in $Installed) {
                $RsatItem = $Item.Name
                Write-Verbose -Verbose "Uninstalling $RsatItem from Windows"
                try {
                    Remove-WindowsCapability -Name $RsatItem -Online
                }
                catch [System.Exception] {
                    Write-Verbose -Verbose "Failed to remove $RsatItem from Windows"
                    Write-Warning -Message $_.Exception.Message
                }
            } 
        }
        else {
            Write-Verbose -Verbose "All RSAT features seems to be uninstalled already"
        }
    }
}
else {
    Write-Warning -Message "Not running correct Windows 10 build: $WindowsBuild"
}