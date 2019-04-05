#Region Header

#CS UDF Info
;Extended (advanced) function to block mouse & keyboard inputs.
;
; This UDF supports few features that built-in BlockInput() function does not.
; Here is a quick "features list":
;----------------------------------------------------------------------
;* Block seperately mouse or keyboard input.
;* Block specific keyboard/mouse keys/clicks.
;     [+] Not only hex keys are supported, string keys (such as {ENTER}) is also valid.
;* Block all keyboard/mouse keys *except* specific keys/events.
;* Block keys by CLASS Name (see UDF documentation).
;* Block inputs only for specific window.
;* BlockInput does not re-enables input after pressing Ctrl+Alt+Del.
;----------------------------------------------------------------------
;
; AutoIt Version: 3.2.12.1+
; Author: G.Sandler (a.k.a MrCreatoR). Initial idea and hooks example by rasim.
;
; Remarks: This UDF, same as built-in BlockInput function, can not block Ctrl+Alt+Del, however, it will not re-enable the input.
;
;
;==================
; History version:
;==================
; [v1.8 - 12.05.2013, 12:16]
; * Fixed issue when some numeric keyboard keys was not blocked.
; * Fixed issue when ALT+Tab was not blocked.

; [v1.7 - 04.05.2012, 18:45]
; * Now by default the UDF affects only on user-input, the same as standard BlockInput function. Can be changed with additional parameter $iBlockAllInput, if set to 1, then all input will be blocked, not just the user's.
; * Added optional parameter $iBlockAllInput to allow block only user-input (default 0, block only user-input).
; * Minor fixes.
;
; [v1.6 - 04.04.2011, 22:30]
; * Fixed (again, caused by fix with re-enabled input) an issue with held down "Alt + Ctrl" keys after the user was called "Alt + Ctrl + Del".
; * Fixed an issue with wrong parameter passed to _WinAPI_CallNextHookEx. Thanks to Ascend4nt.
; + Added remarks to the UDF header.
; + Added "Example - Block TaskMan.au3".
;
; [v1.5 - 11.10.2010, 22:20]
; * Fixed an issue with re-enabled input after pressing Ctrl+Alt+Del.
; * Now the $hWindows parameter can be used for mouse blocking.
;    For that reason the $i_MouseHookGetAncestorHwnd variable was added to the UDF,
;    if user sets it to 0, then the $hWindows is compared to currently hovered window handle, otherwise (1 - default) it's compared to ancestor of the hovered window/control.
;
; [v1.4 - 03.08.2010, 12:00]
; + AutoIt 3.3.6.1 support.
; * Fixed an issue with held down "Alt + Ctrl" keys after the user was called "Alt + Ctrl + Del". It was causing a problems to use HotKeySet later.
; * Fixed examples to be compatible with AutoIt 3.3.6.1.
; * Minor "cosmetic" changes.
;
; [v1.3 - 24.09.2009, 23:00]
; + Added _BlockInputEx Example (Pass Lock)
; * Fixed few examples.
; * Fixed spell mistakes in the UDF.
;
; [v1.2 - 16.01.2009, 21:00]
; + Added key strings support.
;    Now users can set simple hotkey strings for Exclude/Include parameters + Group chars, i.e: "[Group]|{UP}|{DOWN}"
;    (See UDF documentation)
; + Added mouse events blocking support to the $sExclude/$sInclude parameters.
; + Added example for mouse events blocking.
;
; [v1.1 - 16.01.2009]
; + Added CLASSes support (see UDF documentation), thanks to FireFox for the idea and the keys lists.
; + Added example for CLASS usage.
; * Changed behaviour of $iBlockMode parameter as following:
;
;    1  - Block All
; <= 0  - UnBlock all
;    2  - Block only mouse
;    3  - Block only keyboard.
;
; * Fixed hard-crash that related to incorrect BlockInput releasing process (only callbacks was released, not the window hooks).
;
; [v1.0 - 15.01.2009]
; First release.
#CE

#include-once
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <Misc.au3>

If @AutoItVersion >= '3.3.2.0' Then
	Execute('OnAutoItExitRegister("__BlockInputEx_OnAutoItExit")')
Else
	Execute('Assign("i_OptOEF", Opt("OnExitFunc", "__BlockInputEx_OnAutoItExit"), 2)')
EndIf

#EndRegion Header

#Region Global Variables

Global $ah_MouseKeyboard_WinHooks[8]
Global $s_KeyboardKeys_Buffer
Global $i_MouseHookGetAncestorHwnd = 1

