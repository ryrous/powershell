$NewPwd = ConvertTo-SecureString -String "NewPassword" -AsPlainText -Force
Start-Sleep 3
Set-ADAccountPassword ADuser -NewPassword $NewPwd -Reset
Start-Sleep 3
Set-ADAccountPassword ADuser -NewPassword $NewPwd -Reset -PassThru | Set-ADUser -ChangePasswordAtLogon $true