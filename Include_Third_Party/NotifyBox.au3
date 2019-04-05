#Region Header

#cs

    Title:          Management of Message Boxes UDF Library for AutoIt3
    Filename:       NotifyBox.au3
    Description:    Creates a message boxes without pausing a script
    Author:         Yashied
    Version:        1.1
    Requirements:   AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
    Uses:           None
    Notes:          -

                    http://www.autoitscript.com/forum/index.php?showtopic=121609

    Available functions:

    _NotifyBox

    Example:

        #Include "NotifyBox.au3"

        Opt('TrayAutoPause', 0)

        While 1
            _NotifyBox(16, ':-(', 'One.', 2)
            Sleep(500)
            _NotifyBox(48, ':-|', 'Two.', 2)
            Sleep(500)
            _NotifyBox(64, ':-)', 'Three.', 2)
            Sleep(3000)
        WEnd

#ce

#Include-once

#EndRegion Header

#Region Local Variables and Constants

Dim $__nbId[1][4] = [[0, 1, 0, 0]]

#cs

DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$__nbId[0][0] - Number of items in array
       [0][1] - Timer control flag
       [0][2] - Handle to the DLL callback function
       [0][3] - Timer identifier

$__nbId[i][0] - Handle to the message box window
       [i][1] - Timeout, in milliseconds
       [i][2] - TimerInit()
       [i][3] - Reserved

#ce

#EndRegion Local Variables and Constants

#Region Initialization

OnAutoItExitRegister('__NB_AutoItExit')

#EndRegion Initialization

#Region Public Functions

; #FUNCTION# ====================================================================================================================
; Name...........: _NotifyBox
; Description....: Creates, displays, and operates a message box.
; Syntax.........: _NotifyBox ( $iFlags, $sTitle, $sText [, $iTimeOut [, $hParent [, $hInstance [, $iIcon]]]] )
; Parameters.....: $iFlags    - The flag indicates the type of message box and the possible button combinations (see MsgBox()).
;                  $sTitle    - The title of the message box.
;                  $sText     - The text of the message box.
;                  $iTimeOut  - Timeout in seconds. After the timeout has elapsed the message box will be automatically closed.
;                               The default is 0, which is no timeout.
;                  $hParent   - The window handle to use as the parent for this dialog.
;                  $hInstance - Handle to the module that contains the icon resource identified by the $iIcon parameter.
;                               If this parameter is 0, a handle of the file used to create the calling process.
;                  $iIcon     - Identifies an icon resource. $iIcon can be either a string or an integer resource identifier.
;                               $iIcon is ignored if the $iFlags parameter does not specify the MB_USERICON (128) flag.
; Return values..: Success    - Handle to the created message box.
;                  Failure    - 0.
; Author.........: Yashied
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================

