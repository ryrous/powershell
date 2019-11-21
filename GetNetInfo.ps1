# Get Net Info
Get-NetAdapter | Where-Object Name -eq Ethernet | Select-Object $env:COMPUTERNAME, MacAddress, InterfaceAlias, LinkSpeed, AdminStatus | Export-Csv -Path C:\ExportDir\NETinfo.csv -NoTypeInformation
# Get IP Info
Get-NetIPAddress | Where-Object InterfaceAlias -eq Ethernet | Select-Object IPv4Address | Export-Csv -Path C:\ExportDir\IPinfo.csv -NoTypeInformation
