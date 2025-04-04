<#
.SYNOPSIS
Retrieves the CPU usage percentage for specified processes, normalized by the number of logical CPU cores.

.DESCRIPTION
This script calculates the CPU usage percentage for one or more processes identified either by name (partial match supported)
or by a specific Process ID (PID). It uses performance counters and adjusts the value based on the total number of
logical processors available on the system. Compatible with PowerShell Core 7+.

.PARAMETER ProcessName
Specifies the name of the process. Wildcards (*) are supported at the end (e.g., "chrome*", "sql*").
This parameter cannot be used with -ProcessPID.

.PARAMETER ProcessPID
Specifies the Process ID (PID) of the process to monitor.
This parameter cannot be used with -ProcessName.

.EXAMPLE
.\Get-ProcessCpuUsageImproved.ps1 -ProcessName "powershell*"
Displays CPU usage for all processes starting with "powershell".

.EXAMPLE
.\Get-ProcessCpuUsageImproved.ps1 -ProcessPID 1234
Displays CPU usage for the process with PID 1234.

.NOTES
- Requires PowerShell Core 7+ for guaranteed compatibility (uses Get-CimInstance).
- The CPU percentage is calculated as (Raw Counter Value / Number of Logical Cores).
- When using -ProcessName with a wildcard, multiple processes might be returned.
- When using -ProcessPID, the script attempts to find the specific performance counter instance for that PID.
- Performance counter queries can sometimes take a moment, especially the first time they are run.
- Ensure you have permissions to query performance counters. Run as Administrator if needed.
#>
[CmdletBinding(DefaultParameterSetName = 'ByName')]
param(
    [Parameter(Mandatory=$true, Position=0, ParameterSetName='ByName')]
    [string]$ProcessName,

    [Parameter(Mandatory=$true, Position=0, ParameterSetName='ByPID')]
    [int]$ProcessPID
)

try {
    # Get logical core count using the modern CIM cmdlet (compatible with PS Core 7+)
    Write-Verbose "Getting logical processor count..."
    $CpuCores = (Get-CimInstance -ClassName Win32_ComputerSystem).NumberOfLogicalProcessors
    if ($null -eq $CpuCores -or $CpuCores -le 0) {
        Write-Warning "Could not determine the number of logical processors or value is invalid. Defaulting to 1."
        $CpuCores = 1 # Fallback to prevent division by zero/error
    }
    Write-Verbose "System has $CpuCores logical processors."

    $counterPath = $null
    $targetDescription = $null # For descriptive output

    # Determine the correct counter path based on parameter set
    if ($PSCmdlet.ParameterSetName -eq 'ByName') {
        Write-Verbose "Querying by process name: '$ProcessName*'"
        # Use wildcard directly for name matching
        $counterPath = "\Process($ProcessName*)\% Processor Time"
        $targetDescription = "Processes matching '$ProcessName*'"

        # Optional: Check if any processes actually match the name pattern beforehand
        # $matchingProcesses = Get-Process -Name "$ProcessName*" -ErrorAction SilentlyContinue
        # if (-not $matchingProcesses) {
        #     Write-Warning "No running processes found matching '$ProcessName*'."
        #     # Decide whether to exit or let Get-Counter handle it
        # }

    }
    elseif ($PSCmdlet.ParameterSetName -eq 'ByPID') {
        Write-Verbose "Querying by Process ID: $ProcessPID"
        # Get the process to verify it exists and get its base name
        $process = Get-Process -Id $ProcessPID -ErrorAction SilentlyContinue
        if (-not $process) {
            Write-Error "Process with PID $ProcessPID not found."
            return # Exit script or function
        }
        $baseProcessName = $process.ProcessName
        $targetDescription = "Process '$baseProcessName' (PID: $ProcessPID)"

        Write-Verbose "Base process name for PID $ProcessPID is '$baseProcessName'. Finding specific performance counter instance..."

        # Find the specific performance counter instance name matching the PID.
        # This is needed because instance names can be 'process', 'process#1', etc.
        # We query the 'ID Process' counter for all instances matching the base name.
        $idCounterPath = "\Process($baseProcessName*)\ID Process"
        Write-Verbose "Querying counter path for PID lookup: '$idCounterPath'"
        $instances = Get-Counter $idCounterPath -ErrorAction SilentlyContinue

        if ($null -eq $instances) {
             # This can happen if the counter set doesn't exist or permissions are denied
             Write-Error "Could not retrieve 'ID Process' performance counters for '$baseProcessName*'. Performance counters might be disabled, require permissions, or the process type may not have standard counters."
             return
        }

        # Get-Counter might return a single object or an array, handle both cases
        $instanceSamples = @($instances.CounterSamples) # Ensure it's always an array

        # Find the sample where the CookedValue (which is the PID for 'ID Process') matches our target PID
        $matchingInstanceSample = $instanceSamples | Where-Object { $_.CookedValue -eq $ProcessPID } | Select-Object -First 1

        if (-not $matchingInstanceSample) {
            Write-Error "Could not find an active performance counter instance for PID $ProcessPID (Process Name: $baseProcessName). The process might have exited just now, or counters might still be initializing."
            return
        }

        $instanceName = $matchingInstanceSample.InstanceName # This is the name like 'chrome' or 'chrome#1'
        Write-Verbose "Found matching counter instance name: '$instanceName'"
        $counterPath = "\Process($instanceName)\% Processor Time"
    }

    # Get the actual CPU usage counter samples using the determined path
    Write-Verbose "Querying counter path for CPU Usage: '$counterPath'"
    $Samples = Get-Counter $counterPath -ErrorAction SilentlyContinue

    if ($null -eq $Samples) {
        # Handles cases where the process(es) might have exited between checks or counter query fails
        Write-Warning "No '% Processor Time' performance counter data found for '$targetDescription'. The process(es) might not be running, accessible, or counters could be unavailable."
        return
    }

    # Process the samples and calculate CPU percentage, normalized by core count
    Write-Host "Calculating CPU Usage for $targetDescription (Normalized across $CpuCores cores):"
    # Ensure CounterSamples is treated as an array even if only one result is returned
    @($Samples.CounterSamples) | Select-Object InstanceName, @{Name="CPU %";Expression={ [Decimal]::Round(($_.CookedValue / $CpuCores), 2) }}

}
catch {
    # Catch any unexpected errors during script execution
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    # For detailed debugging: Write-Error $_.ToString()
}
finally {
    # Cleanup or final messages can go here if needed
    Write-Verbose "Script execution completed."
}