<#
.SYNOPSIS
  Short description

.DESCRIPTION
  Long description

.OUTPUTS
  The value returned by this cmdlet

.EXAMPLE
  Example of how to use this cmdlet

.LINK
  To other relevant cmdlets or help
#>
Function Get-CIMFile
{
  [CmdletBinding()]
  [OutputType([Nullable])]
  Param
  (
    [Parameter(Mandatory=$True, ValueFromPipelineByPropertyName, Position=0)]
    [ValidateNotNullorEmpty()]
    [string]$Name,

    [ValidateNotNullorEmpty()]
    [string]$Drive="C:",

    [ValidateNotNullorEmpty()]
    [string[]]$ComputerName=$env:computername,
    [switch]$AsJob
  )
  If ($Drive.Length -gt 2)
  {
    $Drive=$Drive.Substring(0,2);
  }

  Write-Verbose "Searching for $Name on Drive $Drive on computer $Computername."

  $index = $Name.LastIndexOf(".");
  $filename = $Name.Substring(0,$index);
  $extension = $Name.Substring($index + 1);
  $filter = "Filename=’$filename’ AND extension=’$extension’ AND Drive=’$drive’";
  Write-Verbose $filter;

  Get-WmiObject -Class CIM_Datafile -ComputerName $Computername –Asjob:$AsJob –Filter $filter
}
