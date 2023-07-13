# Get Installed Software
Get-WmiObject -Class Win32_Product | Select-Object -Property Vendor,Name,Version,InstallDate | Sort-Object Vendor | Format-Table -AutoSize

# Get Installed Apps
Get-AppxPackage | Select-Object Name, Version