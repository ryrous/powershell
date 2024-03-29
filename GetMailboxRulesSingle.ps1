$ApplicationId = 'YourApplicationID'
$ApplicationSecret = 'YourApplicationSecret' | Convertto-SecureString -AsPlainText -Force
#$TenantID = 'YourTenantID'
$ExchangeRefreshToken = 'YourExchangeToken'
#$RefreshToken = 'YourRefreshToken'
$UPN = "UPN-Used-To-Generate-Token"
$ClientTenantName = "bla.onmicrosoft.com"
##############################
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
 
$customers = $ClientTenantName
$logs = foreach ($customer in $customers) {
    $startDate = (Get-Date).AddDays(-1)
    $endDate = (Get-Date)
    $token = New-PartnerAccessToken -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716'-RefreshToken $ExchangeRefreshToken -Scopes 'https://outlook.office365.com/.default' -Tenant $ClientTenantName
    $tokenValue = ConvertTo-SecureString "Bearer $($token.AccessToken)" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($upn, $tokenValue)
    $customerId = $customer.DefaultDomainName
    $PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$($customerId)&BasicAuthToOAuthConversion=true" -Credential $credential -Authentication Basic -AllowRedirection
    $MySession = import-PSSession $PSSession -AllowClobber -CommandName "Search-unifiedAuditLog", "Get-AdminAuditLogConfig"
    $MySession
    if((Get-AdminAuditLogConfig).UnifiedAuditLogIngestionEnabled -eq $false){
        Write-Host "AuditLog is disabled for client $ClientTenantName)"
    }
    
    $LogsTenant = @()
    Write-Host "Retrieving logs for $ClientTenantName)" -ForegroundColor Blue
    do {
        $logsTenant += Search-unifiedAuditLog -SessionCommand ReturnLargeSet -SessionId $customer.name -ResultSize 5000 -StartDate $startDate -EndDate $endDate -Operations "New-InboxRule", "Set-InboxRule", "UpdateInboxRules"
        Write-Host "Retrieved $($logsTenant.count) logs" -ForegroundColor Yellow
    }
    while ($LogsTenant.count % 5000 -eq 0 -and $LogsTenant.count -ne 0)

    Write-Host "Finished Retrieving logs" -ForegroundColor Green
    $LogsTenant
}

foreach ($log in $logs){
    $AuditData = $log.AuditData | ConvertFrom-Json
    Write-Host "A new or changed rule has been found for user $($log.UserIds). The rule has the following info: $($Auditdata.Parameters | out-string)`n"
}
if (!$Logs){
    Write-Host "Healthy."
}