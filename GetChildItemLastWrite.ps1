Param(
    [Parameter(Mandatory=$true)]
    [Datetime]$LastWrite
)
Get-ChildItem $path | Where-Object -FileterScript {($_.LastWriteTime -gt $LastWrite)}