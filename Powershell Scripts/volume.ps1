Function Set-SpeakerVolume{ 
    Param 
    (
        [switch]$min,
        [switch]$max
    )

    $wshShell = new-object -com wscript.shell

    If ($min)
    {1..50 | % {$wshShell.SendKeys([char]174)}}
    ElseIf ($max)
    {1..50 | % {$wshShell.SendKeys([char]175)}}
    Else
    {$wshShell.SendKeys([char]173)} 
}