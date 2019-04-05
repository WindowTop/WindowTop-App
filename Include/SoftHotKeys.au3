#include 'RegisterKeyBoardFuncEvent.au3'

#Region LowLevel
	Func SoftHotKeys_Code2Name($KeyCode)
		; https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx

		Switch StringUpper($KeyCode)
			Case 0x30
				Return '0'
			Case 0x31
				Return '1'
			Case 0x32
				Return '2'
			Case 0x33
				Return '3'
			Case 0x34
				Return '4'
			Case 0x35
				Return '5'
			Case 0x36
				Return '6'
			Case 0x37
				Return '7'
			Case 0x38
				Return '8'
			Case 0x39
				Return '9'
			Case 0x41
				Return 'A'
			Case 0x42
				Return 'B'
			Case 0x43
				Return 'C'
			Case 0x44
				Return 'D'
			Case 0x45
				Return 'E'
			Case 0x46
				Return 'F'
			Case 0x47
				Return 'G'
			Case 0x48
				Return 'H'
			Case 0x49
				Return 'I'
			Case 0x4A
				Return 'J'
			Case 0x4B
				Return 'K'
			Case 0x4C
				Return 'L'
			Case 0x4D
				Return 'M'
			Case 0x4E
				Return 'N'
			Case 0x4F
				Return 'O'
			Case 0x50
				Return 'P'
			Case 0x51
				Return 'Q'
			Case 0x52
				Return 'R'
			Case 0x53
				Return 'S'
			Case 0x54
				Return 'T'
			Case 0x55
				Return 'U'
			Case 0x56
				Return 'V'
			Case 0x57
				Return 'W'
			Case 0x58
				Return 'X'
			Case 0x59
				Return 'Y'
			Case 0x5A
				Return 'Z'

			Case 0x5B, 0x5C
				Return 'WIN'

			Case 0x5D
				Return 'APPS'
			Case 0x60
				Return 'NUM-0'
			Case 0x61
				Return 'NUM-1'
			Case 0x62
				Return 'NUM-2'
			Case 0x63
				Return 'NUM-3'
			Case 0x64
				Return 'NUM-4'
			Case 0x65
				Return 'NUM-5'
			Case 0x66
				Return 'NUM-6'
			Case 0x67
				Return 'NUM-7'
			Case 0x68
				Return 'NUM-8'
			Case 0x69
				Return 'NUM-9'
			Case 0x6A
				Return '*'
			Case 0x6B , 0xBB
				Return '+'
			Case 0xBC
				Return ','
			Case 0x6C
				Return 'SEPARATOR'
			Case 0x6D, 0xBD
				Return '-'
			Case 0x6E, 0xBE
				Return '.'
			Case 0x6F
				Return '/'
			Case 0x70
				Return 'F1'
			Case 0x71
				Return 'F2'
			Case 0x72
				Return 'F3'
			Case 0x73
				Return 'F4'
			Case 0x74
				Return 'F5'
			Case 0x75
				Return 'F6'
			Case 0x76
				Return 'F7'
			Case 0x77
				Return 'F8'
			Case 0x78
				Return 'F9'
			Case 0x79
				Return 'F10'
			Case 0x7A
				Return 'F11'
			Case 0x7B
				Return 'F12'
			Case 0x7C
				Return 'F13'
			Case 0x7D
				Return 'F14'
			Case 0x7E
				Return 'F15'
			Case 0x7F
				Return 'F16'
			Case 0x80
				Return 'F17'
			Case 0x81
				Return 'F18'
			Case 0x82
				Return 'F19'
			Case 0x83
				Return 'F20'
			Case 0x84
				Return 'F21'
			Case 0x85
				Return 'F22'
			Case 0x86
				Return 'F23'
			Case 0x87
				Return 'F24'

			Case 0xA0, 0xA1
				Return 'SHIFT'
			Case 0xA2, 0xA3
				Return 'CONTROL'
			Case 0xA4, 0xA5
				Return 'ALT'

