#SingleInstance Force
#Persistent
SetWorkingDir, % A_ScriptDir


Menu, Tray, NoStandard
Menu, Tray, Add, 打开, open
Menu, Tray, Default, 打开
Menu, Tray, Add, 退出, exit

if(!FileExist("IMG"))
    FileCreateDir, IMG
if(!FileExist("IMG\Bing"))
    FileCreateDir, IMG\Bing
if(!FileExist("IMG\Lock"))
{
    FileCreateDir, IMG\Lock
    FileSetTime, 19000101, IMG\Lock
}
SavePath := A_ScriptDir . "\IMG\"
imgs := []
guipics := {}

IniRead, lockimg, config.ini, main, lockimg
IniRead, bingimg, config.ini, main, bingimg


if(bingimg = 1)
{
    FileGetTime, Time, % SavePath . "\Bing"
    FormatTime, DownLoaded_Date, %Time%, yyMMdd
    FormatTime, Now_Date, %A_Now%, yyMMdd
    if(DownLoaded_Date < Now_Date)
    {
        Bing_img_path := SavePath . "Bing\"
        Winhttp := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        Winhttp.Open("GET", "https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1",true)
        Winhttp.Send()
        Winhttp.WaitForResponse()
        r := Winhttp.ResponseText
        RegExMatch(r, "urlbase"":""(.*?)""", Match)
        IniRead, Pixels, config.ini, main, Pixels
        url := "https://cn.bing.com" . Match1 . "_" . Pixels . ".jpg"
        RegExMatch(url, "[^/]*$", fname)
        URLDownloadToFile, % url, % Bing_img_path . fname
    }
    IniRead, autosetbingimg, config.ini, main, autosetbingimg
    if(autosetbingimg = 1)
        DllCall("SystemParametersInfo", UINT, 20, UINT, uiParam, STR, imgpath, UINT, 2)
}


if (lockimg =1 && A_OSVersion > 10)
{
    Lock_img_path := SavePath . "Lock\"
    loop, files, % A_AppData . "\..\Local\Packages\Microsoft.Windows.ContentDeliveryManager_*", D
        Source := A_LoopFileFullPath . "\LocalState\Assets\*"
    FileGetTime, DownLoaded_time, % SavePath
    pToken := Gdip_Startup()
    Loop, files, % Source
    {
        FileGetTime, File_time, % A_LoopFileFullPath
        if(File_time <= DownLoaded_time)
            continue
        img := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
        w := Gdip_GetImageWidth(img)
        if ( w := Gdip_GetImageWidth(img) > 1200 &&  w > Gdip_GetImageHeight(img))
            FileCopy, % A_LoopFileFullPath, % Lock_img_path . A_LoopFileName . ".jpg"
    }
    Gdip_Shutdown(pToken)
}



Loop, Files, IMG\*.jpg, R
{
    imgs.push(A_LoopFileLongPath)
}

Gui, +ToolWindow +HwndMyGui
Gui, Margin, 2, 2
Gui, Color, EEEEEE, 888888
Gui +LastFound
WinSet, TransColor, EEEEEE 
Loop, 16
{
    if (Mod(A_Index, 4)=1)
        Gui, Add, Picture, xm w192 h108 gSetWallpaper, pic%A_Index%
    else
        Gui, Add, Picture, x+2 w192 h108 gSetWallpaper, pic%A_Index%
}
Gui, Show
Gui_Add_Img()
return

SetWallpaper:
    img := guipics[A_GuiControl][2]
    DllCall("SystemParametersInfo", UINT, 20, UINT, uiParam, STR, img, UINT, 2)
return
open:
    Gui, Show
return

exit:
    ExitApp
return
GuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y)
{
    global guipics
    global imgs
    GuiControlGet, id, , %CtrlHwnd%
    MsgBox, 4, 删除图片, 是否删除这张图片%id%, 3
    IfMsgBox, Yes
    {
        FileRecycle, % guipics[id][2]
        imgs.RemoveAt[guipics[id][1]]

        max := imgs.Length()
        Random, index, 1, % max
        guipics[id] := [index, imgs[index]]
        GuiControl,, % id, % guipics[id][2]
    }
}

Gui_Add_Img()
{
    global imgs
    global guipics
    static index := 0
    max := imgs.Length()
    Loop
    {
        ; index += 1
        Random, index, 1, % max
        id := "pic" . A_Index
        guipics[id] := [index, imgs[index]]
        GuiControl,, % id, % guipics[id][2]
        if(A_Index=16)
            break
    }
}

Gdip_Startup()
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	if !DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("LoadLibrary", "str", "gdiplus")
	VarSetCapacity(si, A_PtrSize = 8 ? 24 : 16, 0), si := Chr(1)
	DllCall("gdiplus\GdiplusStartup", A_PtrSize ? "UPtr*" : "uint*", pToken, Ptr, &si, Ptr, 0)
	return pToken
}

Gdip_Shutdown(pToken)
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	
	DllCall("gdiplus\GdiplusShutdown", Ptr, pToken)
	if hModule := DllCall("GetModuleHandle", "str", "gdiplus", Ptr)
		DllCall("FreeLibrary", Ptr, hModule)
	return 0
}

Gdip_CreateBitmapFromFile(sFile, IconNumber := 1, IconSize := "")
{
	Ptr := A_PtrSize ? "UPtr" : "UInt"
	PtrA := A_PtrSize ? "UPtr*" : "UInt*"
        DllCall("gdiplus\GdipCreateBitmapFromFile", Ptr, &sFile, PtrA, pBitmap)
	return pBitmap
}

Gdip_GetImageWidth(pBitmap)
{
   DllCall("gdiplus\GdipGetImageWidth", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Width)
   return Width
}

Gdip_GetImageHeight(pBitmap)
{
   DllCall("gdiplus\GdipGetImageHeight", A_PtrSize ? "UPtr" : "UInt", pBitmap, "uint*", Height)
   return Height
}



#If WinActive("ahk_id " . MyGui)
f5::
    Gui_Add_Img()
return
