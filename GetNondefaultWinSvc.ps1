$NonDefaultServices = Get-wmiobject win32_service | Where-Object { 
    $_.Caption -notmatch "Windows" -and 
    $_.PathName -notmatch "Windows" -and
    $_.PathName -notmatch "policyhost.exe" -and 
    $_.Name -ne "LSM" -and 
    $_.PathName -notmatch "OSE.EXE" -and 
    $_.PathName -notmatch "OSPPSVC.EXE" -and 
    $_.PathName -notmatch "Microsoft Security Client" 
}

$NonDefaultServices.DisplayName # Service Display Name (full name)
$NonDefaultServices.PathName # Service Executable
$NonDefaultServices.StartMode # Service Startup mode
$NonDefaultServices.StartName # Service RunAs Account
$NonDefaultServices.State # Service State (running/stopped etc)
$NonDefaultServices.Status # Service Status
$NonDefaultServices.Started # Service Started status
$NonDefaultServices.Description # Service Description

Foreach ($Service in $NonDefaultServices) {
    Write-Output "Stopping Service: $($Service.DisplayName)"
    Get-Service $Service | Stop-Service -Force
}