#Export User Accounts to CSV for Reference
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountInactive -TimeSpan 90.00:00:00 | Select-Object -Property SAMaccountname, Enabled, PasswordExpired, PasswordNeverExpires, LastLogonDate | Export-Csv C:\ExportDir\InactiveUsers.csv
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountExpired | Select-Object -Property SAMaccountname, Enabled, PasswordExpired, PasswordNeverExpires, LastLogonDate | Export-Csv C:\ExportDir\ExpiredUsers.csv
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountDisabled | Select-Object -Property SAMaccountname, Enabled, PasswordExpired, PasswordNeverExpires, LastLogonDate | Export-Csv C:\ExportDir\DisabledUsers.csv
#Remove User Accounts from AD
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountInactive -TimeSpan 90.00:00:00 | Remove-ADUser
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountExpired | Remove-ADUser
Search-ADAccount -SearchBase "OU=Users,DC=domain,DC=com" -UsersOnly -AccountDisabled | Remove-ADUser
