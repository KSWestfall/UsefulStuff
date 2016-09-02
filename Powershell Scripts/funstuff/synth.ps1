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
Function use-Synth
{
  [CmdletBinding()]
  [OutputType([Nullable])]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory=$True, Position=0)]
    $msg
  )

    Add-Type -AssemblyName System.Speech
    $synth = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    $synth.Speak($msg)
}
