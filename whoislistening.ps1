#requires -Version 2
function Get-ProcessInfoUI($Process)
{
  foreach ($proc in $Process)
  {
    Add-Type -AssemblyName UIAutomationClient
    [System.Windows.Automation.AutomationElement]::FromHandle($proc.MainWindowHandle).Current |
    Select-Object -Property Name, HasKeyboardFocus, IsOffscreen, BoundingRectangle, NativeWindowHandle, ProcessId, Orientation, FrameworkId
  }
}

# get current PowerShell process:
$ise = Get-Process -Id $pid
# start new Notepad and wait until loaded:
$notepad = Start-Process notepad -WindowStyle Minimized -PassThru
$null = $notepad.WaitForInputIdle()

# get UI information for these processes
Get-ProcessInfoUI $ise, $notepad | Out-GridView -Title 'UI Information'