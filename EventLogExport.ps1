<# VARIABLES #>
# Specify which Log File
$EventLogName = “Application”
# Specify drive to store event logs
$drive= “c$”
# Specify server to store event logs
$dest = "SERVERNAME"
#Simple Server list
$servers = Get-Content C:\Servers.txt
<# END VARIABLES #>

# For loop to do the work
foreach ($server in $servers){
    # Create a target folder on host if does not exist
    $TARGETROOT = "\\$server\$drive\logs"
    if(!(Test-Path -Path $TARGETROOT)){
        New-Item -ItemType Directory -Path $TARGETROOT
    }
    # This is the WMI call to select the application log from each server
    $logFile = Get-WmiObject -EnableAllPrivileges -ComputerName $server Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $EventLogName}
    # Creating a file name based on server, log and time
    $exportFileName = $server + “_” + $EventLogName + “_” +(get-date -f yyyyMMdd) + “.evt”
    # Perform the backup
    $logFile.backupeventlog($TARGETROOT + “\” + $exportFileName)
    # Create an export folder if it does not exist
    $target = "\\$dest\$drive\logs\export"
    if(!(Test-Path -Path $target)){
N       ew-Item -ItemType Directory -Path $target
    }
    # Since WMI does the work on the remote machine you can’t copy to file share.
    # This is a workaround to move to files to a single location after the backup
    Move-Item $TARGETROOT\$exportFileName $target
}
