#Create Variables
$TargetOU = "OU=NameOfOU,DC=domain,DC=com"

#Export User Accounts to CSV for Reference
Search-ADAccount -SearchBase $TargetOU -AccountInactive -UsersOnly -TimeSpan 90.00:00:00 | Select-Object -Property SAMaccountname,Enabled,PasswordExpired,PasswordNeverExpires,LastLogonDate | Export-Csv C:\ExportDir\InactiveUsers.csv -NoTypeInformation
Search-ADAccount -SearchBase $TargetOU -AccountExpired -UsersOnly | Select-Object -Property SAMaccountname,Enabled,PasswordExpired,PasswordNeverExpires,LastLogonDate | Export-Csv C:\ExportDir\ExpiredUsers.csv -NoTypeInformation
Search-ADAccount -SearchBase $TargetOU -AccountDisabled -UsersOnly | Select-Object -Property SAMaccountname,Enabled,PasswordExpired,PasswordNeverExpires,LastLogonDate | Export-Csv C:\ExportDir\DisabledUsers.csv -NoTypeInformation

#Move User Accounts to new OU in AD
Search-ADAccount -SearchBase $TargetOU -AccountInactive -UsersOnly -TimeSpan 90.00:00:00 | Remove-ADUser
Search-ADAccount -SearchBase $TargetOU -AccountExpired -UsersOnly | Remove-ADUser
Search-ADAccount -SearchBase $TargetOU -AccountDisabled -UsersOnly | Remove-ADUser
