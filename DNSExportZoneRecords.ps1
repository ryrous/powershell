$zones = (Get-DnsServerZone).ZoneName
$results = foreach ($zone in $zones) {
    $zoneData = Get-DnsServerResourceRecord $zone
    foreach ($record in $zoneData) {
        [PSCustomObject]@{
            ZoneName = $zone
            HostName = $record.HostName
            RecordType = $record.RecordType
            RecordData = $record.RecordData
        }
    }
}
$results | Out-GridView
$results | Export-Csv -Path C:\DNSRecords.csv -NoTypeInformation