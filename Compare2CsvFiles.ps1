$Path = "C:\Scripts"
$CsvFile1 = Import-Csv -Path "$($path)\CsvFile1.csv"
$CsvFile2 = Import-Csv -Path "$($path)\CsvFile2.csv"
$UserOutput = @()
    ForEach ($Name in $CsvFile1) {
        $NameMatch = $CsvFile2 | Where-Object {$_.Name -eq $Name}
        If($NameMatch) {
            # Process the data
            $UserOutput += New-Object PsObject -Property @{Name =$Name;column1=$NameMatch.column1;column2=$NameMatch.column2}
        }
        else {
            $UserOutput += New-Object PsObject -Property @{Name =$Name;column1 ="NA";column2 ="NA"}
        }
    }
$UserOutput | Format-Table