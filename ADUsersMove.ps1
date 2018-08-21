#Export User Accounts to CSV for Reference
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountInactive -TimeSpan 90.00:00:00 | Select-Object -Property SAMaccountname, Enabled, PasswordExpired, PasswordNeverExpires, LastLogonDate | Export-Csv C:\ExportDir\InactiveUsers.csv -NoTypeInformation
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountExpired | Select-Object -Property SAMaccountname, Enabled, PasswordExpired, PasswordNeverExpires, LastLogonDate | Export-Csv C:\ExportDir\ExpiredUsers.csv -NoTypeInformation
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountDisabled | Select-Object -Property SAMaccountname, Enabled, PasswordExpired, PasswordNeverExpires, LastLogonDate | Export-Csv C:\ExportDir\DisabledUsers.csv -NoTypeInformation
#Create Variables
$InactiveUsers = (Import-Csv -Path C:\ExportDir\InactiveUsers.csv).SAMaccountname
$ExpiredUsers = (Import-Csv -Path C:\ExportDir\ExpiredUsers.csv).SAMaccountname
$DisabledUsers = (Import-Csv -Path C:\ExportDir\DisabledUsers.csv).SAMaccountname
$InactiveOU = "OU=InactiveUsers,OU=Users,DC=domain,DC=com"
$ExpiredOU = "OU=ExpiredUsers,OU=Users,DC=domain,DC=com"
$DisabledOU = "OU=DisabledUsers,OU=Users,DC=domain,DC=com"
#Move User Accounts to new OU in AD
Move-ADObject -Identity $InactiveUsers -TargetPath $InactiveOU
Move-ADObject -Identity $ExpiredUsers -TargetPath $ExpiredOU
Move-ADObject -Identity $DisabledUsers -TargetPath $DisabledOU
