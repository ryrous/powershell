# --- How to Use ---

# Example 1: Clear logs on the local machine (will prompt for confirmation)
# Clear-AllWinEventLogs

# Example 2: Clear logs on a remote machine (will prompt for confirmation)
# Clear-AllWinEventLogs -ComputerName "SERVER01"

# Example 3: Run without confirmation (Use with caution!)
# Clear-AllWinEventLogs -Confirm:$false

# Example 4: See what would happen without actually clearing (using -WhatIf)
# Clear-AllWinEventLogs -WhatIf

# Example 5: Show verbose messages during execution
# Clear-AllWinEventLogs -Verbose

# --- To run the script on the local machine immediately (like the original): ---
# Clear-AllWinEventLogs -ComputerName localhost -Confirm:$false # Be careful!

function Clear-AllWinEventLogs {
   [CmdletBinding(SupportsShouldProcess = $true)]
   param(
       [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
       [string]$ComputerName = $env:COMPUTERNAME # Default to local machine using environment variable
   )

   #Requires -RunAsAdministrator # Add this line to enforce running as admin in PS 5+ environments
                                # In PS Core, manual check might still be needed or rely on Clear-WinEvent errors

   # Check for Elevated Privileges (more cross-version compatible check)
   $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
   $principal = [System.Security.Principal.WindowsPrincipal]::new($currentUser)
   if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
       Write-Warning "This script needs to be run with Administrator privileges to clear all event logs."
       # Optionally, you could force an exit here:
       # throw "Administrator privileges required."
       # Or just continue and let Clear-WinEvent fail on restricted logs.
   }

   Write-Verbose "Retrieving list of event logs from computer: $ComputerName"
   $logNames = @() # Initialize empty array

   try {
       # Get-WinEvent -ListLog * can sometimes be slow or error on specific providers.
       # Filter for log names that are commonly clearable. You might adjust this.
       # This gets log names directly. Avoids issues with provider names vs log names.
       $logNames = Get-WinEvent -ListLog * -ComputerName $ComputerName -ErrorAction Stop | Select-Object -ExpandProperty LogName
       Write-Verbose "Found $($logNames.Count) event logs."
   }
   catch {
       Write-Error "Failed to retrieve event log list from $ComputerName. Error: $($_.Exception.Message)"
       return # Exit the function if we can't get the log list
   }

   if ($logNames.Count -eq 0) {
       Write-Warning "No event logs found or retrieved from $ComputerName."
       return
   }

   foreach ($logName in $logNames) {
       # Check if the operation should proceed (handles -Confirm and -WhatIf)
       if ($PSCmdlet.ShouldProcess("'$logName' on computer '$ComputerName'", "Clear Event Log")) {
           Write-Verbose "Attempting to clear log: $logName on $ComputerName"
           try {
               # Clear the specific log
               # Use -ErrorAction Stop to force errors into the catch block
               # Use -WarningAction SilentlyContinue to suppress warnings about logs that cannot be cleared (e.g., Debug/Analytic)
               Clear-WinEvent -LogName $logName -ComputerName $ComputerName -ErrorAction Stop -WarningAction SilentlyContinue
               Write-Verbose "Successfully cleared or attempted to clear log: $logName"
           }
           catch [System.UnauthorizedAccessException] {
               Write-Warning "Access denied clearing log '$logName' on $ComputerName. Requires elevated permissions."
           }
           catch {
               # Catch other potential errors
               Write-Warning "Could not clear log '$logName' on $ComputerName. Error: $($_.Exception.Message)"
               # Some logs (like certain Debug/Analytic logs) cannot be cleared by design.
               # Clear-WinEvent might throw an error or issue a warning (suppressed above).
           }
       }
   }

   Write-Host "Finished attempting to clear all accessible event logs on $ComputerName."

   # Optional: Re-list logs or show status if desired, but removed for simplicity.
   # Get-WinEvent -ListLog * -ComputerName $ComputerName | Select-Object LogName, RecordCount, IsEnabled, LogMode
}

# Recommended execution (prompts for confirmation):
Clear-AllWinEventLogs -ComputerName localhost -Verbose