schtasks.exe /delete /tn "\Microsoft\Office\Office 15 Subscription Heartbeat" > nul
schtasks.exe /delete /tn "\Microsoft\Office\Office Automatic Update" > nul
schtasks.exe /delete /tn "\Microsoft\Office\Office Subscription Maintenance" > nul
Stop-Process -processname Officeclicktorun.exe -ErrorAction SilentlyContinue
Stop-Process -processname appvshnotify.exe -ErrorAction SilentlyContinue
Stop-Process -processname firstrun.exe -ErrorAction SilentlyContinue
Stop-Process -processname setup.exe -ErrorAction SilentlyContinue
sc.exe delete Clicktorunsvc 
Remove-Item -path "C:\Program Data\Microsoft\Office" -ErrorAction SilentlyContinue
Remove-Item -path "C:\Program Data\Microsoft\ClickToRun" -ErrorAction SilentlyContinue
Remove-Item -path "C:\Program Files\Microsoft Office" -ErrorAction SilentlyContinue
Remove-Item -path "C:\Program Files\Microsoft Office 15" -ErrorAction SilentlyContinue
Remove-Item -path "C:\Program Files\Common Files\microsoft shared\ClickToRun" -ErrorAction SilentlyContinue
Remove-Item -path "C:\Program Files\Common Files\microsoft shared\OFFICE15" -ErrorAction SilentlyContinue
Remove-Item -path "C:\Program Files\Common Files\microsoft shared\OfficeSoftwareProtectionPlatform" -ErrorAction SilentlyContinue
Remove-Item -path "%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Office" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Office\15.0\ClickToRun" -Name "*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\AppVISV" -Name "*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Office <Edition>15 - en-us" -Name "*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKEY_CURRENT_USER\Software\Microsoft\Office" -Name "*" -ErrorAction SilentlyContinue