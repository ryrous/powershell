### Display CPU Information ###
Get-WMIObject Win32_Processor | Select-Object Name, MaxClockSpeed, NumberOfCores | Format-Table
Read-Host -Prompt "Press Enter to exit"