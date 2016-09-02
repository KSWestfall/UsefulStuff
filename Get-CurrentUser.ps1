#Find logged in user of remote computer
function Get-CurrentUser {
    Param(
        [Parameter(Mandatory=$True,Position=1)]
            [string]$ComputerName
    )
    gwmi win32_computersystem -ComputerName $ComputerName | select Username,Caption,Manufacturer;
}