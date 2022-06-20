function Get-PortQry {
    # Download PortQry utility
    Invoke-WebRequest -Uri https://www.microsoft.com/en-us/download/confirmation.aspx?id=17148 -OutFile $env:USERPROFILE\Downloads\PortQryV2.exe
    # Extract package
    Start-Process -Wait -FilePath $env:USERPROFILE\Downloads\PortQryv2.exe -ArgumentList '/q' -PassThru
}

function Get-ADMTPortStatus {
    # Set Directory
    Set-Location C:\PortQryV2
    # Test port for DNS
    .\portqry -n $Target -p tcp -e 53 -l C:\Temp\PortScanDNS.txt -y
    # Test port for Kerberos
    .\portqry -n $Target -p tcp -e 88 -l C:\Temp\PortScanKerberos.txt -y
    # Test port for RPC Endpoint Mapper
    .\portqry -n $Target -p tcp -e 135 -l C:\Temp\PortScanRPCend.txt -y
    # Test ports for SMB TCPNetBIOS Over TCP/IP
    .\portqry -n $Target -p udp -e 137 -l C:\Temp\PortScanSMBudp137.txt -y
    .\portqry -n $Target -p tcp -e 137 -l C:\Temp\PortScanSMBtcp137.txt -y
    .\portqry -n $Target -p udp -e 138 -l C:\Temp\PortScanSMBudp138.txt -y
    .\portqry -n $Target -p tcp -e 138 -l C:\Temp\PortScanSMBtcp138.txt -y
    # Test port for LDAP
    .\portqry -n $Target -p tcp -e 389 -l C:\Temp\PortScanLDAP.txt -y
    # Test port for SMB Hosting
    .\portqry -n $Target -p tcp -e 445 -l C:\Temp\PortScanSMBhost.txt -y
    # Test port for GC
    .\portqry -n $Target -p tcp -e 3268 -l C:\Temp\PortScanGC.txt -y
    # Test port range for RPC (full dynamic port range) (this will take a very long time)
    #.\portqry -n $Target -p tcp -r 1024:65535 -l C:\Temp\PortScanRPCrange.txt -y
}

function Show-FilteredPorts {
    $Logs = (Get-ChildItem -Path C:\Temp\ -Filter "PortScan*").Name
    foreach ($Log in $Logs) {
        Get-Content -Path C:\Temp\$Log | Select-Object -First 23 | Select-Object -Last 1 
    }
}

$Target = "8.8.8.8"
Get-ADMTPortStatus
Show-FilteredPorts