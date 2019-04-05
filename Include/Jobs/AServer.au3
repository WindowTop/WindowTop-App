#include <GUIConstantsEx.au3>

Global Const $WM_COPYDATA = 0x004A

Global $ServerTitle = "AServer", $ClientTitle = "AClient"

; Sender's hWnd
Global $Sender

$hGUI = GUICreate($ServerTitle, 100, 10)
GUIRegisterMsg($WM_COPYDATA, "MY_WM_COPYDATA")
GUISetState()

While 1
    $GUIMsg = GUIGetMsg()
    Switch $GUIMsg
        Case $GUI_EVENT_CLOSE
            ExitLoop
    EndSwitch
WEnd

Exit

;==================================================
Func quit()
  exit
EndFunc

;==================================================
; Handler WM_COPYDATA
Func MY_WM_COPYDATA($hWnd, $Msg, $wParam, $lParam)
local $Line
 $stCOPYDATASTRUCT = DllStructCreate("ptr;dword;ptr", $lParam)
 $Len = DllStructGetData($stCOPYDATASTRUCT, 2)
 $pCommand = DllStructGetData($stCOPYDATASTRUCT, 3)
 $stCommand = DllStructCreate("char[" & $Len & "]", $pCommand)
 $Data = DllStructGetData($stCommand, 1)
; Msgbox(0, "AServer", "Data Received = " & $Data)
 $Line = StringSplit($Data,":")
 $Sender = $Line[1]
 $Command = StringTrimLeft($Data,StringLen($Sender & ":"))
 Msgbox(0, "AServer", "Command Received = " & $Command)
 SendData(Execute($Command))
 return 0
EndFunc

;===============================================================
; Send data to window with $hWnd specified
func SendData ($Command)
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