# [8/20/2015 2:34 PM] Schloot, William:
function Get-ProcessesCheck {
  [CmdletBinding()]
  [OutputType([String[]])]
  param (
    [Parameter(Mandatory=$true, Position=0)]
      [string[]]$Computers,
    [Parameter(Mandatory=$true, Position=1)]
      [string]$ProcessName,
    [Parameter(Mandatory=$false)]
      [string]$OutFile
  )
  begin{
    # Function used to check to see if the computer is up
    function tc ($ComputerName) {
      if (Test-Connection -Computername $ComputerName -BufferSize 16 -Count 1 -Quiet) {
        $true;
      }
      else {
        $false;
      }
    }
  }
  process{
    # check input to see if its a list or not 
    switch -wildcard ($Computers) {
      "*.txt" {$ComputerName = Get-Content $Computers} # parse text file
      "*.csv" {$ComputerName = Import-Csv $Computers} # parse csv file
      Default {$ComputerName = $Computers}
    }

    ForEach ($Computer in $ComputerName)
    {
      $isComputerOn = tc $Computer
        if ($isComputerOn -and (Get-Process -ComputerName $Computer -Name $ProcessName -ErrorAction SilentlyContinue)) {
          $Results = Get-Process $ProcessName -ComputerName $Computer
          if ($OutFile) {
            "$Computer | $Results" | out-file -FilePath $OutFile -Append;
          }
          else {
            Write-Host "$Computer | $Results";
          }
        }
        elseif (!($isComputerOn)) {
          if ($OutFile) {
            "$Computer | COMPUTER NOT RUNNING/REACHABLE" | out-file -FilePath $OutFile -Append;
          }
          else {
            Write-Host "$Computer | COMPUTER NOT RUNNING/REACHABLE";
          }
        }
        else
        {
          if ($OutFile) {
            "$Computer | NOT RUNNING" | out-file -FilePath $OutFile -Append;
          }
          else {
            Write-Host "$Computer | PROCESS NOT RUNNING";
          }
        }
    }
  }
}
