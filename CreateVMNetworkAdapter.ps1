Get-VM -Name "NameofVM" | Get-VMNetworkAdapter `
                        | Connect-VMNetworkAdapter -Switchname 'Private Network'