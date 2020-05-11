Get-Command -Module AWSPowerShell.NetCore | Select-Object Name, Module, Version, Visibility, Definition | Export-CSV '~/Downloads/PS Commands/AWSPowerShell.csv' -NoTypeInformation -Force
Get-Command -Module Azure | Select-Object Name, Module, Version, Visibility, Definition | Export-CSV '~/Downloads/PS Commands/AzurePowerShell.csv' -NoTypeInformation -Force
Get-Command -Module Azure.Storage | Select-Object Name, Module, Version, Visibility, Definition | Export-CSV '~/Downloads/PS Commands/AzureStorage.csv' -NoTypeInformation -Force
Get-Command -Module RabbitMQTools | Select-Object Name, Module, Version, Visibility, Definition | Export-CSV '~/Downloads/PS Commands/AWSPowerShell.csv' -NoTypeInformation -Force
Get-Command -Module VMware.VimAutomation.Core | Select-Object Name, Module, Version, Visibility, Definition | Export-CSV '~/Downloads/PS Commands/VMwarePowerShell.csv' -NoTypeInformation -Force
Get-Command -Module VMware.VimAutomation.Storage | Select-Object Name, Module, Version, Visibility, Definition | Export-CSV '~/Downloads/PS Commands/VMwareStorage.csv' -NoTypeInformation -Force
