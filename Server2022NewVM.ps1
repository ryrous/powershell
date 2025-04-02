# Get admin password securely
$securePassword = Read-Host -AsSecureString "Enter desired local administrator password"

# Example execution
.\New-UnattendedVM.ps1 -VMName "MyNewDC01" `
                      -CpuCount 4 `
                      -RAMCount 4GB `
                      -IPAddress "192.168.1.10" `
                      -SubnetPrefixLength 24 `
                      -DefaultGateway "192.168.1.1" `
                      -DNSServer "192.168.1.1" `
                      -DNSDomain "corp.contoso.com" `
                      -SwitchName "External Network" `
                      -NetworkAdapterName "Ethernet" `
                      -AdminPasswordSecure $securePassword `
                      -Organization "Contoso Corp" `
                      -AVMAKey "WX4NM-KYWYW-QJJR4-XV3QB-6VM33" ` # Server 2022 DC Key
                      -TemplateVHDXPath "C:\VM\Templates\WS2022_Datacenter_Template.vhdx" `
                      -BaseUnattendXmlPath "C:\VM\Templates\Unattend_Base_WS2022.xml" `
                      -AutoStartVM `
                      -Verbose