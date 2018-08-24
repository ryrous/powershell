$c = Get-Credential -UserName $env:USERNAME -Message 'Enter Password'
$s = Get-Content -Path C:\ManualReboot\RebootServers.txt
Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*'} | Select-Object -Expand Name | Add-Content -Path C:\ManualReboot\RebootServers.txt 
foreach ($env:COMPUTERNAME in ($s)) {
        Restart-Computer -Wait -For PowerShell -ThrottleLimit 500 -Timeout 300 -Delay 2 -Credential $c -Force
}
Exit 