#EndRegion Global Variables

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _BlockInputEx
; Description ...: Disable/enable the mouse and/or keyboard. Supporting blocking (by include/exclude) of seperate keys.
; Syntax.........: _BlockInputEx( [iBlockMode [, sExclude [, sInclude [, hWindows [, $iBlockAllInput]]]]] )
;
; Parameters ....: $iBlockMode    - [Optional] Set the block mode.
;                                                     1  - Block All
;                                                  <= 0  - UnBlock all
;                                                     2  - Block only mouse
;                                                     3  - Block only keyboard.
;
;                  $sExclude      - [Optional] Keys hex/string-list (| delimited) to *exclude* when blocking.
;                                    [*] All keys will be blocked, except the keys in $sExclude list.
;                                    [!] This list supports keys CLASSes,
;                                        key strings as supported in HotKeySet() function,
;                                        and seperate mouse events classes, see "Remarks" for more details.
;
;                                 
;
;                  $sInclude      - [Optional] Keys hex/string-list (| delimited) to *include* when blocking.
;                                    [*] Only these keys will be blocked, the $sExclude ignored in this case.
;                                    [!] This list supports keys CLASSes,
;                                        key strings as supported in HotKeySet() function,
;                                        and seperate mouse events classes, see "Remarks" for more details.
;
;                  $hWindows       - [Optional] Window handles list (| delimited) to limit the blocking process.
;
;                  $iBlockAllInput - [Optional] If this parameter is 0 (default),
;                                      then only user input will be blocked (the same behaviour as standard BlockInput function), otherwise all input will be blocked (including *Send and Mouse* functions).
;
; Return values .: Success     - 1.
;                  Failure     - 0 and set @error to 1. This can happend only when passing wrong parameters.
;
; Author ........: G.Sandler (a.k.a MrCreatoR), Rasim -> Initial idea and hooks example.
;                  Thanks to FireFox for other block methods, it gave me a starting point for adding the "keys classes" support.
;
;
; Modified.......: 
; Remarks .......: * This UDF includes OnAutoItExit function to release the callback/hooks resources.
;
;                  * $sExclude and $sInclude parameters supporting keys/mouse classes as hex or as string,
;                     [!] The hex keys list can be found in _IsPressed documentation section.
;                      Here is a full list of supported classess/events:
;                                                      ======= KeyBoard =======
;                                                               [:FUNC:]
;                                                               [:ALPHA:]
;                                                               [:NUMBER:]
;                                                               [:ARROWS:]
;                                                               [:SPECIAL:]
;                                                               [GROUP_abcd] -> Use raw chars/key strings inside squere brackets.
;                                                               {KEY} -> Standard keys support ({F1}, {ENTER} etc.).
;
;                                                      ========= Mouse =========
;                                                               {MMOVE}    -> Mouse move event
;                                                               {MPDOWN}   -> Mouse Primary Down event
;                                                               {MPUP}     -> Mouse Primary Up event
;                                                               {MSDOWN}   -> Mouse Secondary Down event
;                                                               {MSUP}     -> Mouse Secondary Up event
;                                                               {MWDOWN}   -> Mouse WHEEL Button Down event
;                                                               {MWUP}     -> Mouse WHEEL Button Up event
;                                                               {MWSCROLL} -> Mouse WHEEL Scroll event
;                                                               {MSPDOWN}  -> Mouse Special Button Down event
;                                                               {MSPUP}    -> Mouse Special Button Up event
;
;
;                  * See also built-in BlockInput() documentation.
;
; Related .......: BlockInput()?
; Link ..........; http://www.autoitscript.com/forum/index.php?s=&showtopic=87735
; Example .......; Yes
; ===============================================================================================================================
Func _BlockInputEx($iBlockMode = -1, $sExclude = "", $sInclude = "", $hWindows = "", $iBlockAllInput = 0)
	If $iBlockMode < -1 Or $iBlockMode > 3 Then Return SetError(1, 0, 0) ;Only -1 to 3 modes are supported.
	
	If $iBlockMode <= 0 Then Return __BlockInputEx_UnhookWinHooks_Proc()
	
	Local $pStub_KeyProc = 0, $pStub_MouseProc = 0, $hHook_Keyboard = 0, $hHook_Mouse = 0
	Local $hHook_Module = _WinAPI_GetModuleHandle(0)
	
	For $i = 0 To 3
		If $ah_MouseKeyboard_WinHooks[$i] > 0 Then
			__BlockInputEx_UnhookWinHooks_Proc()
			ExitLoop
		EndIf
	Next
	
	If $iBlockMode = 1 Or $iBlockMode = 2 Then
		$pStub_MouseProc = DllCallbackRegister("__BlockInputEx_MouseHook_Proc", "int", "int;ptr;ptr")
		$hHook_Mouse = _WinAPI_SetWindowsHookEx($WH_MOUSE_LL, DllCallbackGetPtr($pStub_MouseProc), $hHook_Module, 0)
	EndIf
	
	If $iBlockMode = 1 Or $iBlockMode = 3 Then
		$pStub_KeyProc = DllCallbackRegister("__BlockInputEx_KeyBoardHook_Proc", "int", "int;ptr;ptr")
		$hHook_Keyboard = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($pStub_KeyProc), $hHook_Module, 0)
	EndIf
	
	$ah_MouseKeyboard_WinHooks[0] = $pStub_KeyProc
	$ah_MouseKeyboard_WinHooks[1] = $pStub_MouseProc
	$ah_MouseKeyboard_WinHooks[2] = $hHook_Keyboard
	$ah_MouseKeyboard_WinHooks[3] = $hHook_Mouse
	$ah_MouseKeyboard_WinHooks[4] = "|" & __BlockInputEx_Parse_vmCodesList_CLASSes(__BlockInputEx_Parse_vkCodesList_CLASSes($sInclude)) & "|"
	$ah_MouseKeyboard_WinHooks[5] = "|" & __BlockInputEx_Parse_vmCodesList_CLASSes(__BlockInputEx_Parse_vkCodesList_CLASSes($sExclude)) & "|"
	$ah_MouseKeyboard_WinHooks[6] = "|" & $hWindows & "|"
	$ah_MouseKeyboard_WinHooks[7] = $iBlockAllInput
	
	Return 1
