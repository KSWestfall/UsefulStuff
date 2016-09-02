<#
removeOldProfiles.ps1
4/5/2016
Author: Kyle Westfall

Removes profiles older then a specified amount of time, defaulting to profiles over a year old.

[int]daysOld    Specifies the amount of days the profile has to be to remove it. Any profile
                older then the amount of days specified will be removed. Defaults to 1 year.
[switch]WhatIf  Flag tells you what will happen if you run this script.
[string]notify  Notifies the specified computer when the script is complete.

if there is a profile that you dont want to remove, add the profile name to the namesToExclude list
#>
#Requires 
Param(
    [Parameter(Mandatory=$False)]
        [int] $daysOld = 365,
    [Parameter(Mandatory=$False)]
        [switch] $WhatIf,
    [Parameter(Mandatory=$False)]
        [string] $profileName,
    [Parameter(Mandatory=$False)]
        [string] $notify
)

$regProfileDir = Get-ChildItem -LiteralPath 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList';
$listOfFiles = New-Object System.Collections.ArrayList;
$toBeRemoved = New-Object System.Collections.ArrayList;
$profilesDeletedIndex = 0;

# User profiles that are to be skipped.
$namesToExclude = 'bshoemaker', 'dbaird', 'a-dbaird', 'wschloot', 'ADMINI~1', 'Public', 'Administrator', 'Default'

# Determine OS and set the directory
if (((Get-WmiObject -Class Win32_OperatingSystem).caption) -contains 'XP') {
    $dirToCheck = 'C:\Documents and Settings';
}
else {
    $dirToCheck = 'C:\Users';
}
$profileDir = Get-ChildItem $dirToCheck;

# Create a list of all folders that are older then a certain amount of days.
foreach ($file in $profileDir) {
    if ($file.LastWriteTime -lt (Get-Date).AddDays(-$daysOld)) {
        if ($namesToExclude -notcontains $file.Name) {
            [void]$listOfFiles.Add($file.Name);
        }
    }
}


if ($listOfFiles -gt 0) {
    'Profiles to be removed:'
    ""
    $listOfFiles.Count; 
    "profiles";
    ""
    $escape = Read-Host -Prompt 'Would you like to continue(Y or N)?';
    if ($escape -notlike 'y') {
        break;
    }
    
    # create list of directories to remove
    foreach ($profile in $regProfileDir) {
        foreach ($profileName in $listOfFiles) {
            if ($profile.GetValue('ProfileImagePath') -like '*' + $profileName) {
                [void]$toBeRemoved.Add($profile.Name);
                break;
            }
        }
    }

    "Removing Registry Keys..."
    foreach ($item in $toBeRemoved) {
        
        $i = $item -replace 'HKEY_LOCAL_MACHINE', 'hklm:'
        if ($WhatIf) {
            Remove-Item -Path $i -Recurse -WhatIf;
        }
        else {
            cmd /c 'reg delete "$i" /f'
            Remove-Item -Path $i -Recurse;
        }
    }

    ""
    "Deleting Files... "
    foreach ($item in $listOfFiles) {
        try {
            if ($WhatIf) {
                Get-ChildItem -Path ($dirToCheck + '\' + $item) -Recurse -Hidden | Remove-Item -Force -WhatIf;
            }
            else {
                cmd /c "rd /s/q $dirToCheck\$item" | Out-Null;
                if (Test-Path "$dirToCheck\$item") {
                    cmd /c "rd /s/q $dirToCheck\$item" | Out-Null;
                }
            }
            $profilesDeletedIndex++;
        }
        catch [System.Exception] {
               
        }
        
    }
    "$profilesDeletedIndex profiles removed. Ensure all reminants of the profiles have been removed"
}
else {
    "No Profiles to delete"
}

if ($notify -ne "") {
    Invoke-WmiMethod -Class Win32_Process -ComputerName $notify -Name Create -ArgumentList "C:\Windows\System32\msg.exe $("*") /time:$(1000) $("$profilesDeletedIndex profiles removed. ensure reminates of old profiles are deleted.")"     
}