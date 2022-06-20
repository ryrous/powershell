Function Show-DatabasesOnServer ([string]$Server) {
    $srv = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $server
    Write-Host " The Databases on $Server Are As Follows"
    $srv.databases| Select-Object Name
}