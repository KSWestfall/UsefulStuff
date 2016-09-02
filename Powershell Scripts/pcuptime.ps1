function PCUptime {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0)]
        [string]$ComputerName
    )
    process{
        Write-Verbose "getting wmi object "
        try {
            $wmiOS = Get-WmiObject -computer $ComputerName Win32_OperatingSystem -ErrorAction SilentlyContinue;
            
            $localdatetime = $wmi.ConvertToDateTime($wmiOS.LocalDateTime);
            Write-Verbose "$localdatetime"
            $lastbootuptime = $wmi.ConvertToDateTime($wmiOS.LastBootUpTime);
            Write-Verbose "$lastbootuptime"

            $uptime = $localdatetime - $lastbootuptime;
            
            $wmiram = Get-WmiObject -computer $Computer Win32_PhysicalMemory -ErrorAction SilentlyContinue;
            # Calculate the total memory for the given computer by adding the current value to $TotalMem
            $TotalMem = 0;
            foreach($device in $wmiram){
                $TotalMem += $device.Capacity/1GB;
                Write-Verbose "Total Memory: $TotalMem";
            }
            
            New-Object psobject -Property @{
                ComputerName=$ComputerName; 
                Uptime=$uptime; 
                TotalMemory=$TotalMem} 
        }
        catch {
            New-Object psobject -Property @{ComputerName=$ComputerName; Uptime="--------"; TotalMemory="-------"};
        }
    }
}