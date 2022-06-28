# Get Motherboard Information
Get-WmiObject Win32_BaseBoard | Select-Object PSComputerName, Manufacturer, Model, Name, Serialnumber, SKU, Product | Sort-Object PSComputerName | Format-Table -Autosize