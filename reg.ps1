$regProfileDir = Get-ChildItem -LiteralPath "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList";
$dir = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$namesToExclude = 'bshoemaker', 'dbaird', 'a-dbaird', 'wschloot', 'ADMINI~1', 'Public', 'Administrator', 'Default'

foreach ($item in $regProfileDir) {
    foreach ($name in $namesToExclude) {
        
    }
    if ($namesToExclude -notcontains $item.GetValue('ProfileImagePath')) {
        $item.GetValue('ProfileImagePath')
    } 
}