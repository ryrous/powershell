###### Run all from an Elevated PowerShell session ##########
##### Enable PowerShell Remoting #####
Enable-PSRemoting -Force
Start-Sleep 3
##### Workgroup Setup #####
Set-Item wsman:\localhost\client\trustedhosts * -force
Start-Sleep 3
Restart-Service WinRM
Start-Sleep 3
##### Enable CredSSP #####
Enable-WSManCredSSP –Role server -force
Start-Sleep 3
##### Set Execution Policy #####
Set-ExecutionPolicy -scope LocalMachine Unrestricted -force
Start-Sleep 3
Set-ExecutionPolicy -scope CurrentUser Unrestricted -force