function Get-PCinfo {
    Write-Host "Getting PowerShell Version.." -ForegroundColor Magenta
    Get-Host

    Write-Host "Getting Network Adapter information.." -ForegroundColor Magenta
    Get-NetAdapter | Sort-Object Name | Format-Table

    Write-Host "Getting IP Addresses.." -ForegroundColor Magenta
    Get-NetIPAddress | Select-Object InterfaceAlias, IPAddress | Sort-Object InterfaceAlias | Format-Table

    Write-Host "Getting DNS information.." -ForegroundColor Magenta
    Get-DnsClientServerAddress | Sort-Object InterfaceAlias | Format-Table

    Write-Host "Getting Disk information.." -ForegroundColor Magenta
    Get-Disk | Format-Table

    Write-Host "Getting Disk Space.." -ForegroundColor Magenta
    Get-PSDrive | Sort-Object -Property Free -Descending | Format-Table

    Write-Host "Getting Volumes on Disk.." -ForegroundColor Magenta
    Get-Volume | Sort-Object SizeRemaining | Format-Table

    Write-Host "Getting CPU Usage.." -ForegroundColor Magenta
    Get-Process | Where-Object Path -notlike ($env:WINDIR + "*") | Sort-Object CPU | Select-Object Name, CPU, StartTime | Select-Object -Last 10 | Sort-Object CPU -Descending | Format-Table

    Write-Host "Getting Licensing Status.."  -ForegroundColor Magenta
    cscript C:\Windows\System32\slmgr.vbs /dlv
}
Get-PCinfo