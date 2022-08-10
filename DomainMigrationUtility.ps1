<# DOMAIN MIGRATION UTILITY - VERSION 1.4 #>
using namespace System.Management.Automation.Host

<# GENERAL VARIABLES #>
$VMs = Get-Content .\VMList.txt
$Domain = 'domain.com'
$DC = 'COMPUTERNAME'
$DCIP = '10.10.10.30'
$PingDomain = "ping $Domain"
$PingDC = "ping $DC.$Domain"
$PingDCIP = "ping $DCIP"
$UsersInGroup = "net localgroup Administrators"
$Add2GroupCD = "net localgroup Administrators Domain\Username /add"
$GetDomainOnVM = "wmic computersystem get domain"
$GetDNSAddress = "netsh interface ipv4 show dnsserver"
$SetDNSAddress1 = "netsh interface ipv4 set dnsserver ""Ethernet"" static 10.10.10.1 primary"
$SetDNSAddress2 = "netsh interface ipv4 add dnsserver ""Ethernet"" 10.10.10.2"
$RegisterDNS = "ipconfig /registerdns"
$GetSvcOnVM = "wmic service get name,startname | sort"
$GetDomainSvc = "wmic service get startname | find ""svc startname"" | sort"
$FWStatus = "netsh advfirewall show allprofiles state"
$FWDisable = "netsh advfirewall set allprofiles state off"
$ManualMoveScript = '$DomainUser = "Domain\Username";
                $DomainPWord = ConvertTo-SecureString -String "Password" -AsPlainText -Force;
                $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $DomainPWord;
                Add-Computer -DomainName "domain.com" -Credential $DomainCredential;
                Start-Sleep -Seconds 20;
                Shutdown /r /t 0'


<# DOMAIN LOGIN VARIABLES #>
Write-Host "Let's get started! Please enter your Domain credentials." -ForegroundColor Magenta -BackgroundColor Black
$GuestUser = Read-Host "Enter your Domain UserName (Domain\UserName): "
$GuestPasswordSec = Read-Host "Enter your Domain Password: " -AsSecureString
$GuestPassword = ConvertFrom-SecureString -SecureString $GuestPasswordSec -AsPlainText
$GuestCreds = New-Object System.Management.Automation.PSCredential ($GuestUser, $GuestPasswordSec)
<# ADMT LOGIN VARIABLES #>
Write-Host "Now let's get your ADMT credentials." -ForegroundColor Magenta -BackgroundColor Black
$ADMTAccount = Read-Host "Enter your ADMT account UserName (Domain\UserName): "
$ADMTPasswordSec = Read-Host "Enter your ADMT account Password: " -AsSecureString
$ADMTPassword = ConvertFrom-SecureString -SecureString $ADMTPasswordSec -AsPlainText
$ADMTCreds = New-Object System.Management.Automation.PSCredential ($ADMTAccount, $ADMTPasswordSec)
<# VCENTER LOGIN VARIABLES #>
Write-Host "Last step! Enter your vCenter password." -ForegroundColor Magenta -BackgroundColor Black
$vCenter = "10.10.10.20"
$vCenterUser = Read-Host "Enter your vCenter UserName (Domain\UserName): "
$vCenterPasswordSec = Read-Host "Enter your vCenter Password: " -AsSecureString
$vCenterPassword = ConvertFrom-SecureString -SecureString $vCenterPasswordSec -AsPlainText


