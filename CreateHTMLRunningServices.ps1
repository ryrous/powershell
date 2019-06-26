Get-Service | Where-Object {$_.status -eq "running"} `
            | ConvertTo-HTML Name, DisplayName, Status `
            | Set-Content C:\ExportDir\RunningServices.html