### Script to scan a subnet for active computers
$Subnet = "10.0.1."
1..254|ForEach-Object{
  Start-Process -WindowStyle Hidden ping.exe -Argumentlist "-n 1 -l 0 -f -i 2 -w 1 -4 $SubNet$_"
}

$Computers = (arp.exe -a | Select-String "$SubNet.*dynam") -replace ' +',',' | ConvertFrom-Csv -Header Computername,IPv4,MAC,x,Vendor | Select-Object Computername,IPv4,MAC

ForEach ($Computer in $Computers) {
  nslookup $Computer.IPv4|Select-String -Pattern "^Name:\s+([^\.]+).*$" | ForEach-Object {
    $Computer.Computername = $_.Matches.Groups[1].Value
  }
}

### Display output
$Computers

### Output to CSV
#$FileOut = "C:\Temp\Computers.csv"
#$Computers | Export-Csv $FileOut -NotypeInformation

### Output to GridView
#$Computers | Out-Gridview
