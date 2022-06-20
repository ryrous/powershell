$Certs = Get-ChildItem "Cert:\LocalMachine\" -Recurse
Foreach($Cert in $Certs) {
    If($Cert.NotAfter -lt (Get-Date)) {
        $Cert | Select-Object -Property FriendlyName, NotAfter
    }
}