<#
.SYNOPSIS
    This script returns the device names of the computer that the value provided.
.NOTES
    You can use wildcards in this script to find similar device names.
    * used for multiple characters
    ? used for single characters
.PARAMETER ComputerName
    The name of the device that you are wanting to find. Can contain wildcards
.PARAMETER ToFile
    Outputs the returned values to a file.
 #>

function Get-ComputersLike 
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, Position=0)]
            [string]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$false)]
            [string]$ToFile
        
    )    
    $ComputerName = '"' + $ComputerName + '"';
    $list = Get-ADComputer -Filter "Name -like $ComputerName" | foreach{ $_.Name}; 
    if ($ToFile) {
        $list | Out-File  -FilePath $ToFile;                                                                                                  
    }
    else {
        ,$list;
    }
    
};set-alias gcnl -Value Get-ComputerNameLike;
