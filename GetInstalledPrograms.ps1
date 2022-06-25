$Servers = Import-Csv .\ServerList.csv
$array = @()
foreach($Server in $Servers){
    $ServerName=$Server.ComputerName
    #Define the variable to hold the location of Currently Installed Programs
    $UninstallKeyLocation="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" 
    #Create an instance of the Registry Object and open the HKLM base key
    $Reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$ServerName) 
    #Drill down into the Uninstall key using the OpenSubKey Method
    $RegKey=$Reg.OpenSubKey($UninstallKeyLocation) 
    #Retrieve an array of string that contain all the subkey names
    $subkeys=$RegKey.GetSubKeyNames() 
    #Open each Subkey and use GetValue Method to return the required values for each
    foreach($key in $subkeys){
        $thisKey=$UninstallKeyLocation+"\\"+$key 
        $thisSubKey=$Reg.OpenSubKey($thisKey) 
        $obj = New-Object PSObject
        $obj | Add-Member -MemberType NoteProperty -Name "ComputerName" -Value $ServerName
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))
        $obj | Add-Member -MemberType NoteProperty -Name "InstallLocation" -Value $($thisSubKey.GetValue("InstallLocation"))
        $obj | Add-Member -MemberType NoteProperty -Name "Publisher" -Value $($thisSubKey.GetValue("Publisher"))
        $array += $obj
    } 
}
$array | Where-Object { $_.DisplayName } | Select-Object ComputerName, DisplayName, DisplayVersion, Publisher | Format-Table -AutoSize
# Where-Object { $_.DisplayName -and $_.computerName -eq “thisComputer”}