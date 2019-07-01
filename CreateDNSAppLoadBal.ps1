### Create Zone Scopes ###
Add-DnsServerZoneScope -ZoneName "contosogiftservices.com" `
                       -Name "SeattleZoneScope"
Add-DnsServerZoneScope -ZoneName "contosogiftservices.com" `
                       -Name "DallasZoneScope"
Add-DnsServerZoneScope -ZoneName "contosogiftservices.com" `
                       -Name "ChicagoZoneScope"

### Add Records to Scopes ###
Add-DnsServerResourceRecord -ZoneName "contosogiftservices.com" `
                            -A `
                            -Name "www" `
                            -IPv4Address "192.0.0.1" `
                            -ZoneScope "SeattleZoneScope"
Add-DnsServerResourceRecord -ZoneName "contosogiftservices.com" `
                            -A `
                            -Name "www" `
                            -IPv4Address "182.0.0.1" `
                            -ZoneScope "ChicagoZoneScope"
Add-DnsServerResourceRecord -ZoneName "contosogiftservices.com" `
                            -A `
                            -Name "www" `
                            -IPv4Address "162.0.0.1" `
                            -ZoneScope "DallasZoneScope"

### Create DNS Policy ###
Add-DnsServerQueryResolutionPolicy -Name "AmericaPolicy" `
                                   -Action ALLOW `
                                   -ZoneScope "SeattleZoneScope,2; ChicagoZoneScope,1; DallasZoneScope,1" `
                                   -ZoneName "contosogiftservices.com"