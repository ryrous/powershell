### Export User Accounts to CSV for Reference ###
Search-ADAccount -UsersOnly `
                 -LockedOut | Select-Object -Property SAMaccountname, `
                                                      Enabled, `
                                                      PasswordExpired, `
                                                      PasswordNeverExpires, `
                                                      LastLogonDate `
                            | Export-Csv C:\ExportDir\LockedOutUsers.csv -NoTypeInformation

### Unlock User Accounts ###
Search-ADAccount -UsersOnly `
                 -LockedOut | Unlock-ADAccount