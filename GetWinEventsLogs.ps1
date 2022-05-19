<code class="language-powershell">$StartDate = (Get-Date).AddDays(-3)
$ProviderName = 'Windows Error Reporting'
$Logs = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$StartDate; ProviderName=$ProviderName;}
$Logs.Count
</code>