function Stop-USPGServices ([string] $ServiceToStop = "USPG\*"){
    Write-Host "Stopping the following Services running under username $ServiceToStop :"
    $ListOfServices = Get-WmiObject win32_Service | where {$_.StartName -like $ServiceToStop} 
    foreach ($item in $ListOfServices) {
        $item = $item -split "Name=" -replace '"', ""
        Write-Host $item[1]
    }
    Get-WmiObject win32_Service | where {$_.StartName -like $ServiceToStop} | Stop-Service
}

function Set-Startmode
{
    param(
    [ValidateSet("auto","manual","disable")]
    [String] $Name = "manual",
    [string] $UserServicesToStop = "USPG\*",
    [string] $ServiceName,
    [switch] $y
    )
    Process
    {
        if ($ServiceName -ne $null) { Get-WmiObject win32_Service | where {$_.StartName -like $UserServicesToStop} | select Name }
        else { Get-WmiObject win32_Service | where {$_.Name -like $ServiceName} | select Name}

        $UserInput = Read-Host
        if ($UserInput -icontains "n") {
            break
        }

        if ($ServiceName -eq $null) {
            switch ($Name) {
                "auto" { Get-WmiObject win32_Service | where {$_.StartName -like $UserServicesToStop} | Set-Service -StartupType Automatic }
                "disable" { Get-WmiObject win32_Service | where {$_.StartName -like $UserServicesToStop} | Set-Service -StartupType Disabled }
                Default { Get-WmiObject win32_Service | where {$_.StartName -like $UserServicesToStop} | Set-Service -StartupType Manual}
            }
        }
        else {
            Get-WmiObject win32_Service | where {$_.Name -like $ServiceName} | Set-Service -StartupType Automatic
            switch ($Name) {
                "auto" { Get-WmiObject win32_Service | where {$_.Name -like $ServiceName} | Set-Service -StartupType Automatic }
                "disable" { Get-WmiObject win32_Service | where {$_.Name -like $ServiceName} | Set-Service -StartupType Disabled }
                Default { Get-WmiObject win32_Service | where {$_.Name -like $ServiceName} | Set-Service -StartupType Manual }
            }
        }
    }
}
