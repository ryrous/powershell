### GET ALL USER ACCOUNTS ###
Get-ADuser -Filter * -Properties SamAccountName,DisplayName,UserPrincipalName,whenCreated,PasswordLastSet,PasswordNeverExpires,MemberOf,LastLogonDate `
			| Sort-Object SamAccountName,DisplayName,UserPrincipalName,whenCreated,PasswordLastSet,PasswordNeverExpires,MemberOf,LastLogonDate `
			| Export-csv .\AllUsers.csv -NoTypeInformation -UseCulture