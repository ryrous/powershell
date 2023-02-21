$Password = ConvertTo-SecureString "password" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ("Domain\UserName", $Password)
$Domain = "domain.com"
$UserName = "UserName"
Set-ADAccountPassword -Credential $Credential -Server $Domain -Identity $UserName -NewPassword (ConvertTo-SecureString -AsPlainText "NewPassword" -Force)