;~ 			Case 0xA4
;~ 				Return 'L-MENU'
;~ 			Case 0xA5
;~ 				Return 'R-MENU'

			Case $MOD_ALT
				Return 'ALT'
			Case $MOD_CONTROL
				Return 'CTRL'
			Case $MOD_SHIFT
				Return 'SHIFT'
			Case $MOD_NOREPEAT
				Return 'NOREPEAT'
			Case $MOD_WIN
				Return 'WIN'

			Case 0x20
				Return 'SPACE'


			Case Else
				Return SetError(1,0,'<?>')

		EndSwitch


	EndFunc



	Func SoftHotKeys_Name2Code($KeyName)
		; https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx
		Switch $KeyName
			Case '0'
				Return 0x30
			Case '1'
				Return 0x31
			Case '2'
				Return 0x32
			Case '3'
				Return 0x33
			Case '4'
				Return 0x34
			Case '5'
				Return 0x35
			Case '6'
				Return 0x36
			Case '7'
				Return 0x37
			Case '8'
				Return 0x38
			Case '9'
				Return 0x39
			Case 'A'
				Return 0x41
			Case 'B'
				Return 0x42
			Case 'C'
				Return 0x43
			Case 'D'
				Return 0x44
			Case 'E'
				Return 0x45
			Case 'F'
				Return 0x46
			Case 'G'
				Return 0x47
			Case 'H'
				Return 0x48
			Case 'I'
				Return 0x49
			Case 'J'
				Return 0x4A
			Case 'K'
				Return 0x4B
			Case 'L'
				Return 0x4C
			Case 'M'
				Return 0x4D
			Case 'N'
				Return 0x4E
			Case 'O'
				Return 0x4F
			Case 'P'
				Return 0x50
			Case 'Q'
				Return 0x51
			Case 'R'
				Return 0x52
			Case 'S'
				Return 0x53
			Case 'T'
				Return 0x54
			Case 'U'
				Return 0x55
			Case 'V'
				Return 0x56
			Case 'W'
				Return 0x57
			Case 'X'
				Return 0x58
			Case 'Y'
				Return 0x59
			Case 'Z'
				Return 0x5A


			Case 'F1'
				Return 0x70
			Case 'F2'
				Return 0x71
			Case 'F3'
				Return 0x72
			Case 'F4'
				Return 0x73
			Case 'F5'
				Return 0x74
			Case 'F6'
				Return 0x75
			Case 'F7'
				Return 0x76
			Case 'F8'
				Return 0x77
			Case 'F9'
				Return 0x78
			Case 'F10'
				Return 0x79
			Case 'F11'
				Return 0x7A
			Case 'F12'
				Return 0x7B
			Case 'F13'
				Return 0x7C
			Case 'F14'
				Return 0x7D
			Case 'F15'
				Return 0x7E
			Case 'F16'
				Return 0x7F
			Case 'F17'
				Return 0x80
			Case 'F18'
				Return 0x81
			Case 'F19'
				Return 0x82
			Case 'F20'
				Return 0x83
			Case 'F21'
				Return 0x84
			Case 'F22'
				Return 0x85
			Case 'F23'
				Return 0x86
			Case 'F24'
				Return 0x87

			Case 'L-SHIFT'
				Return 0xA0
			Case 'R-SHIFT'
				Return 0xA1
			Case 'L-CONTROL'
				Return 0xA2
			Case 'R-CONTROL'
				Return 0xA3
			Case 'L-MENU'
				Return 0xA4
			Case 'R-MENU'
				Return 0xA5


			Case Else
				Return '<??>'

		EndSwitch


	EndFunc




#EndRegion


