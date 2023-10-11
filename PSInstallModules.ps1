Write-Output "Setting PSGallery as a Trusted repo"
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Write-Output "PSGallery is Trusted"
Write-Output "Installing Modules.."
Install-Module -Name 7Zip4Powershell -Scope AllUsers -Confirm:$false
Install-Module -Name ActiveDirectoryDsc -Scope AllUsers -Confirm:$false
Install-Module -Name AWSPowerShell -Scope AllUsers -Confirm:$false
Install-Module -Name AWS.Tools.Common -Scope AllUsers -Confirm:$false
Install-Module -Name Azure -Scope AllUsers -Confirm:$false
Install-Module -Name AzureAD -Scope AllUsers -Confirm:$false
Install-Module -Name CertificateDsc -Scope AllUsers -Confirm:$false
Install-Module -Name ChocolateyGet -Scope AllUsers -Confirm:$false
Install-Module -Name ComputerManagementDsc -Scope AllUsers -Confirm:$false
Install-Module -Name DellBIOSProvider -Scope AllUsers -Confirm:$false
Install-Module -Name ExchangeOnlineManagement -Scope AllUsers -Confirm:$false
Install-Module -Name IISAdministration -Scope AllUsers -Confirm:$false
Install-Module -Name Microsoft.Graph -Scope AllUsers -Confirm:$false
Install-Module -Name MSOnline -Scope AllUsers -Confirm:$false
Install-Module -Name NetworkingDsc -Scope AllUsers -Confirm:$false
Install-Module -Name NuGet -Scope AllUsers -Confirm:$false
Install-Module -Name PackageManagement -Scope AllUsers -Confirm:$false
Install-Module -Name PowerShellGet -Scope AllUsers -Force
Install-Module -Name PSScriptAnalyzer -Scope AllUsers -Confirm:$false
Install-Module -Name SqlServerDsc -Scope AllUsers -Confirm:$false
Install-Module -Name VMware.PowerCLI -Scope AllUsers -Confirm:$false
Install-Module -Name xWindowsUpdate -Scope AllUsers -Confirm:$false
Write-Output "Finished. Displaying installed modules.."
Get-InstalledModule