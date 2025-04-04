#Requires -Modules SqlServer

<#
.SYNOPSIS
  Retrieves a list of database names from a specified SQL Server instance.

.DESCRIPTION
  This function connects to the specified SQL Server instance using the SqlServer
  module and returns the names of all databases found on that instance.
  It requires the SqlServer PowerShell module to be installed.

.PARAMETER ServerInstance
  The name of the SQL Server instance to query (e.g., "ServerName", "ServerName\InstanceName").

.EXAMPLE
  Get-SqlDatabaseName -ServerInstance "MyDatabaseServer"

.EXAMPLE
  Get-SqlDatabaseName -ServerInstance "localhost\SQLEXPRESS" -Verbose

.OUTPUTS
  System.String - Outputs the names of the databases.

.NOTES
  Date:   2025-04-04
  Requires the 'SqlServer' module. Install it using: Install-Module SqlServer -Scope CurrentUser
#>
Function Get-SqlDatabaseName {
    [CmdletBinding()] # Enables common parameters like -Verbose, -ErrorAction
    param(
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true, # Allows piping server names to the function
                   Position = 0,
                   HelpMessage = "Enter the name of the SQL Server instance (e.g., 'ServerName' or 'ServerName\\InstanceName').")]
        [ValidateNotNullOrEmpty()]
        [string]$ServerInstance
    )

    Process {
        Write-Verbose "Attempting to connect to SQL Server instance: $ServerInstance"
        try {
            # Use the dedicated cmdlet from the SqlServer module
            # Select-Object -ExpandProperty Name outputs strings directly
            Get-SqlDatabase -ServerInstance $ServerInstance -ErrorAction Stop | Select-Object -ExpandProperty Name
            Write-Verbose "Successfully retrieved database names from $ServerInstance."
        }
        catch {
            # Catch any errors during connection or retrieval
            Write-Error "Failed to retrieve databases from '$ServerInstance'. Error: $($_.Exception.Message)"
            # Optionally, re-throw the original error record:
            # throw $_
        }
    }
}

# Example Usage:
# Ensure the module is installed first: Install-Module SqlServer -Scope CurrentUser
# Get-SqlDatabaseName -ServerInstance "YourServerName"
# Get-SqlDatabaseName -ServerInstance "YourServerName\YourInstance" -Verbose
# "YourServerName" | Get-SqlDatabaseName