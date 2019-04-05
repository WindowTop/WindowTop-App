


Func ProFe_DisableEnableAll($iState)
	ProFe_EnableDisableDarkMode($iState)
	ProFe_EnableDisableSmartAero($iState)

	If $iState Then
		Tray_AllProFeaturesSetState($TRAY_ENABLE)
	Else
		Tray_AllProFeaturesSetState($TRAY_DISABLE)
	EndIf
EndFunc




Func ProFe_EnableDisableDarkMode($bEnable)

	If Not $bIsInstalled Then Return


	Local $aDarkModeIdxs[1]
	For $a = 1 To $aWins[0][0]
		If Not $aWins[$a][$C_aWins_idx_hMask_hMag_active] Then ContinueLoop
		aWins_ToggleColorEffect($a,0)
		_ArrayAdd($aDarkModeIdxs,$a)
		$aDarkModeIdxs[0] += 1
	Next

	$ProFe_bDarkMode = $bEnable

	For $a = 1 To $aDarkModeIdxs[0]
		If $aWins[$aDarkModeIdxs[$a]][$C_aWins_idx_Shrink_hGUI] Then ContinueLoop
		$tmp = WinGetState($aWins[$aDarkModeIdxs[$a]][$C_aWins_idx_hWin])
		If Not BitAND($tmp, $WIN_STATE_VISIBLE) Or BitAND($tmp, $WIN_STATE_MINIMIZED) Then ContinueLoop

		aWins_ToggleColorEffect($aDarkModeIdxs[$a],1)
		If $ProFe_bDarkMode Then Sleep(1000)
	Next

	IniWrite($ini,'ProFeatures','DarkMode',$bEnable)

	;ConsoleWrite($C_aWins_idx_hMask_hMag & @CRLF)

EndFunc


Func ProFe_EnableDisableSmartAero($bEnable)
	If @OSVersion <> 'WIN_10' Then Return
	If Not $bIsInstalled Then Return

	; נגדיר את מצב ההפעלה של פיצ'ר השקיפות
	$ProFe_bSmartAero = $bEnable

	If Not $bEnable Then
		For $a = 1 To $aWins[0][0]
			If $aWins[$a][$C_aWins_idx_aeroactive] Then aWins_SmartAero_OnOff($a,False)
		Next
	EndIf


	IniWrite($ini,'ProFeatures','SmartAero',$bEnable)
EndFunc



Func ProFe_GUI_SavedWindowList()
	$hGUI = GUICreate("Saved windows settings", 410, 660)
	$Programs_List = GUICtrlCreateList("", 11, 37, 385, 318)
	GUICtrlCreateLabel("Select a program:", 11, 10, 149, 23)
	GUICtrlSetFont(-1, 12, 800, 0, "Tahoma")
	$ForgetSettings_Button = GUICtrlCreateButton("Forget settings", 11, 363, 121, 25)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	$DarkMode_Checkbox = GUICtrlCreateCheckbox("Dark Mode", 32, 435, 107, 17)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	$Opacity_Checkbox = GUICtrlCreateCheckbox("Opacity", 32, 457, 97, 17)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	$SetTop_Checkbox = GUICtrlCreateCheckbox("Set Top", 32, 510, 97, 17)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	$ArrowPos_Checkbox = GUICtrlCreateCheckbox("Arrow position", 32, 533, 130, 17)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	$ArrowPos_Slider = GUICtrlCreateSlider(238, 560, 131, 21)
	$OpacityLevel_Slider = GUICtrlCreateSlider(238, 483, 131, 21)
	GUICtrlCreateLabel("Select (check) settings to save for the selected window", 11, 398, 388, 23)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	$Done_Button = GUICtrlCreateButton("Done", 139, 603, 130, 43)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	GUICtrlCreateLabel("Set the transparency level:", 57, 484, 158, 20)
	GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
	GUICtrlCreateLabel("Set the arrow position:", 57, 560, 136, 20)
	GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
	GUISetState(@SW_SHOW)
EndFunc
