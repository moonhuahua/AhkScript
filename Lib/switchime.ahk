switchime(ime := "A")
{
    if (ime = 1)
    {
        DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("LoadKeyboardLayout", Str,"00000804", UInt, 1))
    }
    else If (ime = 0)
    {
        DllCall("SendMessage", UInt, WinActive("A"), UInt, 80, UInt, 1, UInt, DllCall("LoadKeyboardLayout", Str,, UInt, 1))
    }
    Else If (ime = "A")
    {
        ime_status:=DllCall("GetKeyboardLayout","int",0,UInt)
    }
}
