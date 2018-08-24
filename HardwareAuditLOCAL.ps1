############ Hardware Audit ####################
Start-Process powershell.exe -WindowStyle Hidden -Verb runAs

$name = (Get-Item env:\ComputerName).value 
$filepath = (Get-ChildItem env:\UserProfile).value
 
# HTML Output Formatting #
$a = "<!--mce:0-->"

ConvertTo-Html -Head $a -Title "Hardware Information for $name" -Body "<h1> Computer Name : $name </h1>" > "$filepath\$name.html"  
 
# MotherBoard: Win32_BaseBoard # You can also select Tag,Weight,Width # 
Get-CimInstance -Class Win32_BaseBoard -ComputerName $name | Select-Object Name,Manufacturer,Product,SerialNumber,Status | ConvertTo-html  -Body "<H2> MotherBoard Information</H2>" >> "$filepath\$name.html" 
 
# Battery #
Get-CimInstance -Class Win32_Battery -ComputerName $name | Select-Object Caption,Name,DesignVoltage,DeviceID,EstimatedChargeRemaining,EstimatedRunTime  | ConvertTo-html  -Body "<H2> Battery Information</H2>" >> "$filepath\$name.html" 
 
# BIOS #
Get-CimInstance -Class win32_bios -ComputerName $name | Select-Object Manufacturer,Name,BIOSVersion,ListOfLanguages,PrimaryBIOS,ReleaseDate,SMBIOSBIOSVersion,SMBIOSMajorVersion,SMBIOSMinorVersion  | ConvertTo-html  -Body "<H2> BIOS Information </H2>" >> "$filepath\$name.html" 
 
# CD ROM Drive #
Get-CimInstance -Class Win32_CDROMDrive -ComputerName $name |  Select-Object Name,Drive,MediaLoaded,MediaType,MfrAssignedRevisionLevel  | ConvertTo-html  -Body "<H2> CD ROM Information</H2>" >> "$filepath\$name.html" 
 
# System Info #
Get-CimInstance -Class Win32_ComputerSystemProduct -ComputerName $name | Select-Object Vendor,Version,Name,IdentifyingNumber,UUID  | ConvertTo-html  -Body "<H2> System Information </H2>" >> "$filepath\$name.html" 
 
# Hard-Disk #
Get-CimInstance -Class win32_diskDrive -ComputerName $name | Select-Object Model,SerialNumber,InterfaceType,Size,Partitions  | ConvertTo-html  -Body "<H2> Harddisk Information </H2>" >> "$filepath\$name.html" 

# Mapped Drives #
Get-CimInstance -Class Win32_MappedLogicalDisk -ComputerName $name | Select-Object Name,ProviderName | ConvertTo-html -Body "<H2> Mapped Drives </H2>" >> "$filepath\$name.html"
 
# NetWord Adapters #
Get-CimInstance -Class win32_networkadapter -ComputerName $name | Select-Object Name,Manufacturer,Description ,AdapterType,Speed,MACAddress,NetConnectionID | ConvertTo-html  -Body "<H2> Nerwork Card Information</H2>" >> "$filepath\$name.html" 
 
# Memory #
Get-CimInstance -Class Win32_PhysicalMemory -ComputerName $name  | Select-Object BankLabel,DeviceLocator,Capacity,Manufacturer,PartNumber,SerialNumber,Speed  | ConvertTo-html  -Body "<H2> Physical Memory Information</H2>" >> "$filepath\$name.html" 
 
# Processor #
Get-CimInstance -Class Win32_Processor -ComputerName $name  | Select-Object Name,Manufacturer,Caption,DeviceID,CurrentClockSpeed,CurrentVoltage,DataWidth,L2CacheSize,L3CacheSize,NumberOfCores,NumberOfLogicalProcessors,Status  | ConvertTo-html  -Body "<H2> CPU Information</H2>" >> "$filepath\$name.html" 
 
# System enclosure #
Get-CimInstance -Class Win32_SystemEnclosure -ComputerName $name  | Select-Object Tag,AudibleAlarm,ChassisTypes,HeatGeneration,HotSwappable,InstallDate,LockPresent,PoweredOn,PartNumber,SerialNumber  | ConvertTo-html  -Body "<H2> System Enclosure Information </H2>" >> "$filepath\$name.html" 

# Invoke Expressons #
Invoke-Expression "$filepath\$name.html"
 
# Copy to Local C:\HardwareAudits #
New-Item -ItemType Directory -path "C:\HardwareAudits" -ErrorVariable capturedErrors -ErrorAction SilentlyContinue
$capturedErrors | foreach-object { if ($_ -notmatch "already exists") { write-error $_ } }
Copy-Item "$filepath\$name.html" -Destination 'C:\HardwareAudits'