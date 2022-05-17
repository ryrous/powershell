$define = @{
    FriendlyName = 'PowerShell Automation'
    NotBefore = Get-Date
    NotAfter = ((Get-Date).AddYears(2))
    DnsName = 'PSautomate.domain.com'
    Subject = 'PSautomate.domain.com'
}
$cert = New-SelfSignedCertificate $define
$cert | Format-List