$myDescription="ComputerName"
Invoke-Command -ComputerName $lServerName -ScriptBlock {$OSWMI=Get-WmiObject -class Win32_OperatingSystem;$OSWMI.Description=$args[0];$OSWMI.put() } -ArgumentList($myDescription)