<# FUNCTIONS #>
function Show-Menu {
    param (
        [string]$Title = 'Domain Migration Utility v1.4'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "VCENTER AND LIST VERIFICATION" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "1: Press '1' to connect to vCenter." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "2: Press '2' to disconnect from vCenter." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "3: Press '3' to show VMs in list." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "4: Press '4' to see if VMs are in vCenter." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "5: Press '5' to reboot a specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "6a: Press '6a' to check Power Status on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "6b: Press '6b' to power on a specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "6c: Press '6c' to shutdown a specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "6d: Press '6d' to power off a specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "7a: Press '7a' to check VMware Tools on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "7b: Press '7b' to update VMware Tools on specific VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "ADMT ACCOUNTS AND LOCAL ADMIN GROUPS" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "11a: Press '11a' to show users in Admins group on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "11b: Press '11b' to show users in Admins group on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "12a: Press '12a' to add ADMT account to Admins group on specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "12b: Press '12b' to add ADMT account to Admins group on each VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "14: Press '14' to test authentication of ADMT account." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "IP AND DNS ADDRESSES" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "21a: Press '21a' to get IP Address for specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "21b: Press '21b' to get IP Address for each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "22a: Press '22a' to get the current Domain for specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "22b: Press '22b' to get the current Domain for each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "23a: Press '23a' to get DNS Server Address on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "23b: Press '23b' to get DNS Server Address for each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "24a: Press '24a' to set the DNS Server Address on specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "24b: Press '24b' to set the DNS Server Address on each VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "25a: Press '25a' to register DNS on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "25b: Press '25b' to register DNS on each VM." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "SERVICES" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "31a: Press '31a' to get all services on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "31b: Press '31b' to get all services on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "32a: Press '32a' to check for a specific Service on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "32b: Press '32b' to check for a specific Service on each VM." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "NETWORK CONNECTIVITY" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "41a: Press '41a' to ping ComputerName of specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "41b: Press '41b' to ping ComputerName of each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "42a: Press '42a' to ping IP Address of specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "42b: Press '42b' to ping IP Address of each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "43a: Press '43a' to ping the Admin share on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "43b: Press '43b' to ping the Admin share on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "44a: Press '44a' to test reachability of DC from specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "44b: Press '44b' to test reachability of DC from each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "44c: Press '44c' to test reachability of DC IP from each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "48a: Press '48a' to check ADMT ports on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "48b: Press '48b' to check ADMT ports on each VM." -ForegroundColor DarkGreen -BackgroundColor Black

    Write-Host "WINDOWS FIREWALL" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "51a: Press '51a' to get status of Windows Firewall on specific VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "51b: Press '51b' to get status of Windows Firewall on each VM." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "52a: Press '52a' to disable Windows Firewall on specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "52b: Press '52b' to disable Windows Firewall on each VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "BACKUP POLICY" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "61a: Press '61a' to check Backup Policy on specific VM is set to Exclude." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "61b: Press '61b' to check Backup Policy on each VM is set to Exclude." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "62a: Press '62a' to check Backup Policy on specific VM is set to Snapshot." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "62b: Press '62b' to check Backup Policy on each VM is set to Snapshot." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "64a: Press '64a' to set Backup Policy to Exclude on specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "64b: Press '64b' to set Backup Policy to Exclude on each VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "65a: Press '65a' to set Backup Policy to Snapshot on specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "65b: Press '65b' to set Backup Policy to Snapshot on each VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "SNAPSHOTS" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "71a: Press '71a' to take Snapshot of specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "71b: Press '71b' to take Snapshot of each VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "72a: Press '72a' to remove all Snapshots of specific VM." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "72b: Press '72b' to remove all Snapshots of each VM." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "MANUAL MOVES" -ForegroundColor DarkYellow -BackgroundColor Black
    Write-Host "81a: Press '81a' to manually move specific VM to new domain." -ForegroundColor Blue -BackgroundColor Black
    Write-Host "81b: Press '81b' to manually move each VM to new domain." -ForegroundColor Blue -BackgroundColor Black

    Write-Host "Q: Press 'Q' to quit."
}


<# VCENTER AND LIST VERIFICATION #>
function Connect-2vCenter {
    Connect-VIServer -Server $vCenter -User $vCenterUser -Password $vCenterPassword
}

function Get-LocationOfVMs {
    if (VMware.VimAutomation.Core\Get-VM $VM) {
        Write-Host "$VM exists in vCenter" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "$VM does not exist in vCenter" -ForegroundColor Red -BackgroundColor Black
    }
}

function Invoke-RebootOfVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Restarting $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    Restart-VMGuest $TargetVM
}

function Get-PowerStatusOfVM {
    Write-Host "Getting Power Status of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $VM) | Select-Object Powerstate
}

function Start-PoweredOffVM {
    Write-Host "Starting $VM" -ForegroundColor Blue -BackgroundColor Black
    Start-VM -VM $VM -Confirm:$false
}

function Invoke-ShutdownOfVM {
    Write-Host "Shutting down $VM" -ForegroundColor Blue -BackgroundColor Black
    Shutdown-VMGuest -VM $VM -Confirm:$False
}

function Invoke-PowerOffOfVM {
    Write-Host "Starting $VM" -ForegroundColor Blue -BackgroundColor Black
    Stop-VM -VM $VM -Confirm:$False
}

