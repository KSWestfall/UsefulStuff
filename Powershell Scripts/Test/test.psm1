function pmsf {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$true,Position=1)]
            [string[]]$ComputersToPing
    )

    $ComputersToPing;
}