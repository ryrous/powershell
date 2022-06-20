foreach ($p in Get-Process) { 
    if ($p.handlecount -gt 500) {Write-Host $p.Name, $p.pm}
}