EndFunc

#EndRegion Public Functions

#Region Internal Functions

;KeyBoard hook processing function
Func __BlockInputEx_KeyBoardHook_Proc($nCode, $wParam, $lParam)
	If $nCode < 0 Then
		Return _WinAPI_CallNextHookEx($ah_MouseKeyboard_WinHooks[2], $nCode, $wParam, $lParam)
	EndIf
	
	Local $KBDLLHOOKSTRUCT = DllStructCreate("dword vkCode;dword scanCode;dword flags;dword time;ptr dwExtraInfo", $lParam)
	Local $iFlags = DllStructGetData($KBDLLHOOKSTRUCT, "flags")
	Local $iDec_vkCode = DllStructGetData($KBDLLHOOKSTRUCT, "vkCode")
	Local $vkCode = "0x" & Hex($iDec_vkCode, 2)
	
	If Not StringInStr($s_KeyboardKeys_Buffer, $iDec_vkCode & '|') Then
		$s_KeyboardKeys_Buffer &= $iDec_vkCode & '|'
	EndIf
	
	Local $sInclude = $ah_MouseKeyboard_WinHooks[4]
	Local $sExclude = $ah_MouseKeyboard_WinHooks[5]
	Local $hWnds = $ah_MouseKeyboard_WinHooks[6]
	Local $iBlockAllInput = $ah_MouseKeyboard_WinHooks[7]
	
	If $iBlockAllInput = 0 And BitAND($iFlags, 16) Then
		Return _WinAPI_CallNextHookEx($ah_MouseKeyboard_WinHooks[2], $nCode, $wParam, $lParam)
	EndIf
	
	If (StringInStr($s_KeyboardKeys_Buffer, '165|') And StringInStr($s_KeyboardKeys_Buffer, '163|') And StringInStr($s_KeyboardKeys_Buffer, '46|')) Or _
		(StringInStr($s_KeyboardKeys_Buffer, '164|') And StringInStr($s_KeyboardKeys_Buffer, '162|') And StringInStr($s_KeyboardKeys_Buffer, '46|')) Then
		
		Sleep(10)
		$s_KeyboardKeys_Buffer = ""
		
		Return _WinAPI_CallNextHookEx($ah_MouseKeyboard_WinHooks[2], $nCode, $wParam, $lParam) ;Continue processing
	EndIf
	
	If $sInclude <> "||" Then 	;Include proc
		If StringInStr($sInclude, "|" & $vkCode & "|") And ($hWnds = "||" Or StringInStr($hWnds, "|" & WinGetHandle("[ACTIVE]") & "|")) Then
			Return 1 ;Block processing!
		EndIf
	Else 						;Exclude proc
		If Not StringInStr($sExclude, "|" & $vkCode & "|") And ($hWnds = "||" Or StringInStr($hWnds, "|" & WinGetHandle("[ACTIVE]") & "|")) Then
			Return 1 ;Block processing!
		EndIf
	EndIf
	
	Return _WinAPI_CallNextHookEx($ah_MouseKeyboard_WinHooks[2], $nCode, $wParam, $lParam) ;Continue processing
