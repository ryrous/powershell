# Pull Audit HTML from Local Directory #

New-PSSession -ComputerName ServerName -Credential Domain\UserName  
Enter-PSSession -ComputerName ServerName
$name = (Get-Item env:\ComputerName).value 
$filepath = (Get-ChildItem env:\UserProfile).value
$Source = "C:\HardwareAudits\$name"
$Destination = $filepath+'\'+'Documents'
$Session = New-PSSession -ComputerName ServerName
Copy-Item -path $Source -Destination $Destination -ToSession $Session
Microsoft.PowerShell.Core\FileSystem::\\ServerName\hardwareaudits>
