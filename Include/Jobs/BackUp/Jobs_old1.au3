

Func Jobs_Remote_Call($hRemoteGUI,$iFuncID,$sFuncData = Default)




EndFunc









Func SendData ($Command)
local $res, $stCOPYDATASTRUCT, $pCommand

 $pCommand = DllStructCreate("char[" & StringLen($Command) + 1 & "]")
 DllStructSetData($pCommand, 1, $Command)

 ;COPYDATASTRUCT {ULONG_PTR dwData; DWORD cbData; PVOID lpData;}
 $stCOPYDATASTRUCT = DllStructCreate("ptr;dword;ptr")
 DllStructSetData($stCOPYDATASTRUCT, 1, 0)
 DllStructSetData($stCOPYDATASTRUCT, 2, StringLen($Command)+1)
 DllStructSetData($stCOPYDATASTRUCT, 3, DllStructGetPtr($pCommand))
 $res = DllCall("user32.dll", "int", "SendMessage", "hwnd",$Sender, "int", $WM_COPYDATA, "int", 0, "ptr", DllStructGetPtr($stCOPYDATASTRUCT))
 $pCommand = 0
 $stCOPYDATASTRUCT = 0
endfunc