#Importing CSV
$File1 = @(Import-Csv -Path ".\File1.csv")
#Importing CSV 
$File2 = @(Import-Csv -Path ".\File2.csv")
#Remove Rows from File2 that are not in File1
$File1 = @($File1 | Where-Object {
    @(Compare-Object $_ $File2 -Property Name -IncludeEqual -ExcludeDifferent).count -eq 1
}) | Export-Csv ".\File3.csv" -Append -NoTypeInformation