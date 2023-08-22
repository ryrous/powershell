w32tm.exe /config /manualpeerlist:”0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org” /syncfromflags:manual /reliable:YES /update
w32tm.exe /config /update
Restart-Service w32time