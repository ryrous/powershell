function Get-PCinfo {
    Write-Host "Getting PowerShell Version.." -ForegroundColor Magenta
    Get-Host | Select-Object InstanceID, Version, DebuggerEnabled, IsRunspacePushed | Format-Table -AutoSize

    Write-Host "Getting LoggedOn User.." -ForegroundColor Magenta
    Get-WMIObject Win32_LoggedOnUser | Select-Object __Server, Antecedent, Dependent | Format-Table -AutoSize

    Write-Host "Getting BIOS Version.." -ForegroundColor Magenta
    Get-WMIObject Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate, SerialNumber | Format-Table -AutoSize

    Write-Host "Getting CPU Info.." -ForegroundColor Magenta
    Get-WMIObject Win32_Processor | Select-Object Name, MaxClockSpeed, NumberOfCores | Format-Table -AutoSize

    Write-Host "Getting CPU Usage.." -ForegroundColor Magenta
    Get-Process | Where-Object Path -notlike ($env:WINDIR + "*") | Sort-Object CPU | Select-Object Name, CPU, StartTime | Select-Object -Last 10 | Sort-Object CPU -Descending | Format-Table -AutoSize

    Write-Host "Getting Disk info.." -ForegroundColor Magenta
    Get-Disk | Format-Table -AutoSize

    Write-Host "Getting Disk Status.." -ForegroundColor Magenta
    Get-Volume | Where-Object DriveLetter -EQ "C" | Format-Table -AutoSize

    Write-Host "Getting Network Adapter info.." -ForegroundColor Magenta
    Get-NetAdapter | Sort-Object Name | Format-Table -AutoSize

    Write-Host "Getting Network Connection info.." -ForegroundColor Magenta
    Get-NetConnectionProfile | Select-Object Name, InterfaceAlias, IPv4Connectivity, IPv6Connectivity, NetworkCategory | Format-Table -AutoSize

    Write-Host "Getting IP Addresses.." -ForegroundColor Magenta
    Get-NetIPAddress | Select-Object InterfaceAlias, IPAddress | Sort-Object InterfaceAlias | Format-Table -AutoSize

    Write-Host "Getting DNS info.." -ForegroundColor Magenta
    Get-DnsClientServerAddress | Sort-Object InterfaceAlias | Format-Table -AutoSize

    Write-Host "Getting Licensing Status.."  -ForegroundColor Magenta
    cscript C:\Windows\System32\slmgr.vbs /dlv
}
Get-PCinfo
Read-Host -Prompt "Press Enter to exit"