### Create DNS Client Subnets ###
Add-DnsServerClientSubnet -Name "AmericaSubnet" `
                          -IPv4Subnet 192.0.0.0/24,182.0.0.0/24
Add-DnsServerClientSubnet -Name "EuropeSubnet" `
                          -IPv4Subnet 141.1.0.0/24,151.1.0.0/24

### Create DNS Scopes ###
Add-DnsServerZoneScope -ZoneName "contosogiftservices.com" `
                       -Name "DublinZoneScope"
Add-DnsServerZoneScope -ZoneName "contosogiftservices.com" `
                       -Name "AmsterdamZoneScope"

### Add Web Server Host Records to Scopes ###
Add-DnsServerResourceRecord -ZoneName "contosogiftservices.com" `
                            -A `
                            -Name "www" `
                            -IPv4Address "151.1.0.1" `
                            -ZoneScope "DublinZoneScope"
Add-DnsServerResourceRecord -ZoneName "contosogiftservices.com" `
                            -A `
                            -Name "www" `
                            -IPv4Address "141.1.0.1" `
                            -ZoneScope "AmsterdamZoneScope"

### Create DNS Policies ###
Add-DnsServerQueryResolutionPolicy -Name "AmericaLBPolicy" `
                                   -Action ALLOW `
                                   -ClientSubnet "eq,AmericaSubnet" `
                                   -ZoneScope "SeattleZoneScope,2; ChicagoZoneScope,1; TexasZoneScope,1" `
                                   -ZoneName "contosogiftservices.com" `
                                   –ProcessingOrder 1
Add-DnsServerQueryResolutionPolicy -Name "EuropeLBPolicy" `
                                   -Action ALLOW `
                                   -ClientSubnet "eq,EuropeSubnet" `
                                   -ZoneScope "DublinZoneScope,1; AmsterdamZoneScope,1" `
                                   -ZoneName "contosogiftservices.com" `
                                   -ProcessingOrder 2
Add-DnsServerQueryResolutionPolicy -Name "WorldWidePolicy" `
                                   -Action ALLOW `
                                   -FQDN "eq,*.contoso.com" `
                                   -ZoneScope "SeattleZoneScope,1; ChicagoZoneScope,1; TexasZoneScope,1; DublinZoneScope,1; AmsterdamZoneScope,1" `
                                   -ZoneName "contosogiftservices.com" `
                                   -ProcessingOrder 3