EndFunc

;Mouse hook processing function
Func __BlockInputEx_MouseHook_Proc($nCode, $wParam, $lParam)
	If $nCode < 0 Then Return _WinAPI_CallNextHookEx($ah_MouseKeyboard_WinHooks[3], $nCode, $wParam, $lParam) ;Continue processing
	
	Local $MOUSEHOOKSTRUCT = DllStructCreate("ptr pt;hwnd hwnd;uint wHitTestCode;ulong_ptr dwExtraInfo", $lParam)
	Local $iExtraInfo = DllStructGetData($MOUSEHOOKSTRUCT, "dwExtraInfo")
	Local $iMouse_Event = BitAND($wParam, 0xFFFF)
	;Add mouse exclude/include actions support...
	
	Local $sInclude = $ah_MouseKeyboard_WinHooks[4]
	Local $sExclude = $ah_MouseKeyboard_WinHooks[5]
	Local $hWnds = $ah_MouseKeyboard_WinHooks[6]
	Local $iBlockAllInput = $ah_MouseKeyboard_WinHooks[7]
	
	If $iBlockAllInput = 0 And $iExtraInfo <> 0 Then
		Return _WinAPI_CallNextHookEx($ah_MouseKeyboard_WinHooks[3], $nCode, $wParam, $lParam) ;Continue processing
	EndIf
	
	If $sInclude <> "||" Then 	;Include proc
		If StringInStr($sInclude, "|" & $iMouse_Event & "|") And ($hWnds = "||" Or StringInStr($hWnds, "|" & __BlockInputEx_WinGetHovered() & "|")) Then
			Return 1 ;Block processing!
		EndIf
	Else 						;Exclude proc
		If Not StringInStr($sExclude, "|" & $iMouse_Event & "|") And ($hWnds = "||" Or StringInStr($hWnds, "|" & __BlockInputEx_WinGetHovered() & "|")) Then
			Return 1 ;Block processing!
		EndIf
	EndIf
	
	Return _WinAPI_CallNextHookEx($ah_MouseKeyboard_WinHooks[3], $nCode, $wParam, $lParam) ;Continue processing
EndFunc

;Releases callbacks and Unhook Windows hooks
Func __BlockInputEx_UnhookWinHooks_Proc()
	;Release KeyBoard callback function
	If $ah_MouseKeyboard_WinHooks[0] > 0 Then
		DllCallbackFree($ah_MouseKeyboard_WinHooks[0])
		$ah_MouseKeyboard_WinHooks[0] = 0
	EndIf
	
	;Release Mouse callback function
	If $ah_MouseKeyboard_WinHooks[1] > 0 Then
		DllCallbackFree($ah_MouseKeyboard_WinHooks[1])
		$ah_MouseKeyboard_WinHooks[1] = 0
	EndIf
	
	;Release KeyBoard Window hook
	If IsPtr($ah_MouseKeyboard_WinHooks[2]) Then
		_WinAPI_UnhookWindowsHookEx($ah_MouseKeyboard_WinHooks[2])
		$ah_MouseKeyboard_WinHooks[2] = 0
	EndIf
	
	;Release Mouse Window hook
	If IsPtr($ah_MouseKeyboard_WinHooks[3]) Then
		_WinAPI_UnhookWindowsHookEx($ah_MouseKeyboard_WinHooks[3])
		$ah_MouseKeyboard_WinHooks[3] = 0
	EndIf
	
	Return 1
EndFunc

