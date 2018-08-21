Get-Service | Where-Object {$_.status -eq "running"}
Read-Host -Prompt "Press Enter to exit"