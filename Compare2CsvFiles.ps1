#Importing CSV
$File1 = Import-Csv -Path "C:\CsvCompare\NewList.csv"
#Importing CSV 
$File2 = Import-Csv -Path "C:\CsvCompare\DecomList.csv"
 
#Compare both CSV files - column SamAccountName
$Results = Compare-Object -ReferenceObject $File1 -DifferenceObject $File2 -Property Name -IncludeEqual

ForEach ($Result in $Results) {
    If ($Result.SideIndicator -eq "==") {
        Write-Output "Name: $($Result.Name) Status: $($File2.Where({$PSItem.Name -eq $Result.Name}).Status)"
    }
}