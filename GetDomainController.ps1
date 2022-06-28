# Get Primary Domain Controller
Get-ADDomainController -Discover -DomainName domain.com -Service "PrimaryDC" -ForceDiscover
