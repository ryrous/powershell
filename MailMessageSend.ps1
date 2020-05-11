$From = "user@domain.com"
$To = "user@domain.com"
$Cc = "user@domain.com"
$Attachment = "C:\Temp\File.jpg"
$Subject = "File Request"
$Body = "<h2>Here is the file you requested</h2><br><br>"
$Body += “Name of file” 
$SMTPServer = "smtp.mailserver.com"
$SMTPPort = "587"
Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment
