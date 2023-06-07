#Arm the Variables, a bunch of them

#Cpu Cores in the VM
$CpuCount=2
#Ram Size
$RAMCount=1GB
#VMName , will also become the Computer Name
$Name="Test"
#IP Address
$IPDomain="192.168.0.1"
#Default Gateway to be used
$DefaultGW="192.168.0.254"
#DNS Server
$DNSServer="192.168.0.1"
#DNS Domain Name
$DNSDomain="test.com"
#Hyper V Switch Name
$SwitchNameDomain="HyperV"
#Set the VM Domain access NIC name
$NetworkAdapterName="Public"
#User name and Password
$AdminAccount="Administrator"
$AdminPassword="P@ssw0rd"
#Org info
$Organization="Test Organization"
#This ProductID is actually the AVMA key provided by MS
$ProductID="TMJ3Y-NTRTM-FJYXT-T22BY-CWG3J"
#Where's the VM Default location? You can also specify it manually
$Path= Get-VMHost | Select-Object VirtualMachinePath -ExpandProperty VirtualMachinePath
#Where should I store the VM VHD?, you actually have nothing to do here unless you want a custom name on the VHD
$VHDPath=$Path + $Name + "\" + $Name + ".vhdx"
#Where are the folders with prereq software ?
$StartupFolder="C:\ISO"
$TemplateLocation="C:\ISO\Template2016.vhdx"
$UnattendLocation="C:\ISO\unattend.xml"
#Part 1 Complete-------------------------------------------------------------------------------#



#Part 2 Initialize---------------------------------------------------------------------------------#
#Start the Party!
#Let's see if there are any VM's with the same name if you actually find any simply inform the user
$VMS=Get-VM
Foreach($VM in $VMS)
{
 if ($Name -match $VM.Name)
 {
 write-host -ForegroundColor Red "Found VM With the same name!!!!!"
 $Found=$True
 }
}
 
#Create the VM
New-VM -Name $Name -Path $Path  -MemoryStartupBytes $RAMCount  -Generation 2 -NoVHD
 
#Remove any auto generated adapters and add new ones with correct names for Consistent Device Naming
Get-VMNetworkAdapter -VMName $Name | Remove-VMNetworkAdapter
Add-VMNetworkAdapter -VMName $Name -SwitchName $SwitchNameDomain -Name $NetworkAdapterName -DeviceNaming On
 
#Start and stop VM to get mac address, then arm the new MAC address on the NIC itself
start-vm $Name
Start-Sleep 5
stop-vm $Name -Force
Start-Sleep 5
$MACAddress=get-VMNetworkAdapter -VMName $Name -Name $NetworkAdapterName|select MacAddress -ExpandProperty MacAddress
$MACAddress=($MACAddress -replace '(..)','$1-').trim('-')
Get-VMNetworkAdapter -VMName $Name -Name $NetworkAdapterName | Set-VMNetworkAdapter -StaticMacAddress $MACAddress
 
#Copy the template and add the disk on the VM. Also configure CPU and start - stop settings
Copy-item $TemplateLocation -Destination  $VHDPath
Set-VM -Name $Name -ProcessorCount $CpuCount  -AutomaticStartAction Start -AutomaticStopAction ShutDown -AutomaticStartDelay 5 
Add-VMHardDiskDrive -VMName $Name -ControllerType SCSI -Path $VHDPath
 
#Set first boot device to the disk we attached
$Drive=Get-VMHardDiskDrive -VMName $Name | Where-Object {$_.Path -eq "$VHDPath"}
Get-VMFirmware -VMName $Name | Set-VMFirmware -FirstBootDevice $Drive
 
#Prepare the unattend.xml file to send out, simply copy to a new file and replace values
Copy-Item $UnattendLocation $StartupFolder\"unattend"$Name".xml"
$DefaultXML=$StartupFolder+ "\unattend"+$Name+".xml"
$NewXML=$StartupFolder + "\unattend$Name.xml"
$DefaultXML=Get-Content $DefaultXML
$DefaultXML  | Foreach-Object {
 $_ -replace '1AdminAccount', $AdminAccount `
 -replace '1Organization', $Organization `
 -replace '1Name', $Name `
 -replace '1ProductID', $ProductID`
 -replace '1MacAddressDomain',$MACAddress `
 -replace '1DefaultGW', $DefaultGW `
 -replace '1DNSServer', $DNSServer `
 -replace '1DNSDomain', $DNSDomain `
 -replace '1AdminPassword', $AdminPassword `
 -replace '1IPDomain', $IPDomain `
} | Set-Content $NewXML
 
#Mount the new virtual machine VHD
mount-vhd -Path $VHDPath
#Find the drive letter of the mounted VHD
$VolumeDriveLetter=Get-DiskImage $VHDPath | Get-Disk | Get-Partition | Get-Volume | Where-Object {$_.FileSystemLabel -ne "Recovery"} | Select-Object DriveLetter -ExpandProperty DriveLetter
#Construct the drive letter of the mounted VHD Drive
$DriveLetter="$VolumeDriveLetter"+":"
#Copy the unattend.xml to the drive
Copy-Item $NewXML $DriveLetter\unattend.xml
#Dismount the VHD
Dismount-Vhd -Path $VHDPath
#Fire up the VM
Start-VM $Name
#Part 2 Complete---------------------------------------------------------------------#