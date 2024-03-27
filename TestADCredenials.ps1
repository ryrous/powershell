### VARIABLES ###
$VMs = Get-Content .\VMList.txt
$UserName = 'Domain\Username'
$Password = Read-Host "Enter your password: " -AsSecureString

### FUNCTIONS ###
function Test-ADAuthentication {
    param ($UserName,[SecureString] $Password)
    foreach ($VM in $VMs) {
        Write-Host "Testing AD authentication on $VM"
        $null -ne (New-Object directoryservices.directoryentry "",$UserName,$Password).PSBase.Name
    }
}

### TEST SSIADMT CREDENTIALS ###
Test-ADAuthentication $UserName $Password