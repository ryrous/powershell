#Create Variables
$TargetOU = "OU=NameOfOU,DC=domain,DC=com"
$InactiveOU = "OU=Inactive Users,OU=NameOfOU,DC=domain,DC=com"
$ExpiredOU = "OU=Expired Users,OU=NameOfOU,DC=domain,DC=com"
$DisabledOU = "OU=Disabled Users,OU=NameOfOU,DC=domain,DC=com"

#Export User Accounts to CSV for Reference
Search-ADAccount -SearchBase $TargetOU -AccountInactive -UsersOnly -TimeSpan 90.00:00:00 | Select-Object -Property SAMaccountname,Enabled,PasswordExpired,PasswordNeverExpires,LastLogonDate | Export-Csv C:\ExportDir\InactiveUsers.csv -NoTypeInformation
Search-ADAccount -SearchBase $TargetOU -AccountExpired -UsersOnly | Select-Object -Property SAMaccountname,Enabled,PasswordExpired,PasswordNeverExpires,LastLogonDate | Export-Csv C:\ExportDir\ExpiredUsers.csv -NoTypeInformation
Search-ADAccount -SearchBase $TargetOU -AccountDisabled -UsersOnly | Select-Object -Property SAMaccountname,Enabled,PasswordExpired,PasswordNeverExpires,LastLogonDate | Export-Csv C:\ExportDir\DisabledUsers.csv -NoTypeInformation

#Move User Accounts to new OU in AD
Search-ADAccount -SearchBase $TargetOU -AccountInactive -UsersOnly -TimeSpan 90.00:00:00 | Move-ADObject -TargetPath $InactiveOU
Search-ADAccount -SearchBase $TargetOU -AccountExpired -UsersOnly | Move-ADObject -TargetPath $ExpiredOU
Search-ADAccount -SearchBase $TargetOU -AccountDisabled -UsersOnly | Move-ADObject -TargetPath $DisabledOU
