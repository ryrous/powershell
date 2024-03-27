# Get Mac Address of Ethernet Interface
$mac = ifconfig e0 | grep ether | awk '{print $2}'
Write-Output "The MAC Address of your ethernet adapter is $mac"