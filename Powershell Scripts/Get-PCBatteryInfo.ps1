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
Function Get-PCBatteryInfo
{
  [CmdletBinding()]
  [OutputType([Nullable])]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory, ValueFromPipelineByPropertyName, Position=0)]
    $ComputerName
  )
  [array]$BattInfo = Get-WmiObject -ComputerName $ComputerName Win32_Battery | %{$_.Availability, $_.BatteryStatus, $_.EstimatedChargeRemaining, $_.Name};

  [array]$AvailabilityArray = "Other (1)",
    "Unknown (2)",
    "Running/Full Power (3)",
    "Warning (4)",
    "In Test (5)",
    "Not Applicable (6)",
    "Power Off (7)",
    "Off Line (8)",
    "Off Duty (9)",
    "Degraded (10)",
    "Not Installed (11)",
    "Install Error (12)",
    "Power Save - Unknown (13)",
    "Power Save - Low Power Mode (14)",
    "Power Save - Standby (15)",
    "Power Cycle (16)",
    "Power Save - Warning (17)",
    "Paused (18)",
    "Not Ready (19)",
    "Not Configured (20)",
    "Quiesced (21)"

  [array]$BatteryStatusArray = "Other (1)",
    "Unknown (2)",
    "Fully Charged (3)",
    "Low (4)",
    "Critical (5)",
    "Charging (6)",
    "Charging and High (7)",
    "Charging and Low (8)",
    "Charging and Critical (9)",
    "Undefined (10)",
    "Partially Charged (11)"

  ""
  $AvailabilityArray[$BattInfo[0].ToString()]
  ""
  $BatteryStatusArray[$BattInfo[1].ToString()]
  ""
  "Estimated charge remaining: " + $BattInfo[2]
  ""
  "Battery type: " + $BattInfo[3]
  ""
}
