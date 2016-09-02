Function GetRamInfo
{
    # Devices to get ram info from
    Param(
    [Parameter(Mandatory=$True,ValueFromPipeline=$true,Position=1)]
        [string[]]$ComputerName,

    [Parameter(Mandatory=$false)]
        [string]$OutputLocation="h:\myscripts\output\RAMtest.txt"
    )
    $index = 0;
    while ((Test-Path $OutputLocation)) {
        $index ++;
        if ($index -gt 1) {
            $OutputLocation = $OutputLocation -replace "$($index-1).txt", "$index.txt";
            $OutputLocation = $OutputLocation -replace "$($index-1).csv", "$index.csv";
        }
        else {
            $OutputLocation = $OutputLocation -replace ".txt", "$index.txt";
            $OutputLocation = $OutputLocation -replace ".csv", "$index.csv";
        }
        Write-Verbose "$OutputLocation $index";
        
    }
    
    switch -wildcard ($ComputerName) {
        "*.txt" {$Computers = Get-Content $ComputerName} # parse text file
        "*.csv" {$Computers = Get-Content $ComputerName} # parse csv file
        Default {$Computers = $ComputerName}
    }
    
    # Loop through all of the computers
    foreach ($Computer in $Computers) {
        # Get the info needed
        $wmi = Get-WmiObject -computer $Computer Win32_PhysicalMemory -ErrorAction SilentlyContinue;
        
        # Calculate the total memory for the given computer by adding the current value to $TotalMem
        $TotalMem = 0;
        foreach($device in $wmi){
            $TotalMem += $device.Capacity/1MB;
            Write-Verbose "Total Memory: $TotalMem";
        }
        
        # Manage file Output
        switch -wildcard ($OutputLocation) {
            "*.txt" {"$Computer : $TotalMem" | out-file -filepath $OutputLocation -Append; }
            "*.csv" {"$Computer : $TotalMem" | Export-Csv -filepath $OutputLocation -Append;}
            Default {"$Computer : $TotalMem"}
        }
    }
}