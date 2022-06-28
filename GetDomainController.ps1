# Get Primary Domain Controller
Get-ADDomainController -Discover -DomainName $Domain -Service "PrimaryDC" -ForceDiscover 
