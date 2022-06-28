# Get Installed Software
Get-WmiObject -Class Win32_Product | Select-Object -Property Vendor,Name,Version,InstallDate | Sort-Object Vendor | Format-Table -AutoSize
