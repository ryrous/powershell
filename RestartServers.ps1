$PSCredential = Get-Credential -UserName $env:USERNAME -Message 'Enter Password'
$Servers = Get-Content -Path C:\Temp\Servers.txt
Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'} | Select-Object -Expand Name | Add-Content -Path C:\Temp\Servers.txt 
foreach ($env:COMPUTERNAME in ($Servers)) {
        Restart-Computer -Wait -For PowerShell -ThrottleLimit 10 -Timeout 300 -Delay 2 -Credential $PSCredential -Force
}
Exit