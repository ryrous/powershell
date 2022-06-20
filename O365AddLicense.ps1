Import-Csv C:\O365\Users.csv |`
    ForEach-Object {
        $UPN += $_.UPN
    }    
$User="$UPN"
$License="NameOfOrganization:ENTERPRISEPACK"
Set-MsolUserLicense -UserPrincipalName $User -AddLicenses $License