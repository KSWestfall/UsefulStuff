Function Find-File {
  #comment based help is here
  [cmdletbinding()]
  Param(
    [Parameter(Position=0,Mandatory=$True,HelpMessage="What is the name of the file?")]
    [ValidateNotNullorEmpty()]
    [alias("file")]
    [string]$Name,
    [ValidateNotNullorEmpty()]
    [string]$Drive="C:",
    [ValidateNotNullorEmpty()]
    [string[]]$Computername=$env:computername,
    [switch]$AsJob
  )
  $oldverbose = $VerbosePreference

  $VerbosePreference = "continue"
  <#
   strip off any trailing characters to drive parameter
   that might have been passed.
  #>
  If ($Drive.Length -gt 2) {
      $Drive=$Drive.Substring(0,2)
  }

  Write-Verbose "Searching for $Name on Drive $Drive on computer $Computername."

  <#
  Normally you might think to simply split the name on the . character. But
  you might have a filename like myfile.v2.dll so that won’t work. In a case
  like this the extension would be everything after the last . and the filename
  everything before.

  So instead I’ll use the substring method to "split" the filename string.
  #>

  #get the index of the last .
  $index = $Name.LastIndexOf(".")
  #get the first part of the name
  $filename=$Name.Substring(0,$index)
  #get the last part of the name
  $extension=$Name.Substring($index+1)

  #get all instances of the file and write the WMI object to the pipeline
  #Get-WmiObject -Class CIM_Datafile –Filter "Filename=’$filename’ AND extension=’$extension’ AND Drive=’$drive’"
  gwmi -Class CIM_Datafile -Filter "fileName ='$filename' AND extension = '$extension' AND Drive = 'C:'" -Computername $Computername
} #end Get-CIMFile
