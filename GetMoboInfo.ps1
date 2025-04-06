# Get Motherboard Information
Get-CimInstance -ClassName Win32_BaseBoard | Select-Object Manufacturer, Model, Product, SerialNumber, SKU | Format-Table -AutoSize