Func __BlockInputEx_Parse_vkCodesList_CLASSes($sList)
	$sList = StringRegExpReplace($sList, "(?i)\{(Ctrl|Shift|Alt)\}", "{L$1}|{R$1}") ;Fix for Ctrl/Shift/Alt keys (add L/R to them)
	
	Local $a_vkCode_List = StringSplit($sList, "|")
	Local $sRet_Keys = ""
	
	For $i = 1 To $a_vkCode_List[0]
		Switch $a_vkCode_List[$i]
			Case "[:FUNC:]"
				$a_vkCode_List[$i] = "0x70|0x71|0x72|0x73|0x74|0x75|0x76|0x77|0x78|0x79|0x7A|0x7B|0x7C|0x7D|0x7E|0x7F|0x80H|0x81H|0x82H|0x83H|0x84H|0x85H|0x86H|0x87H"
			Case "[:ALPHA:]"
				$a_vkCode_List[$i] = "0x41|0x42|0x43|0x44|0x45|0x46|0x47|0x48|0x49|0x4A|0x4B|0x4C|0x4D|0x4E|0x4F|0x50|0x51|0x52|0x53|0x54|0x55|0x56|0x57|0x58|0x59|0x5A"
			Case "[:NUMBER:]"
				$a_vkCode_List[$i] = "0x30|0x31|0x32|0x33|0x34|0x35|0x36|0x37|0x38|0x39|0x60|0x61|0x62|0x63|0x64|0x65|0x66|0x67|0x68|0x69"
			Case "[:ARROWS:]"
				$a_vkCode_List[$i] = "0x25|0x26|0x27|0x28"
			Case "[:SPECIAL:]"
				$a_vkCode_List[$i] = "0x08|0x09|0x0C|0x0D|0x10|0x11|0x12|0x13|0x14|0x1B|0x20|0x21|0x22|" & _
					"0x23|0x24|0x29|0x2A|0x2B|0x2C|0x2D|0x2E|0x5B|0x5C|0x6A|0x6B|0x6C|" & _
					"0x6D|0x6E|0x6F|0x90|0x91|0xA0|0xA1|0xA2|0xA3|0xA4|0xA5|0xBA|0xBB|" & _
					"0xBC|0xBD|0xBE|0xBF|0xC0|0xDB|0xDC|0xDD"
			Case Else
				$a_vkCode_List[$i] = __BlockInputEx_KeyStr_To_vkCode($a_vkCode_List[$i])
		EndSwitch
		
		$sRet_Keys &= $a_vkCode_List[$i] & "|"
	Next
	
	Return StringRegExpReplace($sRet_Keys, "\|+$", "")
EndFunc

Func __BlockInputEx_Parse_vmCodesList_CLASSes($sList)
	Local Const $MOUSE_MOVE_EVENT				= 512
	Local Const $MOUSE_PRIMARYDOWN_EVENT		= 513
	Local Const $MOUSE_PRIMARYUP_EVENT			= 514
	Local Const $MOUSE_SECONDARYDOWN_EVENT		= 516
	Local Const $MOUSE_SECONDARYUP_EVENT		= 517
	Local Const $MOUSE_WHEELDOWN_EVENT			= 519
	Local Const $MOUSE_WHEELUP_EVENT			= 520
	Local Const $MOUSE_WHEELSCROLL_EVENT		= 522
	Local Const $MOUSE_SPECIALBUTTONDOWN_EVENT	= 523
	Local Const $MOUSE_SPECIALBUTTONUP_EVENT	= 524
	
	Local $a_vmCode_List = StringSplit($sList, "|")
	Local $sRet_Keys = ""
	
	For $i = 1 To $a_vmCode_List[0]
		Switch $a_vmCode_List[$i]
			Case "{MMOVE}"
				$a_vmCode_List[$i] = $MOUSE_MOVE_EVENT
			Case "{MPDOWN}"
				$a_vmCode_List[$i] = $MOUSE_PRIMARYDOWN_EVENT
			Case "{MPUP}"
				$a_vmCode_List[$i] = $MOUSE_PRIMARYUP_EVENT
			Case "{MSDOWN}"
				$a_vmCode_List[$i] = $MOUSE_SECONDARYDOWN_EVENT
			Case "{MSUP}"
				$a_vmCode_List[$i] = $MOUSE_SECONDARYUP_EVENT
			Case "{MWDOWN}"
				$a_vmCode_List[$i] = $MOUSE_WHEELDOWN_EVENT
			Case "{MWUP}"
				$a_vmCode_List[$i] = $MOUSE_WHEELUP_EVENT
			Case "{MWSCROLL}"
				$a_vmCode_List[$i] = $MOUSE_WHEELSCROLL_EVENT
			Case "{MSPDOWN}"
				$a_vmCode_List[$i] = $MOUSE_SPECIALBUTTONDOWN_EVENT
			Case "{MSPUP}"
				$a_vmCode_List[$i] = $MOUSE_SPECIALBUTTONUP_EVENT
		EndSwitch
		
		$sRet_Keys &= $a_vmCode_List[$i] & "|"
	Next
	
	Return StringRegExpReplace($sRet_Keys, "\|+$", "")
