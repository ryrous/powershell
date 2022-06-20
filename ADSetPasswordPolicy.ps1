### Set the default password policy for a specified domain ###
Set-ADDefaultDomainPasswordPolicy -Identity fabrikam.com `
                                  -LockoutDuration 00:40:00 `
                                  -LockoutObservationWindow 00:20:00 `
                                  -ComplexityEnabled $True `
                                  -ReversibleEncryptionEnabled $False `
                                  -MaxPasswordAge 10.00:00:00
                                  
### Set the default domain policy for the current logged on user domain ###
Get-ADDefaultDomainPasswordPolicy -Current LoggedOnUser | Set-ADDefaultDomainPasswordPolicy -LockoutDuration 00:40:00 `
                                                                                            -LockoutObservationWindow 00:20:00 `
                                                                                            -ComplexityEnabled $true `
                                                                                            -ReversibleEncryptionEnabled $false `
                                                                                            -MinPasswordLength 12