function Get-VMwareToolsStatusOfVM {
    Write-Host "Getting VMware Tools Status of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    ((VMware.VimAutomation.Core\Get-VM $VM) | Get-View).Guest.ToolsStatus
}

function Update-VmWareToolsOnVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Updating VmWare Tools on $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | Update-Tools -NoReboot
}

<# ADMT ACCOUNTS AND LOCAL ADMIN GROUPS #>
function Get-UsersInAdminGroup {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting users in Administrators group on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $UsersInGroup
    $SO.ScriptOutput
}

function Get-UsersInAdminGroupAll {
    Write-Host "Getting users in Administrators group on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $UsersInGroup
    $SO.ScriptOutput
}

function Add-Account2Group {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Adding SSIADMT to Administrators group on $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $Add2GroupCD
    $SO.ScriptOutput
}

function Add-Account2GroupAll {
    Write-Host "Adding SSIADMT to Administrators group on $VM" -ForegroundColor Blue -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $Add2GroupCD
    $SO.ScriptOutput
}

function Test-ADAuthentication {
    param ($ADMTAccount,[SecureString] $ADMTPassword)
    Write-Host "Testing ADMT authentication on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $null -ne (New-Object directoryservices.directoryentry "",$ADMTAccount,$ADMTPassword).PSBase.Name
}

<# IP AND DNS ADDRESSES #>
function Get-IPAddress4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting IP of $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $TargetVM).Guest.IPAddress[0]
}
function Get-IPAddress4VMAll {
    Write-Host "Getting IP of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $VM).Guest.IPAddress[0]
}

function Get-DomainOnVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting Domain of $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Powershell -ScriptText $GetDomainOnVM
    $SO.ScriptOutput
}

function Get-DomainOnVMAll {
    Write-Host "Getting Domain of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Powershell -ScriptText $GetDomainOnVM
    $SO.ScriptOutput
}

function Get-DNSServerAddress {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting DNS Server Address on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetDNSAddress
    $SO.ScriptOutput
}

function Get-DNSServerAddressAll {
    Write-Host "Getting DNS Server Address on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetDNSAddress
    $SO.ScriptOutput
}

function Set-DNSServerAddress {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Setting DNS Server Address 1 on $TargetVM..." -ForegroundColor Blue -BackgroundColor Black
    $SO1 = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $SetDNSAddress1
    $SO1.ScriptOutput
    Write-Host "DNS Server Address 1 on $TargetVM has been set." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "Setting DNS Server Address 2 on $TargetVM..." -ForegroundColor Blue -BackgroundColor Black
    $SO2 = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $SetDNSAddress2
    $SO2.ScriptOutput
    Write-Host "DNS Server Address 2 on $TargetVM has been set." -ForegroundColor DarkGreen -BackgroundColor Black
}

function Set-DNSServerAddressAll {
    Write-Host "Setting DNS Server Address 1 on $VM..." -ForegroundColor Blue -BackgroundColor Black
    $SO1 = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $SetDNSAddress1
    $SO1.ScriptOutput
    Write-Host "DNS Server Address 1 on $VM has been set." -ForegroundColor DarkGreen -BackgroundColor Black
    Write-Host "Setting DNS Server Address 2 on $VM..." -ForegroundColor Blue -BackgroundColor Black
    $SO2 = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $SetDNSAddress2
    $SO2.ScriptOutput
    Write-Host "DNS Server Address 2 on $VM has been set." -ForegroundColor DarkGreen -BackgroundColor Black
}

function Invoke-RegisterDNS {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Registering DNS on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $RegisterDNS
    $SO.ScriptOutput
}

function Invoke-RegisterDNSAll {
    Write-Host "Registering DNS on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $RegisterDNS
    $SO.ScriptOutput
}

<# SERVICES #>
function Get-ServicesOnVM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting List of all Services on $TargetVM"
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetSvcOnVM
    $SO.ScriptOutput
}

function Get-ServicesAll {
    Write-Host "Getting List of all Services on $VM"
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetSvcOnVM
    $SO.ScriptOutput
}

