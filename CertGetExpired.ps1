$Certs = Get-ChildItem "Cert:\LocalMachine\" -Recurse
Foreach($Cert in $Certs) {
    If($Cert.NotAfter -lt (Get-Date)) {
        $Cert
    }
}
Read-Host -Prompt "Press Enter to exit"