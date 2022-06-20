Get-AppxPackage *BingWeather* | Remove-AppxPackage
Get-AppxPackage *Xbox* | Remove-AppxPackage
Get-AppxPackage *Messaging* | Remove-AppxPackage
Get-AppxPackage *OneNote* | Remove-AppxPackage
Get-AppxPackage *People* | Remove-AppxPackage
Get-AppxPackage *Photos* | Remove-AppxPackage
Get-AppxPackage *Alarms* | Remove-AppxPackage
Get-AppxPackage *Camera* | Remove-AppxPackage
Get-AppxPackage *Maps* | Remove-AppxPackage
Get-AppxPackage *Feedback* | Remove-AppxPackage
Get-AppxPackage *Zune* | Remove-AppxPackage
Get-AppxPackage *News* | Remove-AppxPackage
Get-AppxPackage *Get* | Remove-AppxPackage
Get-AppxPackage *Skype* | Remove-AppxPackage
Get-AppxPackage *OneConnect* | Remove-AppxPackage
Get-AppxPackage *Office* | Remove-AppxPackage
Get-AppxPackage *EclipseManager* | Remove-AppxPackage
Get-AppxPackage *ActiproSoftwareLLC* | Remove-AppxPackage
Get-AppxPackage *Duolingo* | Remove-AppxPackage
Get-AppxPackage *3DViewer* | Remove-AppxPackage
Get-AppxPackage *Print3D* | Remove-AppxPackage
Get-AppxPackage *Wallet* | Remove-AppxPackage
Get-AppxPackage *CBSPreview* | Remove-AppxPackage
Get-AppxPackage *XboxGameCallableUI* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Get* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Skype* | Remove-AppxPackage
Get-AppxPackage -AllUsers *OneConnect* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Office* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Camera* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Bingnews* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Xbox* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Messaging* | Remove-AppxPackage
Get-AppxPackage -AllUsers *OneNote* | Remove-AppxPackage
Get-AppxPackage -AllUsers *People* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Photos* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Alarms* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Maps* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Feedback* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Zune* | Remove-AppxPackage
Get-AppxPackage -AllUsers *EclipseManager* | Remove-AppxPackage
Get-AppxPackage -AllUsers *ActiproSoftwareLLC* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Duolingo* | Remove-AppxPackage
Get-AppxPackage -AllUsers *3DViewer* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Print3D* | Remove-AppxPackage
Get-AppxPackage -AllUsers *Wallet* | Remove-AppxPackage
Get-AppxPackage -AllUsers *CBSPreview* | Remove-AppxPackage
Get-AppxPackage -AllUsers *XboxGameCallableUI* | Remove-AppxPackage

remove-appxprovisionedpackage -Online -PackageName Microsoft.BingWeather*
remove-appxprovisionedpackage -Online -PackageName Microsoft.GetHelp*
remove-appxprovisionedpackage -Online -PackageName Microsoft.Getstarted*
remove-appxprovisionedpackage -Online -PackageName Microsoft.Messaging*
remove-appxprovisionedpackage -Online -PackageName Microsoft.Microsoft3DViewer*
remove-appxprovisionedpackage -Online -PackageName Microsoft.MicrosoftOfficeHub*
remove-appxprovisionedpackage -Online -PackageName Microsoft.Office.OneNote*
remove-appxprovisionedpackage -Online -PackageName Microsoft.OneConnect*
remove-appxprovisionedpackage -Online -PackageName Microsoft.People*
remove-appxprovisionedpackage -Online -PackageName Microsoft.Print3D*
remove-appxprovisionedpackage -Online -PackageName Microsoft.SkypeApp*
remove-appxprovisionedpackage -Online -PackageName Microsoft.Wallet*
remove-appxprovisionedpackage -Online -PackageName Microsoft.WebMediaExtensions*
remove-appxprovisionedpackage -Online -PackageName Microsoft.Windows.Photos*
remove-appxprovisionedpackage -Online -PackageName Microsoft.WindowsAlarms*
remove-appxprovisionedpackage -Online -PackageName Microsoft.WindowsCamera*
remove-appxprovisionedpackage -Online -PackageName Microsoft.WindowsFeedbackHub*
remove-appxprovisionedpackage -Online -PackageName Microsoft.WindowsMaps*
remove-appxprovisionedpackage -Online -PackageName Microsoft.Xbox.TCUI*
remove-appxprovisionedpackage -Online -PackageName Microsoft.XboxApp*
remove-appxprovisionedpackage -Online -PackageName Microsoft.XboxGameOverlay*
remove-appxprovisionedpackage -Online -PackageName Microsoft.XboxGamingOverlay*
remove-appxprovisionedpackage -Online -PackageName Microsoft.XboxIdentityProvider*
remove-appxprovisionedpackage -Online -PackageName Microsoft.XboxSpeechToTextOverlay*
remove-appxprovisionedpackage -Online -PackageName Microsoft.ZuneMusic*
remove-appxprovisionedpackage -Online -PackageName Microsoft.ZuneVideo*