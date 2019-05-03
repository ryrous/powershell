################################################
#WINDOWS CLEANUP
################################################
$Temp = "C:\Windows\Temp\*"
$WU = "C:\Windows\SoftwareDistribution\Download\*"
$AppTemp = "C:\Users\$Env:USERNAME\AppData\Local\Temp\*"
$Downloads = "C:\Users\$Env:USERNAME\Downloads\*"
$Desktop = "C:\Users\$Env:USERNAME\Desktop\*"
$EdgePath = [Environment]::ExpandEnvironmentVariables("$Env:LOCALAPPDATA\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\") + '\#!*'
#Make sure there isn't anything on the desktop or in temp locations
Remove-Item -Path $Temp -ErrorAction SilentlyContinue -Force -Recurse
Remove-Item -Path $AppTemp -ErrorAction SilentlyContinue -Force -Recurse
Remove-Item -Path $WU -ErrorAction SilentlyContinue -Force -Recurse
Remove-Item -Path $Downloads -ErrorAction SilentlyContinue -Force -Recurse
Remove-Item -Path $Desktop -ErrorAction SilentlyContinue -Force -Recurse
#Make sure the recycle bin is empty for every user
Clear-RecycleBin -Force -Confirm:$false
#Empty any Internet history/cookies/cache for every user
Remove-Item -Path $EdgePath -ErrorAction SilentlyContinue -Force -Recurse