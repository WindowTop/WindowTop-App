#include-once
#include <WinAPI.au3>


Global $RegKeyBFuncEvt_hHook_Keyboard


Func RegisterKeyBoardFuncEvent_Register($Func)
	Local $hHook_Module = _WinAPI_GetModuleHandle(0)
	If @error Then Return SetError(1)
	Local $pStub_KeyProc = DllCallbackRegister($Func, "int", "int;ptr;ptr")
	If Not $pStub_KeyProc Then Return SetError(2)
	$RegKeyBFuncEvt_hHook_Keyboard = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($pStub_KeyProc), $hHook_Module, 0)
EndFunc

Func RegisterKeyBoardFuncEvent_UnRegister()
	_WinAPI_UnhookWindowsHookEx($RegKeyBFuncEvt_hHook_Keyboard)
EndFunc

Func RegisterKeyBoardFuncEvent_Continue($nCode, $wParam, $lParam)
	Return _WinAPI_CallNextHookEx($RegKeyBFuncEvt_hHook_Keyboard, $nCode, $wParam, $lParam) ;Continue processing
EndFunc