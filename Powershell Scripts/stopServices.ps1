function Stop-USPGServices ([string] $ServiceToStop = "USPG\*"){
    Write-Host "Stopping the following Services running under username $ServiceToStop :"
    $ListOfServices = Get-WmiObject win32_Service | where {$_.StartName -like $ServiceToStop} 
    foreach ($item in $ListOfServices) {
        $item = $item -split "Name=" -replace '"', ""
        Write-Host $item[1]
    }
    Get-WmiObject win32_Service | where {$_.StartName -like $ServiceToStop} | Stop-Service
}
