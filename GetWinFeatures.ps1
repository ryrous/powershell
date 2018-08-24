workflow Get-WinFeatures {
    Parallel {
        Get-WindowsFeature -Name PowerShell*
        InlineScript {
            $env:COMPUTERNAME
        }
        Sequence {
            Get-Date
            $PSVersionTable.PSVersion 
        } 
    }
}