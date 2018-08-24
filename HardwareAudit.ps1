#Get the server list
$servers = Get-Content .\Serverlist.txt
#Run the commands for each server in the list
$infoColl = @()
Foreach ($s in $servers) {
    $CPUInfo = Get-WmiObject Win32_Processor -ComputerName $s #Get CPU Information
    $OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $s #Get OS Information
    #Get Memory Information. The data will be shown in a table as MB, rounded to the nearest MB.
    $OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB)
    $OSTotalVisibleMemory = [math]::round($OSInfo.TotalVisibleMemorySize / 1MB)
    #Get Physical Memory Information. The data will be shown in a table as GB, rounded to the nearest GB.
    $PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName $s | Measure-Object -Property Capacity -Sum | ForEach-Object {[Math]::Round($_.sum / 1GB)}
    #Get Disk Information. The data will be shown in a table as GB, rounded to the nearest GB.
    $DiskInfo = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $s | Measure-Object -Sum Size | ForEach-Object {[Math]::Round($_.sum / 1GB)}
    Foreach ($CPU in $CPUInfo) {
        $infoObject = New-Object PSObject
        #The following add data to the infoObjects.	
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "ServerName" -value $CPU.SystemName
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Processor" -value $CPU.Name
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Model" -value $CPU.Description
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Manufacturer" -value $CPU.Manufacturer
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "PhysicalCores" -value $CPU.NumberOfCores
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L2CacheSize" -value $CPU.L2CacheSize
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L3CacheSize" -value $CPU.L3CacheSize
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "Sockets" -value $CPU.SocketDesignation
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "LogicalCores" -value $CPU.NumberOfLogicalProcessors
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Name" -value $OSInfo.Caption
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Version" -value $OSInfo.Version
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalPhysical_Memory_GB" -value $PhysicalMemory
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVirtual_Memory_MB" -value $OSTotalVirtualMemory
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVisable_Memory_MB" -value $OSTotalVisibleMemory
        Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalDiskSize" -Value $DiskInfo
        $infoObject #Output to the screen for a visual feedback.
        $infoColl += $infoObject
    }
}
$infoColl | Export-Csv -Path .\Server_Inventory_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation -Force #Export the results in csv file.
