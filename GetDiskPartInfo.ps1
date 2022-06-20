Function GET-DISKPARTINFO() {
    [cmdletbinding()]
    Param()
    #Now let’s add our first DiskPart script to get the number of drives:
    NEW-ITEM -Path .\ -Name ListDisk.txt -ItemType File -Force | OUT-NULL
    ADD-CONTENT -Path ListDisk.txt "LIST DISK"
    $LISTDISK=(DISKPART /S LISTTDISK.TXT)
    $TOTALDISK=($LISTDISK.Count)-9          
    #Then we can loop through each disk, grabbing the DiskID and its physical size:
    for ($d=0;$d -le $TOTALDISK;$d++){
        $SIZE=$LISTDISK[-1-$d].substring(25,9).replace(" ","") 
        $DISKID=$LISTDISK[-1-$d].substring(7,5).trim()
        #Now that we have the DiskID, we can write a simple script for DiskPart to call up that disk and grab it’s Detail:
        NEW-ITEM -Path .\ -Name Detail.txt -ItemType File -Force | OUT-NULL 
        ADD-CONTENT -Path Detail.txt "SELECT DISK $DISKID" 
        ADD-CONTENT -Path Detail.txt "DETAIL DISK"
        $DETAIL=(DISKPART /S DETAIL.TXT)
        #And now with the Detail for that disk in hand, we run through our Detail parsing to pull the information we need from there:
        $MODEL=$DETAIL[8] 
        $TYPE=$DETAIL[10].substring(9) 
        $DRIVELETTER=$DETAIL[-1].substring(15,1)
        #Now we take a few minutes to convert that drive size to a real integer that we can use to compare the size of the removable disk:
        $LENGTH=$SIZE.length
        $MULTIPLIER=$SIZE.substring($length-2,2) 
        $INTSIZE=$SIZE.substring(0,$length-2)
        SWITCH($MULTIPLIER) { 
            KB { $MULT = 1KB } 
            MB { $MULT = 1MB } 
            GB { $MULT = 1GB } 
        }
        $DISKTOTAL=([convert]::ToInt16($INTSIZE,10))*$MULT
        #Then all we need do now is wrap it up neatly as a custom object in Windows PowerShell:
        [pscustomobject]@{DiskNum=$DISKID;Model=$MODEL;Type=$TYPE;DiskSize=$DISKTOTAL;DriveLetter=$DRIVELETTER} 
    } 
}
GET-DISKPARTINFO | Format-Table
<#
$TYPE = 
$MIN = 
$MAX = 
GET-DISKPARTINFO | Where-Object {$_.Type –eq $TYPE –and $_.DiskSize -lt $MAX -and $_.DiskSize –gt $MIN}
#>