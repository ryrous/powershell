workflow Get-CompInfo {
    Get-Host | Select-Object version
    Get-NetAdapter
    Get-Disk
    Get-Volume
    Checkpoint-Workflow
}
Get-CompInfo | Export-Csv -Path $env:USERPROFILE\Desktop\CompInfo.csv