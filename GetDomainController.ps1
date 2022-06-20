$DomainList = Get-Content -Path C:\GetDomainController\DomainList.txt
foreach ($Domain in $DomainList) {
    Get-ADDomainController -Discover -DomainName $Domain -Service "PrimaryDC" -ForceDiscover 
}
