$Komputahz = Get-Content "list2.txt"    #CHANGE "PATH" TO "PATH OF TEXT FILE CONTAINING DEVICE NAMES"
    $OutFile = "TESTING3.txt"           #CHANGE "PATH" TO "PATH OF TEXT FILE CONTAINING RESULTS TO BE CREATED"

    ForEach ($Komputah in $Komputahz)
    {
        if (Test-Connection $Komputah -count 1)
        {
            "$Komputah | ONLINE" | out-file -filepath $Outfile -append
        }

        else
        {
            "$Komputah | OFFLINE" | out-file -filepath $Outfile -append
        }

    } 