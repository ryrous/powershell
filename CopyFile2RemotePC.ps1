$pcList = "pc1","pc2"
foreach ($pc in $pcList) {
    $MYSESSION = New-PSSession 
    Copy-Item –Path "C:\test.txt" –Destination "C:\" –ToSession $MYSESSION
    Remove-PSSession -Session $MYSESSION 
}