#Region Load and Unload
	Func SoftHotKeys_LoadKey_FromIni(ByRef $aHotKeyData, $sKeyName,$sDefault = '')
		; Read the key data from the ini file
			$tmp = GetSet('HotKeys',$sKeyName,$sDefault)


		If $tmp = 'none' Then
			$aHotKeyData[$SoftHotKeys_idx_key] = -1
			Return
		EndIf


		$tmp = StringSplit($tmp,',',1)




		; Assign the key value
			$aHotKeyData[$SoftHotKeys_idx_key] = $tmp[1]


		; Assign the combination

			If $tmp[0] > 1 Then



				_ArrayDelete($tmp,1)
				$tmp[0] -= 1
				$aHotKeyData[$SoftHotKeys_idx_aComb] = $tmp

				For $a = 1 To $tmp[0]
					$aHotKeyData[$SoftHotKeys_idx_aCombSum] += $tmp[$a]
				Next

			EndIf

	EndFunc

	Func SoftHotKeys_SaveKey_ToIni(ByRef $aHotKeyData, $sKeyName)
		If $aHotKeyData[$SoftHotKeys_idx_key] <= 0 Then
			IniWrite($ini,'HotKeys',$sKeyName,'none')
			Return
		EndIf

		Local $sIniSave = $aHotKeyData[$SoftHotKeys_idx_key]
		If IsArray($aHotKeyData[$SoftHotKeys_idx_aComb]) And ($aHotKeyData[$SoftHotKeys_idx_aComb])[0] Then $sIniSave &= ','&_ArrayToString($aHotKeyData[$SoftHotKeys_idx_aComb],',',1)
		IniWrite($ini,'HotKeys',$sKeyName,$sIniSave)

	EndFunc
	Func SoftHotKeys_UnLoadKey(ByRef $aHotKeyData)
		ReDim $aHotKeyData[0]
		ReDim $aHotKeyData[$SoftHotKeys_idxmax]
	EndFunc
#EndRegion


#Region Register
	Func SoftHotKeys_RegisterKey(ByRef $aHotKeyData)

		Return _WinAPI_RegisterHotKey($SoftHotKeys_hGUI, $aHotKeyData[$SoftHotKeys_idx_id], $aHotKeyData[$SoftHotKeys_idx_aCombSum], $aHotKeyData[$SoftHotKeys_idx_key])
	EndFunc



	Func SoftHotKeys_WM_HOTKEY($hWnd, $iMsg, $wParam, $lParam) ; _ProcessHotKeys
		#forceref $hWnd, $iMsg, $wParam


		Local $Key = _WinAPI_HiWord($lParam)
		Local $KeyComb = _WinAPI_LoWord($lParam)


		If $TClickThroughAnyOpcWin_aSKey[$SoftHotKeys_idx_key] <> -1 And $Key = $TClickThroughAnyOpcWin_aSKey[$SoftHotKeys_idx_key] And $KeyComb = $TClickThroughAnyOpcWin_aSKey[$SoftHotKeys_idx_aCombSum] Then ToggleClickThrough_OpacityWins()

		If $SetWindowOpc_aSKey[$SoftHotKeys_idx_key] <> -1 And $Key = $SetWindowOpc_aSKey[$SoftHotKeys_idx_key] And $KeyComb = $SetWindowOpc_aSKey[$SoftHotKeys_idx_aCombSum] Then ToggleOpacityForActiveWin()

		If $SetWindowTop_aSKey[$SoftHotKeys_idx_key] <> -1 And $Key = $SetWindowTop_aSKey[$SoftHotKeys_idx_key] And $KeyComb = $SetWindowTop_aSKey[$SoftHotKeys_idx_aCombSum] Then ToggleTopForActiveWin()

		If $TShrink_aSKey[$SoftHotKeys_idx_key] <> -1 And $Key = $TShrink_aSKey[$SoftHotKeys_idx_key] And $KeyComb = $TShrink_aSKey[$SoftHotKeys_idx_aCombSum] Then ToggleShrinkWin()


	EndFunc   ;==>WM_HOTKEY

#EndRegion


#Region Common for GUI and tray

	Func SoftHotKeys_GetKeyShortcutString(ByRef $aKeyData)
		If Not $aKeyData[$SoftHotKeys_idx_key] Then Return SetError(1)

		Local $sKeyShortcut

		$tmp = $aKeyData[$SoftHotKeys_idx_aComb]
		If IsArray($tmp) Then
			For $a = 1 To $tmp[0]
				$sKeyShortcut &= SoftHotKeys_Code2Name($tmp[$a])
				$sKeyShortcut &= ' + '
			Next
		EndIf

		$sKeyShortcut &= SoftHotKeys_Code2Name($aKeyData[$SoftHotKeys_idx_key])

		Return $sKeyShortcut
	EndFunc

#EndRegion


