if (!$args.count -ne 1) { 
    $rh = Read-Host "Enter the name of the service to check" 
    $myValue = Get-Service $rh 
} 
else { 
    $myValue = Get-Service $args[0] 
} 
$serName = $myValue.Name 
switch -wildcard ($myValue.Status) { 
    "S*" {Write-Host "The $serName service is stopped."} 
    "R*" {Write-Host "The $serName service is running."} 
    "P*" {Write-Host "The $serName service is paused."} 
    default {Write-Host "Check the service."} 
}
