Param(
    [Parameter(Mandatory=$true)]
    [Datetime]$LastWrite
)
Get-ChildItem -Path $path | Where-Object -FilterScript {($_.LastWriteTime -gt $LastWrite)}