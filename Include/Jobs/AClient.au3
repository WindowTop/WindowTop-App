#include <GUIConstantsEx.au3>

HotKeySet('{ESC}',Exit1)
Func Exit1()
	Exit
EndFunc


Global Const $WM_COPYDATA = 0x004A

Global $ServerTitle = "AServer", $ClientTitle = "AClient"

$hWnd = GUICreate($ClientTitle, 300, 100)
ConsoleWrite($hWnd &' (L: '&@ScriptLineNumber&')'&@CRLF)
GUIRegisterMsg($WM_COPYDATA, "MY_WM_COPYDATA")

GUISetState()

Do

Until GUIGetMsg() = $GUI_EVENT_CLOSE


;==================================================
; Handler WM_COPYDATA
Func MY_WM_COPYDATA($hWnd, $Msg, $wParam, $lParam)
	$stCOPYDATASTRUCT = DllStructCreate("ptr;dword;ptr", $lParam)
	$Len = DllStructGetData($stCOPYDATASTRUCT, 2)
	$pCommand = DllStructGetData($stCOPYDATASTRUCT, 3)
	$stCommand = DllStructCreate("char[" & $Len & "]", $pCommand)
	$Command = DllStructGetData($stCommand, 1)
	MsgBox(0, "AClient", "Data Received from AServer: " & $Command)
	Execute($Command)
	Return 0
EndFunc   ;==>MY_WM_COPYDATA