Func _NotifyBox($iFlags, $sTitle, $sText, $iTimeOut = 0, $hParent = 0, $hInstance = 0, $iIcon = 0)

	Local $Opt = Opt('WinTitleMatchMode', 3)
	Local $tMBP = DllStructCreate('uint Size;hwnd hOwner;ptr hInstance;ptr Text;ptr Caption;dword Style;ptr Icon;dword_ptr ContextHelpId;ptr MsgBoxCallback;dword LanguageId')
	Local $tTitle = DllStructCreate('wchar[' & (StringLen($sTitle) + 1) & ']')
	Local $tText = DllStructCreate('wchar[' & (StringLen($sText) + 1) & ']')
	Local $aList1, $aList2 = WinList($sTitle)
	Local $tIcon, $hWnd = 0, $Error = 0
	Local $Ret

	If ($iIcon) And (BitAND($iFlags, 0x80)) Then
		If Not IsString($iIcon) Then
			$iIcon = '#' & $iIcon
		EndIf
		$tIcon = DllStructCreate('wchar[' & (StringLen($iIcon) + 1) & ']')
		If Not $hInstance Then
			$Ret = DllCall('kernel32.dll', 'ptr', 'GetModuleHandleW', 'ptr', 0)
			If Not @error Then
				$hInstance = $Ret[0]
			EndIf
		EndIf
	Else
		$tIcon = 0
	EndIf

	DllStructSetData($tTitle, 1, $sTitle)
	DllStructSetData($tText, 1, $sText)
	DllStructSetData($tIcon, 1, $iIcon)
	DllStructSetData($tMBP, 'Size', DllStructGetSize($tMBP))
	DllStructSetData($tMBP, 'hOwner', $hParent)
	DllStructSetData($tMBP, 'hInstance', $hInstance)
	DllStructSetData($tMBP, 'Text', DllStructGetPtr($tText))
	DllStructSetData($tMBP, 'Caption', DllStructGetPtr($tTitle))
	DllStructSetData($tMBP, 'Style', BitAND($iFlags, 0xFFFFBFF8))
	DllStructSetData($tMBP, 'Icon', DllStructGetPtr($tIcon))
	DllStructSetData($tMBP, 'ContextHelpId', 0)
	DllStructSetData($tMBP, 'MsgBoxCallback', 0)
	DllStructSetData($tMBP, 'LanguageId', 0)

	Do
		$Ret = DllCall('kernel32.dll', 'ptr', 'GetModuleHandleW', 'wstr', 'user32.dll')
		If (@error) Or (Not $Ret[0]) Then
			ExitLoop
		EndIf
		$Ret = DllCall('kernel32.dll', 'ptr', 'GetProcAddress', 'ptr', $Ret[0], 'str', 'MessageBoxIndirectW')
		If (@error) Or (Not $Ret[0]) Then
			ExitLoop
		EndIf
		$Ret = DllCall('kernel32.dll', 'ptr', 'CreateThread', 'ptr', 0, 'dword_ptr', 0, 'ptr', $Ret[0], 'ptr', DllStructGetPtr($tMBP), 'dword', 0, 'dword*', 0)
		If (@error) Or (Not $Ret[0]) Then
			ExitLoop
		EndIf
		While 1
			Sleep(10)
			$aList1 = WinList($sTitle)
			For $i = 1 To $aList1[0][0]
				For $j = 1 To $aList2[0][0]
					If $aList1[$i][1] = $aList2[$j][1] Then
						ContinueLoop 2
					EndIf
				Next
				$hWnd = $aList1[$i][1]
				ExitLoop 2
			Next
		WEnd
	Until 1
	Opt('WinTitleMatchMode', $Opt)
	If Not $hWnd Then
		Return SetError(1, 0, 0)
	EndIf
	If $iTimeOut Then
		$__nbId[0][1] += 1
		$__nbId[0][0] += 1
		ReDim $__nbId[$__nbId[0][0] + 1][4]
		$__nbId[$__nbId[0][0]][0] = $hWnd
		$__nbId[$__nbId[0][0]][1] = 1000 * $iTimeOut
		$__nbId[$__nbId[0][0]][2] = TimerInit()
		$__nbId[$__nbId[0][0]][3] = 0
		If Not $__nbId[0][3] Then
			$__nbId[0][2] = DllCallbackRegister('__NB_TimerProc', 'none', '')
			$Ret = DllCall('user32.dll', 'uint_ptr', 'SetTimer', 'hwnd', 0, 'uint_ptr', 0, 'uint', 200, 'ptr', DllCallBackGetPtr($__nbId[0][2]))
			If (@error) Or (Not $Ret[0]) Then
				DllCallbackFree($__nbId[0][2])
				$Error = 1
			Else
				$__nbId[0][3] = $Ret[0]
				$__nbId[0][1] -= 1
			EndIf
		EndIf
		$__nbId[0][1] -= 1
	EndIf
	Return SetError($Error, 0, $hWnd)
EndFunc   ;==>_NotifyBox

#EndRegion Public Functions

#Region Windows DLL Functions

Func __NB_TimerProc()

	If $__nbId[0][1] Then
		Return
	EndIf

	$__nbId[0][1] += 1

	Local $Ret, $Start = 1

	While 1
		For $i = $Start To $__nbId[0][0]
			If TimerDiff($__nbId[$i][2]) >= $__nbId[$i][1] Then
				If WinExists($__nbId[$i][0]) Then
					DllCall('user32.dll', 'lresult', 'SendMessage', 'hwnd', $__nbId[$i][0], 'uint', 0x0010, 'wparam', 0, 'lparam', 0)
				EndIf
				$Start = $i
				For $j = $i To $__nbId[0][0] - 1
					For $k = 0 To 3
						$__nbId[$j][$k] = $__nbId[$j + 1][$k]
					Next
				Next
				ReDim $__nbId[$__nbId[0][0]][4]
				$__nbId[0][0] -= 1
				If Not $__nbId[0][0] Then
					$Ret = DllCall('user32.dll', 'int', 'KillTimer', 'hwnd', 0, 'uint_ptr', $__nbId[0][3])
					If (Not @error) And ($Ret[0]) Then
						$__nbId[0][3] = 0
						DllCallbackFree($__nbId[0][2])
						Return
					EndIf

				EndIf
				ContinueLoop 2
			EndIf
		Next
		ExitLoop
	WEnd

	$__nbId[0][1] -= 1

EndFunc   ;==>__NB_TimerProc

#EndRegion Windows DLL Functions

#Region AutoIt Exit Functions

Func __NB_AutoItExit()
	$__nbId[0][1] += 1
	If $__nbId[0][3] Then
		DllCall('user32.dll', 'int', 'KillTimer', 'hwnd', 0, 'uint_ptr', $__nbId[0][3])
		DllCallbackFree($__nbId[0][2])
	EndIf
EndFunc   ;==>__NB_AutoItExit

#EndRegion AutoIt Exit Functions
