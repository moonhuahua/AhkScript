#Include RunAsAdmin.ahk
SetTime(YYYYMMDDHHMISSMS)  
{  
  VarSetCapacity(localTime, 16, 0) ; 这个结构体是由 8 个 UShorts 组成，所以容量为 8×2=16  
  
  StringLeft, Int, YYYYMMDDHHMISSMS, 4 ; YYYY (年)  
  NumPut(Int, localTime, 0, "UShort")  
  
  StringMid, Int, YYYYMMDDHHMISSMS, 5, 2 ; MM (月份, 1-12)  
  NumPut(Int, localTime, 2, "UShort")  
  
  StringMid, Int, YYYYMMDDHHMISSMS, 7, 2 ; DD (日)  
  NumPut(Int, localTime, 6, "UShort")  
  
  StringMid, Int, YYYYMMDDHHMISSMS, 9, 2 ; HH (小时 0-23)  
  NumPut(Int, localTime, 8, "UShort")  
  
  StringMid, Int, YYYYMMDDHHMISSMS, 11, 2 ; MI (分)  
  NumPut(Int, localTime, 10, "UShort")  
  
  StringMid, Int, YYYYMMDDHHMISSMS, 13, 2 ; SS (秒)  
  NumPut(Int, localTime, 12, "UShort")  
  
  StringMid, Int, YYYYMMDDHHMISSMS, 15, 3 ; MS (毫秒)  
  NumPut(Int, localTime, 14, "UShort")  
  Return,DllCall("SetLocalTime", UInt, &localTime)  
}
