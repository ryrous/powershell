### Get all AD Users ###
Get-ADuser -Filter * -Properties SamAccountName,DisplayName,UserPrincipalName,whenCreated,PasswordLastSet,PasswordNeverExpires,MemberOf,LastLogonDate | Export-csv .\AllUsers.csv -NoTypeInformation -UseCulture