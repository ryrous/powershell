#Importing CSV
$File1 = Import-Csv -Path "C:\Scripts\NewList.csv"
#Importing CSV 
$File2 = Import-Csv -Path "C:\Scripts\DecomList.csv"
 
#Compare both CSV files - column SamAccountName
$Results = Compare-Object -ReferenceObject $File1 -DifferenceObject $File2 -Property Name -IncludeEqual
 
Foreach ($R in $Results) {
    $Status = $File2 | Where-Object Name -like $R.Name | Select-Object -ExpandProperty Status
    If ($R.sideindicator -eq "==") {
        Write-Output "Name: $($R.Name) Status: $($Status)" | Sort-Object -Property Name
    }
}