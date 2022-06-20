$define = @{
    FilePath = 'C:\Git\PSautomateCert.pfx'
    Password = (ConvertTo-SecureString -AsPlainText -String 'password' -Force)
}
$cert = Export-PfxCertificate $define
$cert | Format-List