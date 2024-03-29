<#
!!! Do not setup audit on C: drive with this script, it's not behaving properly!

Script tested and verified working on Windows Server 2012 R2 Standard/Datacenter.

Script requires to enable SeRestorePrivilege for the current Powershell process. 
Please see https://gallery.technet.microsoft.com/Adjusting-Token-Privileges-9b6724fc for how to do this prior to executing the script.

To be executed from C: root directory.
Time running approximately: 5 minutes.
#>

#For all files in file.txt audit will be set for everyone for "Success" on this object only, permissions are not affected

Install-Module -Name AuditPolicyDsc -Force
Install-Module -Name ComputerManagementDsc -Force
Install-Module -Name SecurityPolicyDsc -Force
Install-Module -Name PSDesiredStateConfiguration -Force

$ServerList = Get-Content ".\Servers.txt"
Foreach($Server in $ServerList) {
    $ACL = Get-Acl -Audit -Path $Server #Getting the audit settings on the file from the list
    $ACE = New-Object System.Security.AccessControl.FileSystemAuditRule("Everyone","TakeOwnership,ChangePermissions","None","InheritOnly","Success") #Creating a new object to comply with audit requirement
    $ACL.AddAuditRule($Ace) #Append the new audit settings to the current ones
    Write-Host "Changing audit on $Server" #Setting the audit logging
    $ACL | Set-Acl -Path $Server -Confirm -ErrorAction Inquire
}
Set-Location HKLM:\System
$RegistryKey = 'HKLM:\System\CurrentControlSet\Services\EventLog\Security'
$ACLRK = Get-Acl -Audit -path $RegistryKey #Getting the audit settings on the registrykey
$ACERK = New-Object System.Security.AccessControl.RegistryAuditRule("Everyone","CreateLink","None","InheritOnly","Success") #Creating a new object audit settings
$ACLRK.AddAuditRule($AceRK) #Append the new audit settings to the current ones
Write-Host "Changing audit on HKLM:\System\CurrentControlSet\Services\EventLog\Security" #Setting the audit logging
$ACLRK | Set-Acl -Path $RegistryKey -Confirm -ErrorAction Inquire

Set-Location C:\
Write-Host "Changing HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\EnableLUA to 0" #Changing registry value from 1 to 0
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -Value 0
Write-Host "Changing HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services: Idle Session limit to 20 minutes" #Adding MaxIdleTime new registry key
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name MaxIdleTime -Value 1200000