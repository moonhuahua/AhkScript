#Persistent
SavePath := A_ScriptDir . "\lockimg\"
startuplnk := A_StartMenu . "\Programs\Startup\Win10_Lock_IMG.lnk"
loop, files, % A_AppData . "\..\Local\Packages\Microsoft.Windows.ContentDeliveryManager_*", D
    Source := A_LoopFileFullPath . "\LocalState\Assets\*"
SavePath := RTrim(SavePath, "\")
If(!FileExist(SavePath))
{
    FileCreateDir, % SavePath
    FileSetTime, 19000101, % SavePath
}
FileGetTime, StartTime, % SavePath
SavePath .= "\"

pToken := Gdip_Startup()
Loop, files, % Source
{
    FileGetTime, OutputVar, % A_LoopFileFullPath
    if(OutputVar <= StartTime)
        continue
    img := Gdip_CreateBitmapFromFile(A_LoopFileFullPath)
    w := Gdip_GetImageWidth(img)
    if ( w := Gdip_GetImageWidth(img) > 1200 &&  w > Gdip_GetImageHeight(img))
        FileCopy, % A_LoopFileFullPath, % SavePath . A_LoopFileName . ".jpg"
}
Gdip_Shutdown(pToken)

img := []
Loop, files, % SavePath . "*.jpg"
{
    img[A_Index] := A_LoopFileFullPath
}
min := 1
max := img.Length()

GoSub SetRandomWallpaper
Menu, Tray, NoStandard
Menu, Tray, Add, 随机壁纸(&R),SetRandomWallpaper
Menu, Tray, Default,随机壁纸(&R) 
Menu, Tray, Add, 上一张壁纸(&P),SetPreviousWallpaper
Menu, Tray, Add, 下一张壁纸(&N),SetNextWallpaper
Menu, Tray, Add, 开机启动,AutoStart
Menu, Tray, Add, 打开壁纸文件夹(&O),OpenDir
Menu, Tray, Add, 删除当前壁纸(&D),DelWallpaper
Menu, Tray, Add, 重启, Reload
Menu, Tray, Add, 退出, Exit
if(FileExist(startuplnk))
    Menu, Tray, Check, 开机启动
return

SetRandomWallpaper:
    Random, i, % min, % max
    SetWallpaper(img[i])
return

SetNextWallpaper:
    i += 1
    SetWallpaper(img[i])
return

SetPreviousWallpaper:
    i -= 1
    SetWallpaper(img[i])
return

OpenDir:
    run % SavePath
return

DelWallpaper:
    msgbox, 36, 删除壁纸, 确定删除当前壁纸吗?
    IfMsgBox, Yes
        FileRecycle, % img[i]
    GoSub SetRandomWallpaper
return

AutoStart:
    if(FileExist(startuplnk))
        FileDelete, % startuplnk
    else
        FileCreateShortcut, % A_ScriptFullpath, % startuplnk
    Menu, Tray, ToggleCheck, 开机启动
return

Exit:
    ExitApp
return

Reload:
    Reload
return

; 函数列表

SetWallpaper(BMPpath)
{
	SPI_SETDESKWALLPAPER := 20
	SPIF_SENDWININICHANGE := 2  
	Return DllCall("SystemParametersInfo", UINT, SPI_SETDESKWALLPAPER, UINT, uiParam, STR, BMPpath, UINT, SPIF_SENDWININICHANGE)
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
