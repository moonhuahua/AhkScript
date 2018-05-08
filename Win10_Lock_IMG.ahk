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
Menu, Tray, Add, �����ֽ(&R),SetRandomWallpaper
Menu, Tray, Default,�����ֽ(&R) 
Menu, Tray, Add, ��һ�ű�ֽ(&P),SetPreviousWallpaper
Menu, Tray, Add, ��һ�ű�ֽ(&N),SetNextWallpaper
Menu, Tray, Add, ��������,AutoStart
Menu, Tray, Add, �򿪱�ֽ�ļ���(&O),OpenDir
Menu, Tray, Add, ɾ����ǰ��ֽ(&D),DelWallpaper
Menu, Tray, Add, ����, Reload
Menu, Tray, Add, �˳�, Exit
if(FileExist(startuplnk))
    Menu, Tray, Check, ��������
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
    msgbox, 36, ɾ����ֽ, ȷ��ɾ����ǰ��ֽ��?
    IfMsgBox, Yes
        FileRecycle, % img[i]
    GoSub SetRandomWallpaper
return

AutoStart:
    if(FileExist(startuplnk))
        FileDelete, % startuplnk
    else
        FileCreateShortcut, % A_ScriptFullpath, % startuplnk
    Menu, Tray, ToggleCheck, ��������
return

Exit:
    ExitApp
return

Reload:
    Reload
return

; �����б�

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
