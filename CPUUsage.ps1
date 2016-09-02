function Get-CPUUsage {
    [CmdletBinding()]
    param(
        [Parameter(Position=0, ValueFromPipeline=$true, ParameterSetName="Computers")]
            [string[]]$Computers,
        [Parameter(Position=0, ParameterSetName="ADLookup")]
            [string]$ADLookup
        )
    
    process {
        #$Computers = '"' + $Computers + '"';
        switch ($PSCmdlet.ParameterSetName) {
            "ADLookup" { $Servers = get-adcomputer -Filter {Name -like $ADLookup} | select -Expand Name; }
            "Computers" { 
                switch -wildcard ($Computers) {
                    "*.txt" {$Servers = Get-Content $Computers;} # parse text file
                    "*.csv" {$Servers = Get-Content $Computers;} # parse csv file
                    Default {$Servers = $Computers;}
                }
            }
            Default {}
        }
        
        #loop through all of the computers
        foreach($server in $servers)
        {
            # get all of the pertinent info
            $LoadPercentage = Get-WmiObject win32_processor -computername $server -ErrorAction SilentlyContinue | select -exp LoadPercentage; # Load Percentage
            $MemWMI = gwmi Win32_PhysicalMemory -ComputerName $server -ErrorAction SilentlyContinue # Memory info
            
            $TotalMem = 0; # initialize the totalmemory variable to 0 each time this loop runs
            # foreach loop to go through each of the memory slots on the computer
            foreach ($Stick in $MemWMI) {
                $TotalMem += ($Stick.Capacity/1GB); # add memory to totalmemory
            }
            
            # Create a psobject to display the information that you are getting
            $log = New-Object psobject -Property @{
                Server = $server;
                LoadPercentage = ($LoadPercentage | measure -Average).Average;
                MemoryGB = $TotalMem;
            }
            # Output the log
            $log
        }
    }
}
