### Export User Accounts to CSV for Reference ###
Search-ADAccount -UsersOnly `
                 -LockedOut | Select-Object -Property SAMaccountname, `
                                                      Enabled, `
                                                      PasswordExpired, `
                                                      PasswordNeverExpires, `
                                                      LastLogonDate `
                            | Export-Csv C:\ExportDir\LockedOutUsers.csv -NoTypeInformation
### Get SAMaccountname ###
$LockedOutUsers = (Import-Csv -Path C:\ExportDir\LockedOutUsers.csv).SAMaccountname

### Unlock User Accounts ###
Unlock-ADAccount -Identity $LockedOutUsers