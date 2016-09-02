if ($PSVersionTable.PSVersion.Major -ge 3) {
    Test-ComputerSecureChannel –credential "$($env:COMPUTERNAME)\Administrator" –Repair
}
else {
    Test-ComputerSecureChannel -Repair
}
