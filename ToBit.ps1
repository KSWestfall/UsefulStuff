function To-Base {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,position=0)]
        [string]
        $StringtoConvert,
        [Parameter(Mandatory=$false)]
        [ValidateSet('2','8','16')]
        [string]$Base='2'
        
    )
        
    process {
        [Convert]::ToString($StringtoConvert,$base)
    }
}