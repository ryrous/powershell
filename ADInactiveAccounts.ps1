Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90.00:00:00 | Export-Csv C:\ExportDir\InactiveAccounts.csv -NoTypeInformation
#Search-ADAccount -SearchBase "OU=name,OU=name,DC=domain,DC=com" -UsersOnly -AccountInactive -TimeSpan 90.00:00:00 | Export-Csv C:\ExportDir\InactiveAccounts.csv -NoTypeInformation
