function Get-SID {
    [CmdletBinding()]
    param(
        # Username
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
            [string[]]$Username,
        
        [Parameter(Mandatory=$false)]
            [string]$Domain=$env:USERDNSDOMAIN
    )
        
    process {
        foreach ($Person in $Username) {
            $i = New-Object System.Security.Principal.NTAccount("$Domain", "$Person")
            $j = $i.Translate([System.Security.Principal.SecurityIdentifier]);
            $j.Value;
        }
    }
}

function Get-Username {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
            [string[]]$SID
    )
    
    process {
        $objSID = New-Object System.Security.Principal.SecurityIdentifier ("$SID")
        $objUser = $objSID.Translate( [System.Security.Principal.NTAccount]);
        $objUser.Value;
    }
}