Get-Credential domain\usermname
$PC = Read-Host ".\ListOfPCs.csv"
$FileLocation = Read-Host ".\filename.ext"
$FileDestination = Read-Host "C:\temp\"
Get-Content $PC | foreach {Copy-Item $FileLocation -Destination \\$_\c$\$FileDestination}