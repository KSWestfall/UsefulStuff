function sort-files () {
    function get-filedate ([string]$fileName) {
        return @($fileName.Substring(0,4),$fileName.Substring(4,2))
    }
    $files = Get-ChildItem

    foreach ($file in $files) {
        if ($file.Extension -ne ".jpg" -and $file.Extension -ne ".mp4") {
            continue;
        }
        $filedate = get-filedate($file)
        $filedir = "$($filedate[0])\$($filedate[1])"
        if (!(Test-Path $filedir)) {
            New-Item -ItemType Directory $filedir
        }
        Move-Item $file -Destination $filedir
    }


}
sort-files