#Region Set key GUI
	Func SoftHotKeys_SetKeyGUI($bStart = False, $aKeyData = Default)
		Local Static $OK_Button, $Cancel_Button, $RemoveKey_Button, $Ctrl_Checkbox, $Alt_Checkbox, $Shift_Checkbox, $Win_Checkbox

		If $bStart Then

			Local $sTitle

			Switch $aKeyData[$SoftHotKeys_idx_id]
				Case $SoftHotKeys_IdFor_TClickThroughAnyOpcWin
					$sTitle = 'Click Through transparent wins'
				Case $SoftHotKeys_IdFor_SetWindowTop
					$sTitle = 'Set Top'

				Case $SoftHotKeys_IdFor_SetWindowOpc
					$sTitle = 'Set Opacity'
			EndSwitch

			$SoftHotKeys_SetKeyGUI_hGUI = GUICreate($sTitle, 303, 98)
			GUICtrlCreateLabel("Enter the desired keyboard shortcut", 8, 10, 182, 17)

			If $aKeyData[$SoftHotKeys_idx_key] <> -1 Then
				$tmp = SoftHotKeys_Code2Name($aKeyData[$SoftHotKeys_idx_key])
			Else
				$tmp = 'none'
			EndIf

			$SoftHotKeys_SetKeyGUI_Input = GUICtrlCreateInput($tmp, 188, 8, 97, 21, BitOR($GUI_SS_DEFAULT_INPUT,$ES_READONLY))
			GUICtrlSetBkColor(-1,0xffffff)
			$OK_Button = GUICtrlCreateButton("OK", 42, 62, 76, 25)
			$Cancel_Button = GUICtrlCreateButton("Cancel", 207, 62, 76, 25)
			$RemoveKey_Button = GUICtrlCreateButton("Remove Key", 124, 62, 76, 25)


			$Ctrl_Checkbox = GUICtrlCreateCheckbox("CTRL", 28, 34, 54, 17)
			$Alt_Checkbox = GUICtrlCreateCheckbox("ALT", 89, 34, 49, 17)
			$Shift_Checkbox = GUICtrlCreateCheckbox("SHIFT", 149, 34, 54, 17)
			$Win_Checkbox = GUICtrlCreateCheckbox("WIN", 213, 34, 62, 17)

			If IsArray($aKeyData[$SoftHotKeys_idx_aComb]) Then
				For $a = 1 To ($aKeyData[$SoftHotKeys_idx_aComb])[0]
					Switch ($aKeyData[$SoftHotKeys_idx_aComb])[$a]
						Case $MOD_ALT
							GUICtrlSetState($Alt_Checkbox,$GUI_CHECKED)
						Case $MOD_CONTROL
							GUICtrlSetState($Ctrl_Checkbox,$GUI_CHECKED)

						Case $MOD_SHIFT
							GUICtrlSetState($Shift_Checkbox,$GUI_CHECKED)
						Case $MOD_WIN
							GUICtrlSetState($Win_Checkbox,$GUI_CHECKED)
					EndSwitch
				Next
			EndIf




			GUISetState()

			$SoftHotKeys_SetKeyGUI_aKeyData = $aKeyData
			$timer = TimerInit()
			RegisterKeyBoardFuncEvent_Register(SoftHotKeys_SetKeyGUI_KeyBoardHookProc)
			aExtraFuncCalls_AddFunc(SoftHotKeys_SetKeyGUI)

			Tray_HotKeys_ItemsSetState($TRAY_DISABLE)

			Return
		EndIf


		If $Software_MSG[1] <> $SoftHotKeys_SetKeyGUI_hGUI Then Return

		Switch $Software_MSG[0]

			Case $Ctrl_Checkbox, $Alt_Checkbox, $Shift_Checkbox, $Win_Checkbox

				Switch $Software_MSG[0]
					Case $Ctrl_Checkbox
						$tmp = $MOD_CONTROL
					Case $Alt_Checkbox
						$tmp = $MOD_ALT
					Case $Shift_Checkbox
						$tmp = $MOD_SHIFT
					Case $Win_Checkbox
						$tmp = $MOD_WIN
				EndSwitch

				$aTmp = $SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_aComb]

				$tmp2 = _ArraySearch($aTmp,$tmp,1)
				If $tmp2 < 0 Then
					_ArrayAdd($aTmp,$tmp)
					$aTmp[0] += 1
					$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_aCombSum] += $tmp
				Else
					_ArrayDelete($aTmp,$tmp2)
					$aTmp[0] -= 1
					$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_aCombSum] -= $tmp
				EndIf

				$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_aComb] = $aTmp


			Case $RemoveKey_Button

				$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_key] = -1
				$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_aCombSum] = 0
				Local $aTmp[1]
				$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_aComb] = $aTmp
				ContinueCase
			Case $OK_Button


				_WinAPI_UnregisterHotKey($SoftHotKeys_hGUI,$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_id])
				If $SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_key] <> -1 Then _WinAPI_RegisterHotKey($SoftHotKeys_hGUI,$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_id], $SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_aCombSum], $SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_key])



				Switch $SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_id]
					Case $SoftHotKeys_IdFor_TClickThroughAnyOpcWin
						$TClickThroughAnyOpcWin_aSKey = $SoftHotKeys_SetKeyGUI_aKeyData
						SoftHotKeys_SaveKey_ToIni($SoftHotKeys_SetKeyGUI_aKeyData, 'CThrTransWins')
						Tray_HotKeys_TClickThroughForAllTransWins_SetText()

					Case $SoftHotKeys_IdFor_SetWindowTop
						$SetWindowTop_aSKey = $SoftHotKeys_SetKeyGUI_aKeyData
						SoftHotKeys_SaveKey_ToIni($SoftHotKeys_SetKeyGUI_aKeyData, 'Top')
						Tray_HotKeys_TSetTop_SetText()

					Case $SoftHotKeys_IdFor_SetWindowOpc
						$SetWindowOpc_aSKey = $SoftHotKeys_SetKeyGUI_aKeyData
						SoftHotKeys_SaveKey_ToIni($SoftHotKeys_SetKeyGUI_aKeyData, 'Opacity')
						Tray_HotKeys_SetWindowOpacity_SetText()

					Case $SoftHotKeys_IdFor_TShrink
						$TShrink_aSKey = $SoftHotKeys_SetKeyGUI_aKeyData
						SoftHotKeys_SaveKey_ToIni($SoftHotKeys_SetKeyGUI_aKeyData, 'Shrink')
						Tray_HotKeys_TShrink_SetText()

				EndSwitch

				ContinueCase
			Case $GUI_EVENT_CLOSE, $Cancel_Button
				RegisterKeyBoardFuncEvent_UnRegister()
				GUIDelete($SoftHotKeys_SetKeyGUI_hGUI)
				Tray_HotKeys_ItemsSetState($TRAY_ENABLE)
				Return True

		EndSwitch




	EndFunc




	Func SoftHotKeys_SetKeyGUI_KeyBoardHookProc($nCode, $wParam, $lParam)

		If Not WinActive($SoftHotKeys_SetKeyGUI_hGUI) Then Return RegisterKeyBoardFuncEvent_Continue($nCode, $wParam, $lParam)

		Local $KBDLLHOOKSTRUCT = DllStructCreate("dword vkCode;dword scanCode;dword flags;dword time;ptr dwExtraInfo", $lParam)
		;Local $iFlags = DllStructGetData($KBDLLHOOKSTRUCT, "flags")
		Local $iDec_vkCode = DllStructGetData($KBDLLHOOKSTRUCT, "vkCode")

		Local $vkCode = "0x" & Hex($iDec_vkCode, 2)

		Switch $vkCode

			Case 0x5B, 0x5C, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, $MOD_WIN ; = WIN / SHIFT / CTRL / ALT
				; Do nothing
			Case Else

				Local $tmp = SoftHotKeys_Code2Name($vkCode)
				$SoftHotKeys_SetKeyGUI_aKeyData[$SoftHotKeys_idx_key] = $vkCode
				GUICtrlSetData($SoftHotKeys_SetKeyGUI_Input,$tmp)
		EndSwitch

		Return RegisterKeyBoardFuncEvent_Continue($nCode, $wParam, $lParam) ;Continue processing
	EndFunc

#EndRegion







