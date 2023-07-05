Get-ADGroupMember -Identity "Workstations" | Select-Object Name | Out-File C:\Workstations.txt -Force
$WS = Get-Content C:\Workstations.txt | Select-Object -Skip 3
foreach ($w in $WS){
    Invoke-Command -ComputerName $w -ScriptBlock {Remove-Item -Path "C:\Windows\Temp\*" -ErrorAction SilentlyContinue -Recurse -Force}
    Invoke-Command -ComputerName $w -ScriptBlock {Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -ErrorAction SilentlyContinue -Recurse -Force}
    Clear-RecycleBin -Force -Confirm:$false
}