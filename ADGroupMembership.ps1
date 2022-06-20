### Export Domain Admins Group to CSV ###
Get-ADGroupMember -Server domain.com `
                  -Identity "Domain Admins" `
                  -Recursive | Export-Csv -Path C:\ExportDir\DomainAdmins.csv

### Export Local Admins Group to CSV ###
Get-ADGroupMember -Server domain.com `
                  -Identity "Local Admin Users" `
                  -Recursive | Export-Csv -Path C:\ExportDir\LocalAdmins.csv