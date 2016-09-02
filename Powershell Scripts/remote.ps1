<#
.SYNOPSIS
  Smarter script to open Landesk or SCCM remote.  

.DESCRIPTION
  Tested and works on PowerShell V4
  
  This is smarter script for launching remote sessions using either Landesk or SCCM. I created this script to 
  first test if landesk was present on the specified computer and if it is start that, if not start 
  sccm remoting as soon as possible. The script will wait a specified amount of time for the computer 
  to come back online initially if the computer has been restarted. If the device is not up when first
  starting this script, the script will wait a certain amount of time before giving up.
  

.OUTPUTS
  Void. starts either Landesk or SCCM remote control

.EXAMPLE
  Start-Remote -ComputerName Testcomputer

.PARAMETER ComputerName
  The device name for the computer that you want remote in to.
.PARAMETER Timeout
  The amount of time that this script will attempt to connect to the computer. 

#>
Function Start-Remote
{
  [CmdletBinding()]
  [OutputType([Nullable])]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory=$true, Position=0)]
      [string]$ComputerName,
    [Parameter(Mandatory=$false)]
      [int]$Timeout=1200
  )
  begin {
    $ComputerName = $ComputerName.ToUpper();
    # initialize vars
    $time = 0.0;
    $pingtest = 0.0;
    
    # pings a computer to test if its up.
    function tc () {
      if(Test-Connection -Computername $ComputerName -BufferSize 16 -Count 1 -Quiet){
        $true;
      }
      else {
        $false;
      }
    }
    
    # Check for sccm process
    function sccm () {
      if ((Get-Process -Name CmRcService -ErrorAction SilentlyContinue -ComputerName $ComputerName) -eq $null ) {
        $false;
      } 
      else {
        $true;
      }
    }
    
    # Check for landesk process
    function landesk () {
      if (($landesk = Get-Process -Name residentAgent -ErrorAction SilentlyContinue -ComputerName $ComputerName) -eq $null) {
        $false;
      }
      else {
        $true
      }
    }
    
    # Launches landesk, depending on operating system
    function Launch-Landesk () {
      if ([System.IntPtr]::Size -eq 4) {
        Write-Verbose "32 bit. Launching landesk remote";
        & 'C:\Program Files\LANDesk\ServerManager\RCViewer\isscntr.exe' /c remote control "-a$ComputerName" -srdsvld01;
      }
      else {
        Write-Verbose "64 bit. Launching landesk remote";
        & 'C:\Program Files (x86)\LANDesk\ServerManager\RCViewer\isscntr.exe' /c remote control "-a$ComputerName" -srdsvld01;
      }
    }
    
    # Launches sccm, depending on operating system
    function Launch-Sccm () {
      if ([System.IntPtr]::Size -eq 4) {
        Write-Verbose "32 bit. Launching SCCM remote";
        & 'C:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\i386\CmRcViewer.exe' $ComputerName \\rdvmms01;
      }
      else {
        Write-Verbose "64 bit. Launching SCCM remote";
        & 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\i386\CmRcViewer.exe' $ComputerName \\rdvmms01;
      }
    }
    
    # A function used to check if the device name is real
    function Check-ComputerName () {
      Write-Verbose "testing name";
      Test-Connection -ComputerName $ComputerName -BufferSize 16 -Count 1 -ErrorVariable $errorVar -ErrorAction SilentlyContinue;
      if ($errorVar) {
        if ($ErrorVar.ToString() -contains "No such host is known") { 
          Write-Verbose "$errorVar";
          $true;
        }  
      }
      else {
        Write-Verbose "$ComputerName true"
        $false;
      }
    }
  }#begin end

  process {
    # Test the connection to the computer
    if (!(Check-ComputerName)) {
      Write-Host "$ComputerName does not exist. Check the name and try again.";
      return;
    }
    Write-Verbose "testing connection...";
    
    # wait $Timeout amount of time to see if the computer is coming back up
    while (!(tc)) {
      Start-Sleep -s 1;
      $pingtest += 1;
      Write-Verbose "Waiting for computer to come up...";
      if ($pingtest -gt $Timeout) {
        Write-Verbose "Unable to contact $ComputerName. Exiting Script";
        return;
      }
    }
    
    Write-Verbose "$ComputerName is on the network.";
    
    # If landesk service is running then check to see if Local OS is to find out which file path to launch
    If (landesk)
    {
      Write-Verbose "Launching Landesk";
      Launch-Landesk;
    }
    elseif (sccm) {
      Write-Verbose "Launching SCCM";
      Start-Sleep -s 1;
      Launch-Sccm;
    }
    
    # try sccm remote 
    elseif (!(landesk) -And !(sccm)){
      Write-Verbose "landesk is either not started or not installed and SCCM process is not started.";
      
      # If sccm remote process is not running then wait 
      while(!(sccm))
      {
        Write-Verbose "Waiting for CmRcService to start.";
        Start-Sleep -s 1;
        $Time += 1;
        If ($Time -gt $Timeout)
        {
          Write-Verbose "Start-Remote timed out.";
          return;
        }
        $sccm = Get-Process CmRcService -ErrorAction SilentlyContinue;
      }
      Write-Verbose "CmRcService is running."
      Write-Verbose "Starting SCCM.";
      Start-Sleep -s 2;
      Launch-Sccm;
    }    
  }#process
}; Set-Alias rcs -Value Start-Remote;
