Connect-MsolService
Get-MsolUser -ReturnDeletedUsers
Remove-MsolUser -UserPrincipalName 'user@domain.com' -RemoveFromRecycleBin -Force