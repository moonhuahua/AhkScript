#SingleInstance force
gui +AlwaysOnTop +lastfound +hwndmygui
gui color, 000000
gui show, w%A_ScreenWidth% h%A_ScreenHeight%
winset, Transparent, 0
WinSet, ExStyle, ^0x20

trans := 0

^j::
    trans := trans + 10
    winset, Transparent, %trans%, ahk_id %mygui%
return

^k::
    trans := trans - 10
    winset, Transparent, %trans%, ahk_id %mygui%
return
