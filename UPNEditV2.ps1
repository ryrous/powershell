Import-Module MSOnline
$Username = "admin@domain.com"
$Credential = Get-Credential $Username
Connect-AzureAD -Credential $Credential
Set-AzureADUser -UserPrincipalName "Username@domain.onmicrosoft.com" -NewUserPrincipalName "Username@domain.com"
