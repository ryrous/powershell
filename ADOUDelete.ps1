# Delete OU
Remove-ADObject -Identity "OU=Finance,DC=LucernPub,DC=com" -Recursive -Confirm:$False
