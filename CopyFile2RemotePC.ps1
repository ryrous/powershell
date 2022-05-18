$MYSESSION = New-PSSession -ComputerName HOSTNAME.DOMAIN.COM
Copy-Item –Path "C:\test.txt" –Destination "C:\" –ToSession $MYSESSION
Remove-PSSession -Session $MYSESSION