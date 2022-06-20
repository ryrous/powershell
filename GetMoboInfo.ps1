Get-WmiObject Win32_BaseBoard | Export-Csv -Path C:\ExportDir\MBinfo.csv -Force 
# Format-Table PSComputerName, Manufacturer, Model, Name, Serialnumber, SKU, Product -autosize