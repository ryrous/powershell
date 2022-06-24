<#
A valuable use of Import-Clixml on Windows computers is to import credentials and secure strings that were 
exported as secure XML using Export-Clixml. 
#>
Get-Credential -Credential $env:USERNAME
# Export
$Credxmlpath = Join-Path (Split-Path $Profile) NameOfScript.ps1.credential
$Credential | Export-CliXml $Credxmlpath
# Import
$Credxmlpath = Join-Path (Split-Path $Profile) NameOfScript.ps1.credential
$Credential = Import-CliXml $Credxmlpath