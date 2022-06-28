#Get the server list
$Servers = Get-Content C:\Temp\Serverlist.txt
#Run the commands for each server in the list
$Report = @()
Foreach ($Server in $Servers) {
    $CPU = Get-WmiObject Win32_Processor #Get CPU Information
    $OS = Get-WmiObject Win32_OperatingSystem #Get OS Information
    #Get Memory Information. The data will be shown in a table as MB, rounded to the nearest MB.
    $OSTotalVirtualMemory = [math]::round($OS.TotalVirtualMemorySize / 1MB)
    $OSTotalVisibleMemory = [math]::round($OS.TotalVisibleMemorySize / 1MB)
    #Get Physical Memory Information. The data will be shown in a table as GB, rounded to the nearest GB.
    $PhysicalMemory = Get-WmiObject CIM_PhysicalMemory | Measure-Object -Property Capacity -Sum | ForEach-Object {[Math]::Round($_.sum / 1GB)}
    #Get Disk Information. The data will be shown in a table as GB, rounded to the nearest GB.
    $DiskInfo = Get-WmiObject -Class Win32_LogicalDisk | Measure-Object -Sum Size | ForEach-Object {[Math]::Round($_.sum / 1GB)}
    $ReportObject = New-Object PSObject
    #The following add data to the infoObjects.	
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "ServerName" -Value $CPU.SystemName
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "Processor" -Value $CPU.Name
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "Model" -Value $CPU.Description
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "Manufacturer" -Value $CPU.Manufacturer
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "Physical Cores" -Value $CPU.NumberOfCores
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "CPU L2 Cache Size" -Value $CPU.L2CacheSize
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "CPU L3 Cache Size" -Value $CPU.L3CacheSize
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "Sockets" -Value $CPU.SocketDesignation
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "Logical Cores" -Value $CPU.NumberOfLogicalProcessors
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "OS Name" -Value $OS.Caption
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "OS Version" -Value $OS.Version
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "Total Physical Memory in GB" -Value $PhysicalMemory
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "TotalVirtual Memory in MB" -Value $OSTotalVirtualMemory
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "TotalVisable Memory in MB" -Value $OSTotalVisibleMemory
    Add-Member -inputObject $ReportObject -memberType NoteProperty -Name "Total Disk Size" -Value $DiskInfo
    $ReportObject #Output to the screen for a visual feedback.
    $Report += $ReportObject
}
$Report | Export-Csv -Path C:\Temp\Server_Inventory_$((Get-Date).ToString('MM-dd-yyyy')).csv -NoTypeInformation -Force
