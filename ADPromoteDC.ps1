# Install Server Role
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
# Install PowerShell Module
Import-Module ADDSDeployment
# Promote to DC
Install-ADDSDomainController -DomainName lucernpub.com `
                            -Credential (Get-Credential) `
                            -installDNS:$true `
                            -NoGlobalCatalog:$false `
                            -DatabasePath "E:\NTDS" `
                            -Logpath "E:\Logs" `
                            -SysvolPath "E:” `
                            -Sitename RemoteLocation