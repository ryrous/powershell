#Export to CSV for Reference
Search-ADAccount -PasswordNeverExpires -UsersOnly | Select-Object -Property SAMaccountname, Enabled, PasswordExpired, PasswordNeverExpires, LastLogonDate | Export-Csv -Path C:\ExportDir\PWNeverExpires.csv -NoTypeInformation
#Disable 'Password Never Expires' option
Import-CSV C:\ExportDir\PWNeverExpires.csv | ForEach-Object {Set-ADUser $_ -PasswordNeverExpires $false}
