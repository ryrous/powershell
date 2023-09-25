w32tm.exe /config /manualpeerlist:”time.nist.gov” /syncfromflags:manual /reliable:YES /update
w32tm.exe /config /update
Restart-Service w32time