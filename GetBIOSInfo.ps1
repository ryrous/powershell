### Display BIOS Information ###
Get-WMIObject Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate, SerialNumber | Format-Table
Read-Host -Prompt "Press Enter to exit"