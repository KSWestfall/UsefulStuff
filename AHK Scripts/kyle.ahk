#t:: StartMaxOrMin("C:\Program Files\ConEmu\ConEmu64.exe", "ahk_exe ConEmu64.exe")
#c:: StartMaxOrMin("C:\Program Files (x86)\Microsoft VS Code\Code.exe", "ahk_exe Code.exe")
#v:: CheckIfMinOrMaxed("ahk_exe devenv.exe")
#s:: StartMaxOrMin("C:\Windows\System32\SnippingTool.exe", "ahk_exe SnippingTool.exe")

StartMaxOrMin(programFilePath, ahkexe)
{
    IfWinNotExist %ahkexe%
    {
        Run, %programFilePath%
    }
    Else
    {
        winget, checkmax, MinMax, %ahkexe%
        if (checkmax < 1)
        {
                WinMaximize, %ahkexe%
        } 
        else
        {
            ifWinActive, %ahkexe% 
            {
                WinMinimize, %ahkexe%
            } 
            else 
            {
                WinActivate, %ahkexe% 
            }
        }
    }
    return
}

CheckIfMinOrMaxed(ahkexe)
{
    winget, checkmax, MinMax, %ahkexe%
    if (checkmax < 1)
    {
        WinMaximize, %ahkexe%
    }
    else
    {
        WinMinimize, %ahkexe%
    }
    return
}

#PgUp:: 
SoundSet, +5
SoundPlay, %A_WinDir%\Media\ding.wav
return
#PgDn:: 
SoundSet, -5
SoundPlay, %A_WinDir%\Media\ding.wav
return
#End:: SoundSet, +1, , mute

;=================================
; Volume Control with Visual Feedback
;
!WheelUP::
!WheelDown::

mixer=Volume Mixer
mixeropened := false

Suspend, On
loop
{
	alt_down := GetKeyState("LAlt", "P")

    if(mixeropened=false) ; executes only first time in loop
    {
        Run C:\Windows\System32\SndVol.exe
        Sleep 100

        WinGetPos,,, Width, Height,%mixer%
        WinMove,%mixer%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)

        WinActivate,%mixer%
        WinWait,%mixer%
        mixeropened := true
    }

	if(alt_down=false)
    {
        Suspend off
        WinClose,%mixer%
        Exit
    }
}