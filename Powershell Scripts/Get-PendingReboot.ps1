<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2014 v4.1.74
	 Created on:   	1/13/2015 5:35 AM
	 Created by:   	Douglas DeCamp
	 Organization: 	Lakeland Regional Health Systems
	 Filename:    Get-PendingReboot.ps1 	
	===========================================================================
	DESCRIPTION
		Going beyond the registry and looking at other parameters which may prevent an installation of a software pacakage due to a pending reboot. These would include Windows Update,
		SCCM Client, Pending File Rename and more to be added as it discovered through the trial and error process....
	Running this script
		PARAMETER ComputerName
    		A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME).

			PARAMETER ErrorLog
   			 A single path to send error data to a log file.

		EXAMPLE
   			 PS C:\> Get-PendingReboot -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize
	
                    Computer CBServicing WindowsUpdate CCMClientSDK PendFileRename PendFileRenVal RebootPending
   				 	-------- ----------- ------------- ------------ -------------- -------------- -------------
				    DC01           False         False                       False                        False
				    DC02           False         False                       False                        False
				    FS01           False         False                       False                        False

				    This example will capture the contents of C:\ServerList.txt and query the pending reboot
				    information from the systems contained in the file and display the output in a table. The
				    null values are by design, since these systems do not have the SCCM 2012 client installed,
				    nor was the PendingFileRenameOperations value populated.

		EXAMPLE
		    PS C:\> Get-PendingReboot
			
		    Computer       : WKS01
		    CBServicing    : False
		    WindowsUpdate  : True
		    CCMClient      : False
		    PendFileRename : False
		    PendFileRenVal : 
		    RebootPending  : True
			
		    This example will query the local machine for pending reboot information.
			
		EXAMPLE
		    PS C:\> $Servers = Get-Content C:\Servers.txt
		    PS C:\> Get-PendingReboot -Computer $Servers | Export-Csv C:\PendingRebootReport.csv -NoTypeInformation
			
		    This example will create a report that contains pending reboot information.

		EXAMPLE
			PS C:\> $Servers = Get-Content C:\Servers.txt
			PS C:\> Get-PendingReboot.ps1 -Computer $Servers | Format-List | Out-File C:\MyScriptOutput\test.txt
			
			This example will create a report that contains the pending reboot information and displays it in a list format along with the full path of any pending file renames.
			
			Computer       : WKSTATION1
			CBServicing    : False
			WindowsUpdate  : False
			CCMClientSDK   : True
			PendFileRename : True
			PendFileRenVal : {\??\C:\Config.Msi\37f72.rbf, , \??\C:\Config.Msi\37f82.rbf, ...}
			RebootPending  : True
#>

[CmdletBinding()]
param (
	[Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
	[Alias("CN", "Computer")]
	[String[]]$ComputerName = "$env:COMPUTERNAME",
	[String]$ErrorLog
)

Begin
{
	# Adjusting ErrorActionPreference to stop on all errors, since using [Microsoft.Win32.RegistryKey]
	# does not have a native ErrorAction Parameter, this may need to be changed if used within another function.
	$TempErrAct = $ErrorActionPreference
	$ErrorActionPreference = "Stop"
}#End Begin Script Block
Process
{
	Foreach ($Computer in $ComputerName)
	{
		Try
		{
			# Setting pending values to false to cut down on the number of else statements
			$PendFileRename, $Pending, $SCCM = $false, $false, $false
			
			# Setting CBSRebootPend to null since not all versions of Windows has this value
			$CBSRebootPend = $null
			
			# Querying WMI for build version
			$WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer
			
			# Making registry connection to the local/remote computer
			$RegCon = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"LocalMachine", $Computer)
			
			# If Vista/2008 & Above query the CBS Reg Key
			If ($WMI_OS.BuildNumber -ge 6001)
			{
				$RegSubKeysCBS = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\").GetSubKeyNames()
				$CBSRebootPend = $RegSubKeysCBS -contains "RebootPending"
				
			}#End If ($WMI_OS.BuildNumber -ge 6001)
			
			# Query WUAU from the registry
			$RegWUAU = $RegCon.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")
			$RegWUAURebootReq = $RegWUAU.GetSubKeyNames()
			$WUAURebootReq = $RegWUAURebootReq -contains "RebootRequired"
			
			# Query PendingFileRenameOperations from the registry
			$RegSubKeySM = $RegCon.OpenSubKey("SYSTEM\CurrentControlSet\Control\Session Manager\")
			$RegValuePFRO = $RegSubKeySM.GetValue("PendingFileRenameOperations", $null)
			
			# Closing registry connection
			$RegCon.Close()
			
			# If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true
			If ($RegValuePFRO)
			{
				$PendFileRename = $true
				
			}#End If ($RegValuePFRO)
			
			# Determine SCCM 2012 Client Reboot Pending Status
			# To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0
			$CCMClientSDK = $null
			$CCMSplat = @{
				NameSpace = 'ROOT\ccm\ClientSDK'
				Class = 'CCM_ClientUtilities'
				Name = 'DetermineIfRebootPending'
				ComputerName = $Computer
				ErrorAction = 'SilentlyContinue'
			}
			$CCMClientSDK = Invoke-WmiMethod @CCMSplat
			If ($CCMClientSDK)
			{
				If ($CCMClientSDK.ReturnValue -ne 0)
				{
					Write-Warning "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"
					
				}#End If ($CCMClientSDK -and $CCMClientSDK.ReturnValue -ne 0)
				
				If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending)
				{
					$SCCM = $true
					
				}#End If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending)
				
			}#End If ($CCMClientSDK)
			Else
			{
				$SCCM = $null
				
			}
			
			# If any of the variables are true, set $Pending variable to $true
			If ($CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)
			{
				$Pending = $true
				
			}#End If ($CBS -or $WUAU -or $PendFileRename)
			
			# Creating Custom PSObject and Select-Object Splat
			$SelectSplat = @{
				Property = ('Computer', 'CBServicing', 'WindowsUpdate', 'CCMClientSDK', 'PendFileRename', 'PendFileRenVal', 'RebootPending')
			}
			New-Object -TypeName PSObject -Property @{
				Computer = $WMI_OS.CSName
				CBServicing = $CBSRebootPend
				WindowsUpdate = $WUAURebootReq
				CCMClientSDK = $SCCM
				PendFileRename = $PendFileRename
				PendFileRenVal = $RegValuePFRO
				RebootPending = $Pending
			} | Select-Object @SelectSplat
			
		}#End Try
		
		Catch
		{
			Write-Warning "$Computer`: $_"
			
			# If $ErrorLog, log the file to a user specified location/path
			If ($ErrorLog)
			{
				Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
				
			}#End If ($ErrorLog)
			
		}#End Catch
		
	}#End Foreach ($Computer in $ComputerName)
	
}#End Process

End
{
	# Resetting ErrorActionPref
	$ErrorActionPreference = $TempErrAct
}#End End

#End Function