Import-Module MSOnline
$Username = "admin@domain.com"
$Credential = Get-Credential $Username
Connect-AzureAD -Credential $Credential