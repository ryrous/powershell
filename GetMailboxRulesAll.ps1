$ApplicationId = 'YourApplicationID'
$ApplicationSecret = 'YourApplicationSecret' | Convertto-SecureString -AsPlainText -Force
$TenantID = 'YourTenantID'
$ExchangeRefreshToken = 'YourExchangeToken'
$RefreshToken = 'YourRefreshToken'
$UPN = "UPN-Used-To-Generate-Token"
##############################
$credential = New-Object System.Management.Automation.PSCredential($ApplicationId, $ApplicationSecret)
 
$aadGraphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.windows.net/.default' -ServicePrincipal -Tenant $tenantID
$graphToken = New-PartnerAccessToken -ApplicationId $ApplicationId -Credential $credential -RefreshToken $refreshToken -Scopes 'https://graph.microsoft.com/.default' -ServicePrincipal -Tenant $tenantID
 
Connect-MsolService -AdGraphAccessToken $aadGraphToken.AccessToken -MsGraphAccessToken $graphToken.AccessToken
$customers = Get-MsolPartnerContract -All
$logs = foreach ($customer in $customers) {
    $startDate = (Get-Date).AddDays(-1)
    $endDate = (Get-Date)
    $token = New-PartnerAccessToken -ApplicationId 'a0c73c16-a7e3-4564-9a95-2bdf47383716'-RefreshToken $ExchangeRefreshToken -Scopes 'https://outlook.office365.com/.default' -Tenant $customer.TenantId
    $tokenValue = ConvertTo-SecureString "Bearer $($token.AccessToken)" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($upn, $tokenValue)
    $customerId = $customer.DefaultDomainName
    $PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.outlook.com/powershell-liveid?DelegatedOrg=$($customerId)&BasicAuthToOAuthConversion=true" -Credential $credential -Authentication Basic -AllowRedirection
    $MySession = Import-PSSession $PSSession -AllowClobber -CommandName "Search-UnifiedAuditLog", "Get-AdminAuditLogConfig"
    $MySession
    if((Get-AdminAuditLogConfig).UnifiedAuditLogIngestionEnabled -eq $false){
        Write-Host "AuditLog is disabled for client $($customer.name)"
    }

    $LogsTenant = @()
    Write-Host "Retrieving logs for $($customer.name)" -ForegroundColor Blue
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