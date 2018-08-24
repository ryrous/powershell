$OSWMI=Get-WmiObject -class Win32_OperatingSystem
$OSWMI.Description="ComputerName"
$OSWMI.put()