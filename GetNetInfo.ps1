Get-NetAdapter | Select-Object $env:COMPUTERNAME, MacAddress, NetworkAddresses, InterfaceAlias, LinkSpeed, AdminStatus | Export-Csv -Path C:\ExportDir\NETinfo.csv -NoTypeInformation
Get-NetIPAddress | Select-Object IPv4Address | Export-Csv -Path C:\ExportDir\IPinfo.csv -NoTypeInformation
Get-ADComputer -Properties IPv4Address | Format-Table Name, IPv4Address -AutoSize