function Get-SpecificSVC {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Finding Service on $TargetVM"
    $SO1 = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetDomainSvc
    if ($SO1.ScriptOutput -like "*biz*") {
        Write-Host "Service Found on $TargetVM" -ForegroundColor Red -BackgroundColor Black
        $SO1.ScriptOutput
    } else {
        Write-Host "Service not Found on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    }
}

function Get-SpecificSVCAll {
    Write-Host "Finding Service on $VM"
    $SO1 = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $GetDomainSvc
    if ($SO1.ScriptOutput -like "*biz*") {
        Write-Host "Service Found on $VM" -ForegroundColor Red -BackgroundColor Black
        $SO1.ScriptOutput
    } else {
        Write-Host "Service not Found on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    }
}

<# NETWORK CONNECTIVITY #>
function Get-PingStatus {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Pinging $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    Test-Connection -TargetName $TargetVM -ResolveDestination | Select-Object -ExpandProperty Status
}

function Get-PingStatusAll {
    Write-Host "Pinging $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    Test-Connection -TargetName $VM -ResolveDestination | Select-Object -ExpandProperty Status
}

function Get-PingStatusIP {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Pinging IP of $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $IP = (VMware.VimAutomation.Core\Get-VM $TargetVM).Guest.IPAddress[0]
    Test-Connection -TargetName $IP -IPv4 -ResolveDestination | Select-Object -ExpandProperty Status
}

function Get-PingStatusIPAll {
    Write-Host "Pinging IP of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $IP = (VMware.VimAutomation.Core\Get-VM $VM).Guest.IPAddress[0]
    Test-Connection -TargetName $IP -IPv4 -ResolveDestination | Select-Object -ExpandProperty Status
}

function Get-PingStatusAdmin {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Pinging Admin Share on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    Test-Connection -TargetName \\$TargetVM\Admin$ -ResolveDestination | Select-Object -ExpandProperty Status
}

function Get-PingStatusAdminAll {
    Write-Host "Pinging Admin Share on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    Test-Connection -TargetName \\$VM\Admin$ -ResolveDestination | Select-Object -ExpandProperty Status
}

function Test-ReachDomain {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Testing BIZ DC Reachability from $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Powershell -ScriptText $PingDC
    $SO.ScriptOutput
}

function Test-ReachDomainAll {
    Write-Host "Testing BIZ DC Reachability from $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Powershell -ScriptText $PingDC
    $SO.ScriptOutput
}

function Test-ReachDomainDCIP {
    Write-Host "Testing BIZ DC IP Reachability from $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Powershell -ScriptText $PingDCIP
    $SO.ScriptOutput
}

function Test-ADMTPorts {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    $IPAddress = (VMware.VimAutomation.Core\Get-VM $TargetVM).Guest.IPAddress[0]
    $PortDNS = 53
    $PortKerberos = 88
    $PortRPC = 135
    $PortLDAP = 389
    $PortSMB = 445
    $PortGC = 3268

    Write-Host "Checking DNS Port for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $DNS = Test-NetConnection -ComputerName $IPAddress -Port $PortDNS | Select-Object TcpTestSucceeded
    if ($DNS -eq 'true') {
        Write-Host "DNS Port is open on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "DNS Port is closed on $TargetVM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking Kerberos Port for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $Kerberos = Test-NetConnection -ComputerName $IPAddress -Port $PortKerberos | Select-Object TcpTestSucceeded
    if ($Kerberos -eq 'true') {
        Write-Host "Kerberos Port is open on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "Kerberos Port is closed on $TargetVM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking RPC Port for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $RPC = Test-NetConnection -ComputerName $IPAddress -Port $PortRPC | Select-Object TcpTestSucceeded
    if ($RPC -eq 'true') {
        Write-Host "RPC Port is open on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "RPC Port is closed on $TargetVM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking LDAP Port for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $LDAP = Test-NetConnection -ComputerName $IPAddress -Port $PortLDAP | Select-Object TcpTestSucceeded
    if ($LDAP -eq 'true') {
        Write-Host "LDAP Port is open on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "LDAP Port is closed on $TargetVM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking SMB Port for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SMB = Test-NetConnection -ComputerName $IPAddress -Port $PortSMB | Select-Object TcpTestSucceeded
    if ($SMB -eq 'true') {
        Write-Host "SMB Port is open on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "SMB Port is closed on $TargetVM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking GC Port for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $GC = Test-NetConnection -ComputerName $IPAddress -Port $PortGC | Select-Object TcpTestSucceeded
    if ($GC -eq 'true') {
        Write-Host "GC Port is open on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "GC Port is closed on $TargetVM" -ForegroundColor Red -BackgroundColor Black
    }
}

function Test-ADMTPortsAll {
    $IPAddress = (VMware.VimAutomation.Core\Get-VM $VM).Guest.IPAddress[0]
    $PortDNS = 53
    $PortKerberos = 88
    $PortRPC = 135
    $PortLDAP = 389
    $PortSMB = 445
    $PortGC = 3268

    Write-Host "Checking DNS Port for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $DNS = Test-NetConnection -ComputerName $IPAddress -Port $PortDNS | Select-Object TcpTestSucceeded
    if ($DNS -eq 'true') {
        Write-Host "DNS Port is open on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "DNS Port is closed on $VM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking Kerberos Port for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $Kerberos = Test-NetConnection -ComputerName $IPAddress -Port $PortKerberos | Select-Object TcpTestSucceeded
    if ($Kerberos -eq 'true') {
        Write-Host "Kerberos Port is open on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "Kerberos Port is closed on $VM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking RPC Port for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $RPC = Test-NetConnection -ComputerName $IPAddress -Port $PortRPC | Select-Object TcpTestSucceeded
    if ($RPC -eq 'true') {
        Write-Host "RPC Port is open on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "RPC Port is closed on $VM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking LDAP Port for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $LDAP = Test-NetConnection -ComputerName $IPAddress -Port $PortLDAP | Select-Object TcpTestSucceeded
    if ($LDAP -eq 'true') {
        Write-Host "LDAP Port is open on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "LDAP Port is closed on $VM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking SMB Port for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SMB = Test-NetConnection -ComputerName $IPAddress -Port $PortSMB | Select-Object TcpTestSucceeded
    if ($SMB -eq 'true') {
        Write-Host "SMB Port is open on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "SMB Port is closed on $VM" -ForegroundColor Red -BackgroundColor Black
    }

    Write-Host "Checking GC Port for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $GC = Test-NetConnection -ComputerName $IPAddress -Port $PortGC | Select-Object TcpTestSucceeded
    if ($GC -eq 'true') {
        Write-Host "GC Port is open on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "GC Port is closed on $VM" -ForegroundColor Red -BackgroundColor Black
    }
}

<# WINDOWS FIREWALL #>
function Get-WinFirewallStatus {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Getting Firewall Status on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPasswordSec -ScriptType Bat -ScriptText $FWStatus
    $SO.ScriptOutput
}

function Get-WinFirewallStatusAll {
    Write-Host "Getting Firewall Status on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPasswordSec -ScriptType Bat -ScriptText $FWStatus
    $SO.ScriptOutput
}

function Set-WinFirewallOff {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Disabling Windows Firewall on $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $FWDisable
    $SO.ScriptOutput
}

function Set-WinFirewallOffAll {
    Write-Host "Disabling Windows Firewall on $VM" -ForegroundColor Blue -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $GuestUser -GuestPassword $GuestPassword -ScriptType Bat -ScriptText $FWDisable
    $SO.ScriptOutput
}

<# BACKUP FUNCTIONS #>
function Show-BackupPolicyExclude {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Checking Backup Policy on $TargetVM"
    $BUExclude = Get-Annotation -Entity $TargetVM -CustomAttribute "BackupPolicy" | Select-Object Value
    if ($BUExclude.Value -eq "Exclude") {
        Write-Host "Backup Policy on $TargetVM set to Exclude" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "Backup Policy on $TargetVM NOT set to Exclude" -ForegroundColor Red -BackgroundColor Black
    }
}

function Show-BackupPolicyExcludeAll {
    Write-Host "Checking Backup Policy on $VM"
    $BUExclude = Get-Annotation -Entity $VM -CustomAttribute "BackupPolicy" | Select-Object Value
    if ($BUExclude.Value -eq "Exclude") {
        Write-Host "Backup Policy on $VM set to Exclude" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "Backup Policy on $VM NOT set to Exclude" -ForegroundColor Red -BackgroundColor Black
    }
}

function Show-BackupPolicySnapshot {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Checking Backup Policy on $TargetVM"
    $BUSnapshot = Get-Annotation -Entity $TargetVM -CustomAttribute "BackupPolicy" | Select-Object Value
    if ($BUSnapshot.Value -eq "Snapshot") {
        Write-Host "Backup Policy on $TargetVM set to Snapshot" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "Backup Policy on $TargetVM NOT set to Snapshot" -ForegroundColor Red -BackgroundColor Black
    }
}

function Show-BackupPolicySnapshotAll {
    Write-Host "Checking Backup Policy on $VM"
    $BUSnapshot = Get-Annotation -Entity $VM -CustomAttribute "BackupPolicy" | Select-Object Value
    if ($BUSnapshot.Value -eq "Snapshot") {
        Write-Host "Backup Policy on $VM set to Snapshot" -ForegroundColor DarkGreen -BackgroundColor Black
    } else {
        Write-Host "Backup Policy on $VM NOT set to Snapshot" -ForegroundColor Red -BackgroundColor Black
    }
}

function Set-BackupPolicy2Exclude {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Setting VMs Backup Policy to Exclude" 
    if ((Get-Annotation -Entity $TargetVM -CustomAttribute "BackupPolicy" | Select-Object Value) -ne "Exclude") {
            Write-Host "Setting Backup Policy on $TargetVM to Exclude" -ForegroundColor Blue -BackgroundColor Black
            Set-Annotation -Entity $TargetVM -CustomAttribute "BackupPolicy" -Value "Exclude" 
        }
    Write-Host "Finished setting Backup Policy on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
}

function Set-BackupPolicy2ExcludeAll {
    Write-Host "Setting VMs Backup Policy to Exclude" 
    if ((Get-Annotation -Entity $VM -CustomAttribute "BackupPolicy" | Select-Object Value) -ne "Exclude") {
            Write-Host "Setting Backup Policy on $VM to Exclude" -ForegroundColor Blue -BackgroundColor Black
            Set-Annotation -Entity $VM -CustomAttribute "BackupPolicy" -Value "Exclude" 
        }
    Write-Host "Finished setting Backup Policy on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

function Set-BackupPolicy2Snapshot {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Setting VMs Backup Policy to Snapshot" 
    if ((Get-Annotation -Entity $TargetVM -CustomAttribute "BackupPolicy" | Select-Object Value) -ne "Snapshot") {
            Write-Host "Setting Backup Policy on $TargetVM to Snapshot" -ForegroundColor Blue -BackgroundColor Black
            Set-Annotation -Entity $TargetVM -CustomAttribute "BackupPolicy" -Value "Snapshot" 
        }
    Write-Host "Finished setting Backup Policy on $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black
}

function Set-BackupPolicy2SnapshotAll {
    Write-Host "Setting VMs Backup Policy to Snapshot" 
    if ((Get-Annotation -Entity $VM -CustomAttribute "BackupPolicy" | Select-Object Value) -ne "Snapshot") {
            Write-Host "Setting Backup Policy on $VM to Snapshot" -ForegroundColor Blue -BackgroundColor Black
            Set-Annotation -Entity $VM -CustomAttribute "BackupPolicy" -Value "Snapshot" 
        }
    Write-Host "Finished setting Backup Policy on $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

<# SNAPSHOT FUNCTIONS #>
function New-Snap4Salvation {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Creating new snapshot of $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    New-Snapshot -VM $TargetVM -Name $TargetVM.SNAPSHOT -Description "Snapshot" -Quiesce -Memory:$false -Confirm:$false
    Write-Host "Finished creating new snapshot of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

function New-Snap4SalvationAll {
    Write-Host "Creating new snapshot of $VM" -ForegroundColor Blue -BackgroundColor Black
    New-Snapshot -VM $VM -Name $VM.SNAPSHOT -Description "Snapshot" -Quiesce -Memory:$false -Confirm:$false
    Write-Host "Finished creating new snapshot of $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

function Remove-AllSnapshots4VM {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Removing Snapshots for $TargetVM" -ForegroundColor Blue -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $TargetVM) | Get-Snapshot | ForEach-Object {Remove-Snapshot $_ -Confirm:$false}
    Write-Host "Finished removing Snapshots for $TargetVM" -ForegroundColor DarkGreen -BackgroundColor Black

}

function Remove-AllSnapshots4All {
    Write-Host "Removing Snapshots for each $VM" -ForegroundColor Blue -BackgroundColor Black
    (VMware.VimAutomation.Core\Get-VM $VM) | Get-Snapshot | ForEach-Object {Remove-Snapshot $_ -Confirm:$false}
    Write-Host "Finished removing Snapshots for $VM" -ForegroundColor DarkGreen -BackgroundColor Black
}

<# MANUAL MOVE FUNCTIONS #>
function Add-VM2NewDomain {
    $TargetVM = Read-Host -Prompt "Enter the name of the VM: "
    Write-Host "Moving $TargetVM to new domain..." -ForegroundColor Blue -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($TargetVM) -GuestUser $ADMTAccount -GuestPassword $ADMTPassword -ScriptType Powershell -ScriptText $ManualMoveScript
    $SO.ScriptOutput
    Write-Host "Done!" -ForegroundColor Green -BackgroundColor Black
}

function Add-VM2NewDomainAll {
    Write-Host "Moving $VM to new domain..." -ForegroundColor Blue -BackgroundColor Black
    $SO = Invoke-VMScript -VM ($VM) -GuestUser $ADMTAccount -GuestPassword $ADMTPassword -ScriptType Powershell -ScriptText $ManualMoveScript
    $SO.ScriptOutput
    Write-Host "Done!" -ForegroundColor Green -BackgroundColor Black
}


<# EXECUTE INTERACTIVE MENU #>
do {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection) {
        <# VCENTER AND LIST VERIFICATION #>
        '1' {
            'Connecting to vCenter...'
            Connect-2vCenter
        }
        '2' {
            'Disconnecting from vCenter...'
            Disconnect-VIServer -Confirm:$false
        }
        '3' {
            'Getting list of VMs...'
            Get-Content .\VMList.txt
        }
        '4' {
            'Checking list of VMs for existence in vCenter...'
            foreach ($VM in $VMs) {
                Get-LocationOfVMs
            }
        }
        '5' {
            'Getting list of VMs...'
            Invoke-RebootOfVM
        }
        '6a' {
            'Getting Power Status of VMs...'
            foreach ($VM in $VMs) {
                Get-PowerStatusOfVM
            }
        }
        '6b' {
            'Powering On specific VM...'
            Start-PoweredOffVM
        }
        '6c' {
            'Shutting Down specific VM...'
            Invoke-ShutdownOfVM
        }
        '6d' {
            'Powering Off specific VM...'
            Invoke-PowerOffOfVM
        }
        '7a' {
            'Getting VMware Tools Status of VMs...'
            foreach ($VM in $VMs) {
                Get-VMwareToolsStatusOfVM
            }
        }
        '7b' {
            'Updating VMware Tools on specific VM...'
            Update-VmWareToolsOnVM
        }
        <# ADMT ACCOUNTS AND LOCAL ADMIN GROUPS #>
        '11a' {
            'Getting users in Admins group on specific VM...'
            Get-UsersInAdminGroup
        }
        '11b' {
            'Getting users in Admins group on each VM...'
            foreach ($VM in $VMs) {
                Get-UsersInAdminGroupAll
            }
        }
        '12a' {
            'Adding ADMT account to Admins group on specific VM...'
            Add-Account2Group
        }
        '12b' {
            'Adding ADMT account to Admins group on each VM...'
            foreach ($VM in $VMs) {
                Add-Account2GroupAll
            }
        }
        '14' {
            'Testing authentication of ADMT account...'
            foreach ($VM in $VMs) {
                Test-ADAuthentication
            }
        }
        <# IP AND DNS ADDRESSES #>
        '21a' {
            'Getting IP Address for each VM...'
            Get-IPAddress4VM
        }
        '21b' {
            'Getting IP Address for each VM...'
            foreach ($VM in $VMs) {
                Get-IPAddress4VMAll
            }
        }
        '22a' {
            'Getting Domain for each VM...'
            Get-DomainOnVM
        }
        '22b' {
            'Getting Domain for each VM...'
            foreach ($VM in $VMs) {
                Get-DomainOnVMAll
            }
        }
        '23a' {
            'Getting DNS Server Address on specific VM...'
            Get-DNSServerAddress
        }
        '23b' {
            'Getting DNS Server Address for each VM...'
            foreach ($VM in $VMs) {
                Get-DNSServerAddressAll
            }
        }
        '24a' {
            'Setting the DNS Server Address on specific VM...'
            Set-DNSServerAddress
        }
        '24b' {
            'Setting the DNS Server Address on each VM...'
            foreach ($VM in $VMs) {
                Set-DNSServerAddressAll
            }
        }
        '25a' {
            'Registering DNS on specific VM...'
            Invoke-RegisterDNS
        }
        '25b' {
            'Registering DNS on each VM...'
            foreach ($VM in $VMs) {
                Invoke-RegisterDNSAll
            }
        }
        <# SERVICES #>
        '31a' {
            'Getting list of all Services on specific VM...'
            Get-ServicesOnVM
        }
        '31b' {
            'Getting list of all Services on each VM...'
            foreach ($VM in $VMs) {
                Get-ServicesAll
            }
        }
        '32a' {
            'Finding Service on specific VM...'
            Get-SpecificSVC
        }
        '32b' {
            'Finding Service on each VM...'
            foreach ($VM in $VMs) {
                Get-SpecificSVCAll
            }
        }
        <# NETWORK CONNECTIVITY #>
        '41a' {
            'Pinging specific VM by ComputerName...'
            Get-PingStatus
        }
        '41b' {
            'Pinging each VM by ComputerName...'
            foreach ($VM in $VMs) {
                Get-PingStatusAll
            }
        }
        '42a' {
            'Pinging specific VM by IP...'
            Get-PingStatusIP
        }
        '42b' {
            'Pinging each VM by IP...'
            foreach ($VM in $VMs) {
                Get-PingStatusIPAll
            }
        }
        '43a' {
            'Pinging the Admin share on each VM...'
            Get-PingStatusAdmin
        }
        '43b' {
            'Pinging the Admin share on each VM...'
            foreach ($VM in $VMs) {
                Get-PingStatusAdminAll
            }
        }
        '44a' {
            'Testing reachability of DC on specific VM...'
            Test-ReachDomain
        }
        '44b' {
            'Testing reachability of DC from each VM...'
            foreach ($VM in $VMs) {
                Test-ReachDomainAll
            }
        }
        '44c' {
            'Testing reachability of DC IP from each VM...'
            foreach ($VM in $VMs) {
                Test-ReachDomainDCIP
            }
        }
        <# WINDOWS FIREWALL #>
        '51a' {
            'Getting status of Windows Firewall on specific VM...'
            Get-WinFirewallStatus
        }
        '51b' {
            'Getting status of Windows Firewall on each VM...'
            foreach ($VM in $VMs) {
                Get-WinFirewallStatusAll
            }
        }
        '52a' {
            'Disabling Windows Firewall on specific VM...'
            Set-WinFirewallOff
        }
        '52b' {
            'Disabling Windows Firewall on each VM...'
            foreach ($VM in $VMs) {
                Set-WinFirewallOffAll
            }
        }
        <# BACKUP POLICY #>
        '61a' {
            'Show list of VMs with Backup Policy set to Exclude...'
            Show-BackupPolicyExclude
        }
        '61b' {
            'Show list of VMs with Backup Policy set to Exclude...'
            foreach ($VM in $VMs) {
                Show-BackupPolicyExcludeAll
            }
        }
        '62a' {
            'Show list of VMs with Backup Policy set to Snapshot...'
            Show-BackupPolicySnapshot
        }
        '62b' {
            'Show list of VMs with Backup Policy set to Snapshot...'
            foreach ($VM in $VMs) {
                Show-BackupPolicySnapshotAll
            }
        }
        '64a' {
            'Set Backup Policy to Exclude on each VM...'
            Set-BackupPolicy2Exclude
        }
        '64b' {
            'Set Backup Policy to Exclude on each VM...'
            foreach ($VM in $VMs) {
                Set-BackupPolicy2ExcludeAll
            }
        }
        '65a' {
            'Set Backup Policy to Snapshot on each VM...'
            Set-BackupPolicy2Snapshot
        }
        '65b' {
            'Set Backup Policy to Snapshot on each VM...'
            foreach ($VM in $VMs) {
                Set-BackupPolicy2SnapshotAll
            }
        }
        <# SNAPSHOTS #>
        '71a' {
            'Take Snapshot of specific VM...'
            New-Snap4Salvation
        }
        '71b' {
            'Take Snapshot of each VM...'
            foreach ($VM in $VMs) {
                New-Snap4SalvationAll
            }
        }
        '72a' {
            'Remove Snapshots of specific VM...'
            Remove-AllSnapshots4VM
        }
        '72b' {
            'Remove Snapshots of each VM...'
            foreach ($VM in $VMs) {
                Remove-AllSnapshots4All
            }
        }
        <# MANUAL MOVES #>
        '81a' {
            'Manually moving specific VM...'
            Add-VM2NewDomain
        }
        '81b' {
            'Manually moving each VM...'
            foreach ($VM in $VMs) {
                Add-VM2NewDomainAll
            }
        }
    }
    pause
}
until (
    $selection -eq 'q'
)
