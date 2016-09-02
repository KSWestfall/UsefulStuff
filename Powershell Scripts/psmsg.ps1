<#
psmsg.ps1
4/5/2016
Author: Kyle Westfall

Description: Function used to display a message on a specified computer

Parameters:
[string]ComputerName    Specifies computer to display the message on.
[string]Message         The message that is to be displayed.
[string]UserName        Specifies the user that the message will be displayed to. defaults to all users "*"
                        @Filename specifies a file that contains the user names of users to display message to.
[string]Time            The amount of time before the message disappears. defaults to 1000000000.
[switch]Wait            Asks for users input.            
#>

function psmsg {
    param (
        [Parameter(Mandatory=$True,Position=1)]
            [string]$ComputerName,
        [Parameter(Mandatory=$True,Position=2)]
            [string]$Message,
        [Parameter(Mandatory=$False)]
            [string]$UserName = "*",
        [Parameter(Mandatory=$False)]
            [string]$Time = "1000000000"
    )
    
    Invoke-WmiMethod -Class Win32_Process -ComputerName $ComputerName -Name Create -ArgumentList "C:\Windows\System32\msg.exe $($UserName) /time:$($Time) $($Message)" 
}