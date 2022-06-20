Get-Credential -Credential $env:USERNAME
$Credxmlpath = Join-Path (Split-Path $Profile) NameOfScript.ps1.credential
$Credential | Export-CliXml $Credxmlpath
$Credxmlpath = Join-Path (Split-Path $Profile) NameOfScript.ps1.credential
$Credential = Import-CliXml $Credxmlpath
