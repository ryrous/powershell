Import-Module MSOnline
$Username = "admin@domain.com"
$Credential = Get-Credential $Username
Connect-MsolService -Credential $Credential
Set-MsolUserPrincipalName -UserPrincipalName "Username@domain.onmicrosoft.com" -NewUserPrincipalName "username@domain.com"
