# Convert your Administrator password to a secure string
$Password = ConvertTo-SecureString "password" -AsPlainText -Force
# Create a new PSCredential object using your Administrator domain\username and password
$Credential = New-Object System.Management.Automation.PSCredential ("Domain\UserName", $Password)
# Set the domain and username
$Domain = Read-Host -Prompt 'Input the users Domain like domain.com'
$UserName = Read-Host -Prompt 'Input UserName of account you wish to reset'
$NewPassword = Read-Host -Prompt 'Input new temporary Password for account'
# Reset the password
Set-ADAccountPassword -Credential $Credential -Server $Domain -Identity $UserName -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)