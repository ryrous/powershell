# Get the name of the Wi-Fi interface
$wifiInterface = Get-NetAdapter | Where-Object { $_.Name -like "*ethernet*" }

# Get the MAC address of the Wi-Fi interface
$mac = $wifiInterface.MacAddress

# Print the MAC address
Write-Host "The MAC address of your ethernet adapter is $mac"