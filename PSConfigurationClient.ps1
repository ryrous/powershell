###### Run all from an Elevated PowerShell session ##########
##### Enable Remote Management #####
WinRM quickconfig
Enable-PSRemoting -Force

##### Trusted Hosts Setup #####
Set-Item WSMan:\localhost\Client\TrustedHosts *.yourdomain.com
Restart-Service WinRM

##### Enable CredSSP #####
Enable-WSManCredSSP -Role client -DelegateComputer * -Force

##### Set Execution Policy #####
Set-ExecutionPolicy -scope LocalMachine Unrestricted -Force
Set-ExecutionPolicy -scope CurrentUser Unrestricted -Force
