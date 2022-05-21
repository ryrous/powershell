function Get-ComputerStatus { 
    ## Get drive usage information "Current disk usage" "------------------" 
    $drives = Get-PSDrive 
    ## Override persistence on a command that doesn't ## support it. 
    $drives | Sort-Object -Property Free -Descending -PSPersist:$false 
    ## See which non-system processes have consumed the ## most CPU"` nProcess CPU usage" "-------------------" 
    InlineScript { 
        $userProcesses = Get-Process | Where-Object Path -notlike ($env:WINDIR + "*") 
        $userProcesses = $userProcesses | Sort-Object CPU | Select-Object Name, CPU, StartTime $ userProcesses | Select-Object -Last 10 
    } 
    ## Get licensing status "` nLicense status" "----------------" 
    cscript $env:WINDIR \system32\slmgr.vbs /dlv 
}
$Server = Get-Content -Path C:\PowerShell\ServerList.txt
Get-ComputerStatus -PSComputerName $Server | Export-Csv -Path "$env:USERPROFILE\Desktop\ComputerStatus.csv" -Force