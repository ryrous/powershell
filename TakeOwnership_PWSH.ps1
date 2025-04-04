<#
.SYNOPSIS
Takes ownership of a folder and its contents for the Administrators group
and grants the Administrators group Full Control recursively.

.DESCRIPTION
This script uses native PowerShell cmdlets (Get-Acl, Set-Acl) to modify
folder permissions. It first sets the owner to the local Administrators
group and then grants that group Full Control with inheritance enabled.
Requires administrative privileges to run.

.PARAMETER Path
The full path to the target folder.

.EXAMPLE
.\Set-AdminOwnershipAndPermissions.ps1 -Path "C:\Path\To\Your\foldername"

.NOTES
Date:   2025-04-04
Ensure you run this script with elevated (Administrator) privileges.
Modifying permissions incorrectly can lock you out of folders or destabilize the system. Use with caution.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

# --- Configuration ---
# Get the Security Identifier (SID) for the local Administrators group
$adminSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544") # Built-in Administrators group SID

# Define the access rule: Administrators, FullControl, Apply to 'This folder, subfolders and files'
# InheritanceFlags: ContainerInherit (subfolders inherit), ObjectInherit (files inherit)
# PropagationFlags: None (standard inheritance)
# AccessControlType: Allow
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Administrators",        # Or use $adminSID.Translate([System.Security.Principal.NTAccount])
    "FullControl",
    "ContainerInherit,ObjectInherit",
    "None",
    "Allow"
)

# --- Pre-Checks ---
# Check if running as Administrator
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object System.Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run with Administrator privileges." -ErrorAction Stop
}

# Check if the path exists and is a directory
if (-not (Test-Path $Path -PathType Container)) {
    Write-Error "The specified path '$Path' does not exist or is not a folder." -ErrorAction Stop
}

# --- Main Logic ---
Write-Host "Processing folder: $Path"

# Get all items recursively (folder + files + subfolders)
# Use -Force to include hidden/system items if necessary
try {
    # Process the top-level folder first
    Write-Verbose "Processing ACL for '$Path'" -Verbose
    $acl = Get-Acl -Path $Path -ErrorAction Stop

    # Set the Owner
    Write-Verbose "--> Setting owner to Administrators" -Verbose
    $acl.SetOwner($adminSID)

    # Add/Set the Full Control permission rule
    # Using SetAccessRule modifies an existing rule or adds if it doesn't exist.
    # Using AddAccessRule might add duplicates if a similar rule exists.
    Write-Verbose "--> Granting Administrators Full Control" -Verbose
    $acl.SetAccessRule($accessRule)

    # Apply the modified ACL
    Set-Acl -Path $Path -AclObject $acl -ErrorAction Stop
    Write-Verbose "--> Successfully applied ACL to '$Path'" -Verbose

    # Get child items and process them
    $childItems = Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue # Continue if some sub-items are inaccessible *initially*
    $totalItems = ($childItems | Measure-Object).Count
    $currentItem = 0

    Write-Host "Processing $totalItems sub-items..."

    foreach ($item in $childItems) {
        $currentItem++
        Write-Progress -Activity "Applying Permissions" -Status "Processing item $currentItem of $totalItems" -PercentComplete (($currentItem / $totalItems) * 100) -CurrentOperation $item.FullName

        Write-Verbose "Processing ACL for '$($item.FullName)'" -Verbose
        try {
            $itemAcl = Get-Acl -Path $item.FullName -ErrorAction Stop

            # Set the Owner
            Write-Verbose "--> Setting owner to Administrators for '$($item.FullName)'" -Verbose
            $itemAcl.SetOwner($adminSID)

            # Add/Set the Full Control permission rule
            Write-Verbose "--> Granting Administrators Full Control for '$($item.FullName)'" -Verbose
            $itemAcl.SetAccessRule($accessRule) # Use SetAccessRule for safety

            # Apply the modified ACL
            Set-Acl -Path $item.FullName -AclObject $itemAcl -ErrorAction Stop
             Write-Verbose "--> Successfully applied ACL to '$($item.FullName)'" -Verbose
        }
        catch {
            Write-Warning "Could not process '$($item.FullName)': $($_.Exception.Message)"
        }
    }
     Write-Progress -Activity "Applying Permissions" -Completed
     Write-Host "Finished processing sub-items."
}
catch {
    Write-Error "An error occurred during processing: $($_.Exception.Message)"
    # You might want more specific error handling here
}

Write-Host "Script finished."