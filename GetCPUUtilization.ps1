#############################################################################
# Option A: This is if you just have the name of the process; partial name OK
$ProcessName = "cpu"

# Option B: This is for if you just have the PID; it will get the name for you
#$ProcessPID = "6860"

#$ProcessName = (Get-Process -Id $ProcessPID).Name
$CpuCores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors
$Samples = (Get-Counter "\Process($Processname*)\% Processor Time").CounterSamples
$Samples | Select-Object InstanceName, @{Name="CPU %";Expression={[Decimal]::Round(($_.CookedValue / $CpuCores), 2)}}
#############################################################################