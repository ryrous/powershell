# Get Installed Updates
wmic qfe list #| Add-Content -path C:\Temp\InstalledUpdates.txt -Force
