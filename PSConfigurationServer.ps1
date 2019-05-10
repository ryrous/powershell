###### Run all from an Elevated PowerShell session ##########
##### Enable Remote Management #####
WinRM quickconfig
Enable-PSRemoting -Force

##### Workgroup Setup #####
Set-Item wsman:\localhost\client\trustedhosts * -Force
Restart-Service WinRM

##### Enable CredSSP #####
Enable-WSManCredSSP –Role Server -Force

##### Set Execution Policy #####
Set-ExecutionPolicy -scope LocalMachine Unrestricted -Force
Set-ExecutionPolicy -scope CurrentUser Unrestricted -Force