EndFunc

Func __BlockInputEx_KeyStr_To_vkCode($sKeyStr)
	Local $sRet_Keys = "", $aDelim_Keys[1]
	Local $aKeys = StringSplit("{LMouse}|{RMouse}|{}|(MMouse}|{}|{}|{}|{BACKSPACE}|{TAB}|{}|{}|{}|{ENTER}|{}|{}|{SHIFT}|{CTRL}|{ALT}|{PAUSE}|{CAPSLOCK}|{}|{}|{}|{}|{}|{}|{ESC}|{}|{}|{}|{]|{SPACE}|{PGUP}|{PGDN}|{END}|{HOME}|{LEFT}|{UP}|{RIGHT}|{DOWN}|{SELECT}|{PRINTSCREEN}|{}|{PRINTSCREEN}|{INSERT}|{DEL}|{}|0|1|2|3|4|5|6|7|8|9|{}|{}|{}|{}|{}|{}|{}|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|{LWIN}|{RWIN}|{APPSKEY}|{}|{SLEEP}|{numpad0}|{numpad1}|{numpad2}|{numpad3}|{numpad4}|{numpad5}|{numpad6}|{numpad7}|{numpad8}|{numpad9}|{NUMPADMULT}|{NUMPADADD}|{}|{NUMPADSUB}|{NUMPADDOT}|{NUMPADDIV}|{F1}|{F2}|{F3}|{F4}|{F5}|{F6}|{F7}|{F8}|{F9}|{F10}|{F11}|{F12}|{F13}|{F14}|{F15}|{F16}|{F17}|{F18}|{F19}|{F20}|{F21}|{F22}|{F23}|{F24}|{}|{}|{}|{}|{}|{}|{}|{}|{NUMLOCK}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{LSHIFT}|{RSHIFT}|{LCTRL}|{RCTRL}|{LALT}|{RALT}|{BROWSER_BACK}|{BROWSER_FORWARD}|{BROWSER_REFRESH}|{BROWSER_STOP}|{BROWSER_SEARCH}|{BROWSER_FAVORITES}|{BROWSER_HOME}|{VOLUME_MUTE}|{VOLUME_DOWN}|{VOLUME_UP}|{MEDIA_NEXT}|{MEDIA_PREV}|{MEDIA_STOP}|{MEDIA_PLAY_PAUSE}|{LAUNCH_MAIL}|{LAUNCH_MEDIA}|{LAUNCH_APP1}|{LAUNCH_APP2}|{}|{}|;|{+}|,|{-}|.|/|`|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|{}|[|\|]|'", "|")
	
	If StringRegExp($sKeyStr, "\A\[|\]\z") Then
		$sKeyStr = StringRegExpReplace($sKeyStr, "\A\[|\]\z", "")
		$sKeyStr = StringRegExpReplace($sKeyStr, "(.)", "\1|")
		$sKeyStr = StringRegExpReplace($sKeyStr, "\|+$", "")
		
		$aDelim_Keys = StringSplit($sKeyStr, "")
	EndIf
	
	For $i = 1 To $aKeys[0]
		If $aDelim_Keys[0] > 1 Then
			For $j = 1 To $aDelim_Keys[0]
				If $aKeys[$i] = $aDelim_Keys[$j] Then $sRet_Keys &= "0x" & Hex($i, 2) & "|"
			Next
		Else
			If $aKeys[$i] = $sKeyStr Then Return "0x" & Hex($i, 2)
		EndIf
	Next
	
	If $sRet_Keys = "" Then Return $sKeyStr
	Return StringRegExpReplace($sRet_Keys, "\|+$", "")
EndFunc

Func __BlockInputEx_WinGetHovered()
	Local $iOld_Opt_MCM = Opt("MouseCoordMode", 1)
	Local $aRet = DllCall("user32.dll", "int", "WindowFromPoint", "long", MouseGetPos(0), "long", MouseGetPos(1))
	Opt("MouseCoordMode", $iOld_Opt_MCM)
	
	If $i_MouseHookGetAncestorHwnd Then
		$aRet = DllCall("User32.dll", "hwnd", "GetAncestor", "hwnd", $aRet[0], "uint", 2) ;$GA_ROOT
	EndIf
	
	Return HWnd($aRet[0])
EndFunc

;Called when script exits to release resources.
Func __BlockInputEx_OnAutoItExit()
	_BlockInputEx(0)
EndFunc

#EndRegion Internal Functions
