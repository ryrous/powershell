#Export User Accounts to CSV for Reference
Search-ADAccount -UsersOnly -AccountExpiring | Select-Object -Property SAMaccountname, Enabled, PasswordExpired, PasswordNeverExpires, LastLogonDate | Export-Csv C:\ExportDir\ExpiringUsers.csv -NoTypeInformation
