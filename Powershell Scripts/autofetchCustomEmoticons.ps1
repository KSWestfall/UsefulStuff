Stop-Process -Name CiscoJabber
$CustomEmoticonPath = "C:\Program Files (x86)\Cisco Systems\Cisco Jabber\CustomEmoticons"
cd $CustomEmoticonPath

if (Get-Command "git" -ErrorAction SilentlyContinue) {
    $output = git pull origin master
}
elseif (test-path "C:\Program Files\Git\bin\git.exe") {
    $output = . "C:\Program Files\Git\bin\git.exe" pull origin master
}
elseif (test-path "%USERPROFILE%\AppData\Local\Programs\Git\git-cmd.exe") {
    $output = . "%USERPROFILE%\AppData\Local\Programs\Git\git-cmd.exe" pull origin master
}

. "C:\Program Files (x86)\Cisco Systems\Cisco Jabber\CiscoJabber.exe"
