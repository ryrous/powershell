Get-ChildItem -Path C:\Windows\System32 -Recurse -File | Select-Object -Property Name | Sort-Object -Property Name | Export-Csv -Path C:\Users\Username\Downloads\System32Files.csv -UseCulture
