function uptime {
    Param(
        # Parameter help description
        [Parameter(Mandatory=$True,Position=1)]
            [string]$ComputerName
    )
    $lbut = gwmi win32_operatingsystem -ComputerName $ComputerName;
    $ut = $lbut.ConvertToDateTime($lbut.LocalDateTime) - $lbut.ConvertToDateTime($lbut.LastBootUpTime);
    $ut
}