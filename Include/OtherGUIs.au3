

Func StartWithWindowsQuestion()
	If Not StringInStr(@ScriptDir,'Program Files') Then Return
	If Number(GetSet('Messages','StartWithWindowsQuestion',0)) Then Return
	If MsgBox(4,'Start with windows?','Do you want the program to start with windows?') = 6 Then _
		InstallStartup()
	IniWrite($ini,'Messages','StartWithWindowsQuestion',1)
EndFunc

Func Windows10CompatibilityWarning()
	If Not Number(GetSet('Messages','Windows10Compatibility',1)) Then Return


	Local Enum $hGUI, $NotShowAgain_Checkbox, $OK_Button, $p_max
	Local $p[$p_max]

	$p[$hGUI] = GUICreate(Null, 521, 250)
	GUICtrlCreateLabel("Please note!"&@CRLF&@CRLF&'If you use the program in windows 10, it may not work properly on modern/metro apps.'&@CRLF&@CRLF& _
	'it will still work good on any desktop program that run up to Windows 8.1', 24, 18, 456, 130)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	$p[$NotShowAgain_Checkbox] = GUICtrlCreateCheckbox("Do not show me again", 24, 160, 449, 25)
	GUICtrlSetState(-1,$GUI_CHECKED)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	$p[$OK_Button] = GUICtrlCreateButton("OK", 184, 192, 153, 41)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
	;WinSetOnTop($p[$hGUI],Null,1)
	GUISetState(@SW_SHOW)

	Windows10CompatibilityWarning_ProcessMsg($p)
	aExtraFuncCalls_AddFunc(Windows10CompatibilityWarning_ProcessMsg)


EndFunc

Func Windows10CompatibilityWarning_ProcessMsg($p = Default)
	Local Enum $hGUI, $NotShowAgain_Checkbox, $OK_Button, $p_max
	Local Static $ps

	If $p <> Default Then
		$ps = $p
		Return
	EndIf

	If $Software_MSG[1] <> $ps[$hGUI] Then Return

	Switch $Software_MSG[0]
		Case $ps[$OK_Button]
			If GUICtrlRead($ps[$NotShowAgain_Checkbox]) = $GUI_CHECKED Then IniWrite($ini,'Messages','Windows10Compatibility',0)

			ContinueCase
		Case $GUI_EVENT_CLOSE
			GUIDelete($ps[$hGUI])
			$ps = 0
			Return True
	EndSwitch
EndFunc



Func ChangingLog()


	If $ChangingLog_hGUI Then Return WinActivate($ChangingLog_hGUI)

	Local Enum $Close_Button, $p_max
	Local $p[$p_max]


	Local Const $C_xSize = 430 , $C_ySize = 400, $C_LowArea_xSpace = 40

	$ChangingLog_hGUI = GUICreate('Changing log',$C_xSize,$C_ySize)
	GUICtrlCreateEdit(_ResourceGetAsString('ChangingLog'),0,0,$C_xSize,$C_ySize-$C_LowArea_xSpace,BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $ES_WANTRETURN, $WS_VSCROLL, $WS_HSCROLL))
	;GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

	Local Const $C_CloseButton_xSize = 110
	$p[$Close_Button] = GUICtrlCreateButton('Close',($C_xSize-$C_CloseButton_xSize)/2,$C_ySize-$C_LowArea_xSpace+2,$C_CloseButton_xSize,$C_LowArea_xSpace-4)
	GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

	GUISetState()


	ChangingLog_ProcessMsg($p)
	aExtraFuncCalls_AddFunc(ChangingLog_ProcessMsg)

EndFunc


Func ChangingLog_ProcessMsg($p = Default)
	Local Enum $Close_Button, $p_max
	Local Static $ps

	If $p <> Default Then
		$ps = $p
		Return
	EndIf


	If $Software_MSG[1] <> $ChangingLog_hGUI Then Return


	Switch $Software_MSG[0]
		Case $ps[$Close_Button], $GUI_EVENT_CLOSE
			GUIDelete($ChangingLog_hGUI)
			$ChangingLog_hGUI = 0
			$ps = 0
			Return True
	EndSwitch

EndFunc


Func HotKeySetGUI($aStart)

	Local Static $hGUI, $HotKeyInput, $OK_Button, $Concel_Button, $FuncCall


	If IsArray($aStart) Then
		Local $bAddFunc = True
		If $hGUI Then
			GUIDelete($hGUI)
			$bAddFunc = False
		EndIf

		$hGUI = GUICreate("Hotkey Properties", 303, 98)
		$HotKeyInput = GUICtrlCreateInput("None", 11, 30, 283, 21)
		GUICtrlCreateLabel("Enter the desired keyboard shortcut:", 10, 10, 175, 17)
		$OK_Button = GUICtrlCreateButton("OK", 134, 61, 75, 25)
		$Concel_Button = GUICtrlCreateButton("Cancel", 217, 61, 75, 25)
		GUISetState(@SW_SHOW)
		If $bAddFunc Then aExtraFuncCalls_AddFunc(HotKeySetGUI)

		Return
	EndIf


	If $Software_MSG[1] <> $hGUI Then Return


	Switch $Software_MSG[0]
		Case $OK_Button

		Case $Concel_Button, $GUI_EVENT_CLOSE
			GUIDelete($hGUI)
			$hGUI = Null
			Return True



	EndSwitch

EndFunc


Func ClickTrWarning($hWindow = Null,$iOpactyType = Null)

	Local Static $hWindow_static, $hGUI, $Yes_Button, $No_Button, $NotShowAgain_Checkbox




	If $hWindow Then

		If $hGUI Then Return WinActivate($hGUI)

		$hGUI = GUICreate("Warning!", 525, 250)
		GUICtrlCreateLabel("Warning !!!", 0, 6, 523, 30, $SS_CENTER)
		GUICtrlSetFont(-1, 20, 400, 4, "Tahoma")
		GUICtrlSetColor(-1, 0xFF0000)
		GUICtrlCreateLabel("If you enable this, the current window will be unclickable!"&@CRLF& _
		'To disable it, uncheck this option.'&@CRLF&@CRLF& _
		'Are you sure you want to enable this option for the current window?', 16, 48, 503, 120)
		GUICtrlSetFont(-1, 14, 400, 0, "Tahoma")
		$Yes_Button = GUICtrlCreateButton("Yes", 104, 170, 123, 33)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
		$No_Button = GUICtrlCreateButton("No", 302, 170, 123, 33)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
		$NotShowAgain_Checkbox = GUICtrlCreateCheckbox("Do not show me this warning again", 16, 215, 497, 25)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
		WinSetOnTop($hGUI,'',1)
		GUISetState(@SW_SHOWNOACTIVATE)

		$hWindow_static = $hWindow
		aExtraFuncCalls_AddFunc(ClickTrWarning)

		Return
	EndIf



	If $Software_MSG[1] <> $hGUI Then Return


	Switch $Software_MSG[0]
		Case $Yes_Button
			Local $iIndex = _ArraySearch($aWins,$hWindow_static,1,$aWins[0][0],0,0,1,$C_aWins_idx_hWin)
			If $iIndex > 0 Then



				aWins_ToggleClickThrough($iIndex, True)

				Switch $iOpactyType
					Case 1
						If Not $aWins[$iIndex][$C_aWins_idx_opacityactive] Then aWins_Opacity_OnOff($iIndex,True)
					Case 2
						; If Not $aWins[$iIndex][$C_aWins_idx_aeroactive] Then aWins_SmartAero_OnOff($iIndex,True) REMOVED
				EndSwitch

			EndIf
			ContinueCase
		Case $No_Button
			ContinueCase
		Case $GUI_EVENT_CLOSE
			If $NotShowAgain_Checkbox <> -1 And GUICtrlRead($NotShowAgain_Checkbox) = $GUI_CHECKED Then
				IniWrite($ini,'Other','ShowCTWarning',0)
				$bShowClickTWarning = 0
			EndIf

			GUIDelete($hGUI)
			$hGUI = Null
			Return True
	EndSwitch





EndFunc


#Region ToolBar options
	Global $ToolBarOptions_aArrowPos[2], $ToolBarOptions_xStart, $ToolBarOptions_xEnd
	Func ToolBarOptions($bStart = False)

		; Vars for the loop also
			Local Static $hGUI, $hGUI_aPos,$timer1,$timer2, $ToolBar_xPos, $ToolBar_yPos, _
			$iMaxItems_Combo,$ChangeBkColor_Label , $ChangeBkColor_Button, $ChangeBkColorToDef_Button, _
			$ToolbarDynamicBkColor_Checkbox, $ApplySettings_Button, $ArrowPosition_Combo, $ArrowPosition_sComboText, _
			$ArrowPosOffSet_Input, $ArrowPosOffSet_Label, $ArrowOffSet_ShowMode

		; Save the original settings
			Local Static $Save_bRestoreSettings , $Save_Set_iMaxItems, $Save_Set_bDynamicBkColor, $Save_Set_bkcolor, _
			$Save_Set_ArrowXPosOffSet, $Save_Set_ArrowXPosMode


		; Consts
			Local Const $C_hGUI_xSize = 315, $C_hGUI_ySize = 330, $C_Arrow_yPosFix = 8, $C_Graphic_ySize = 65, _
			$C_Graphic_xPos = 15, $C_Graphic_yPos = $C_Arrow_yPosFix-1, $C_Graphic_xSize = 286

		If $bStart Then



			#Region Save the original settings
			$Save_bRestoreSettings = True
			; Save the toolbar settings
				$Save_Set_iMaxItems = $GUMe_WinOptions_iMaxItems
				$Save_Set_bDynamicBkColor = $GUMe_WinOptions_bDynamicBkColor
				$Save_Set_bkcolor = $GUMe_WinOptions_bkcolor

			; Save the arrow settings
				$Save_Set_ArrowXPosOffSet = $GUMe_xPosFix
				$Save_Set_ArrowXPosMode = $GUMe_xPos_mode

			#EndRegion

		; Disable the $Tray_ToolBarOptions item in the tray
			TrayItemSetState($Tray_ToolBarOptions,$TRAY_DISABLE)
			$GUIMenuButton_bDisableUpdatePos = True


		; Create the GUI
			$hGUI = GUICreate("Toolbar options", $C_hGUI_xSize, $C_hGUI_ySize,-1,-1,BitXOr(BitOR($WS_MINIMIZEBOX, $WS_CAPTION, $WS_POPUP, $WS_SYSMENU ), $WS_MINIMIZEBOX, $WS_MAXIMIZEBOX),$WS_EX_TOPMOST)

			#Region Create the area where the toolbar preview will be shown

				GUICtrlCreateGraphic($C_Graphic_xPos, $C_Graphic_yPos, $C_Graphic_xSize, $C_Graphic_ySize)
				GUICtrlSetBkColor(-1, 0xffffff)
				GUICtrlSetGraphic(-1, $GUI_GR_RECT, 0, 0, $C_Graphic_xSize, $C_Graphic_ySize)
			#EndRegion

			; Apply settings button
				$ApplySettings_Button = GUICtrlCreateButton('Apply settings',72,283,170)
				GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")


			#Region Create other stuff in the GUI
				_GUICtrlHyperLink_Create("www.WindowTop.info", 8, 312, 110, 15, 0x0000FF, 0x551A8B, _
				-1, 'http://windowtop.info', 'Visit: the official website of the software: www.WindowTop.info', $hGUI) ;Intentionally set as google.com, will change later
			#EndRegion

			; Create the settings inside the GUI
				GUICtrlCreateTab(4, 80, 307, 200)

				#Region Tab 1 - toolbar settings
					GUICtrlCreateTabItem("Toolbar")


					; Max buttons
						GUICtrlCreateLabel("Max buttons:", 12, 110, 96, 23)
						GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

						$iMaxItems_Combo = GUICtrlCreateCombo('', 119, 111, 46, 25, BitOr($CBS_DROPDOWNLIST, $WS_VSCROLL))
						GUICtrlSetData(-1,'1|2|3|4|5',$GUMe_WinOptions_iMaxItems)






					; Toolbar background color
						$ChangeBkColor_Label = GUICtrlCreateLabel("Toolbar background color:", 12, 166, 190, 23)
						GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
						$ChangeBkColor_Button = GUICtrlCreateButton('Change',203,165,50,23)
						$ChangeBkColorToDef_Button = GUICtrlCreateButton('Default',256,165,50,23)



					; Toolbar dynamic background color
						$ToolbarDynamicBkColor_Checkbox = GUICtrlCreateCheckbox("Toolbar dynamic background color ", 12, 135, 270, 23)
						GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
						If $GUMe_WinOptions_bDynamicBkColor Then
							GUICtrlSetState(-1,$GUI_CHECKED)
							GUICtrlSetState($ChangeBkColor_Label,$GUI_DISABLE)
							GUICtrlSetState($ChangeBkColor_Button,$GUI_DISABLE)
							GUICtrlSetState($ChangeBkColorToDef_Button,$GUI_DISABLE)
						EndIf


					; More options will be available in later versions
						GUICtrlCreateLabel('* More options will be available in later versions.',12,200,250,100)
						GUICtrlSetColor(-1,0x1e65d8)

				#EndRegion



				#Region Tab 2 - Arrow settings
					GUICtrlCreateTabItem("Arrow")

					; Arrow position

						$ArrowOffSet_ShowMode = $GUI_SHOW

						GUICtrlCreateLabel("Arrow position:", 12, 110, 115, 23)
						GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

						$ArrowPosition_Combo = GUICtrlCreateCombo('', 130, 111, 60, 25, BitOr($CBS_DROPDOWNLIST, $WS_VSCROLL))

						$ArrowPosOffSet_Label = GUICtrlCreateLabel('Offset: ',200,111,50)
						GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

						$ArrowPosOffSet_Input = GUICtrlCreateInput($GUMe_xPosFix,252,112,45,20,BitOR($GUI_SS_DEFAULT_INPUT,$ES_NUMBER))


						Switch $GUMe_xPos_mode
							Case $C_GUMe_xPos_mode_Left
								$ArrowPosition_sComboText = 'Left'
							Case $C_GUMe_xPos_mode_Right
								$ArrowPosition_sComboText = 'Right'
							Case $C_GUMe_xPos_mode_Center
								$ArrowPosition_sComboText = 'Center'
								GUICtrlSetState($ArrowPosOffSet_Label,$GUI_HIDE)
								GUICtrlSetState($ArrowPosOffSet_Input,$GUI_HIDE)
								$ArrowOffSet_ShowMode = $GUI_HIDE
						EndSwitch

						GUICtrlSetData($ArrowPosition_Combo,'Center|Left|Right',$ArrowPosition_sComboText)


					; More options will be available in later versions
						GUICtrlCreateLabel('* More options will be available in later versions.',12,150,250,100)
						GUICtrlSetColor(-1,0x1e65d8)

				#EndRegion



			; Show the GUI
				GUISetState(@SW_SHOW)
				$hActiveWindow = $hGUI



			#Region Create the toolbar preview

				$hGUI_aPos = WinGetPos($hGUI)
				If @error Then Return GUIDelete($hGUI)

				$tmp1 = _WinAPI_GetClientRect($hGUI)
				If @error Then Return GUIDelete($hGUI)



				$tmp2 = DllStructCreate("int X;int Y")


				DllStructSetData($tmp2, "X", $C_Graphic_xPos)
				DllStructSetData($tmp2, "Y", $C_Graphic_yPos)


				_WinAPI_ClientToScreen($hGUI, $tmp2)
				If @error Then Return GUIDelete($hGUI)

				$ToolBarOptions_xStart = DllStructGetData($tmp2, "X")+1
				Local $yStart = DllStructGetData($tmp2, "Y")
				$ToolBarOptions_xEnd = $ToolBarOptions_xStart+$C_Graphic_xSize-1





				ToolBarOptions_ArrowSetXPosMode()
				$ToolBarOptions_aArrowPos[1] = $yStart+2

				$tmp1 = ToolBarOptions_ReCreateToolBarPreview()

				$ToolBar_xPos = $tmp1[0]
				$ToolBar_yPos = $tmp1[1]

			#EndRegion


			; Prepare things for the loop
				$timer1 = TimerInit()
				$timer2 = $timer1

				aExtraFuncCalls_AddFunc(ToolBarOptions)
				Return
		EndIf




		If TimerDiff($timer2) >= 250 Then

			WinSetOnTop($GUIMenuButton_h,Null,True)

			$timer2 = TimerInit()
		EndIf



	; Monitor Arrow settings
		$tmp1 = Number(GUICtrlRead($ArrowPosOffSet_Input))
		If $tmp1 <> $GUMe_xPosFix Then
;~ 			ToolTip(1)
			$GUMe_xPosFix = $tmp1

			ToolBarOptions_ArrowSetXPosMode()
			$tmp1 = ToolBarOptions_ReCreateToolBarPreview()
			$ToolBar_xPos = $tmp1[0]
			$ToolBar_yPos = $tmp1[1]
		EndIf




		; Monitor arrow pos mode
		$tmp1 = GUICtrlRead($ArrowPosition_Combo)
		If $tmp1 <> $ArrowPosition_sComboText Then ; The user changed the pos mode
			$ArrowPosition_sComboText = $tmp1

			Local $ShowModeNew
			Switch $ArrowPosition_sComboText
				Case 'Left'
					$ShowModeNew = $GUI_SHOW
					$GUMe_xPos_mode = $C_GUMe_xPos_mode_Left

				Case 'Right'
					$ShowModeNew = $GUI_SHOW
					$GUMe_xPos_mode = $C_GUMe_xPos_mode_Right
				Case 'Center'
					$ShowModeNew = $GUI_HIDE
					$GUMe_xPos_mode = $C_GUMe_xPos_mode_Center

			EndSwitch

			If $ArrowOffSet_ShowMode <> $ShowModeNew Then
				$ArrowOffSet_ShowMode = $ShowModeNew
				GUICtrlSetState($ArrowPosOffSet_Label,$ArrowOffSet_ShowMode)
				GUICtrlSetState($ArrowPosOffSet_Input,$ArrowOffSet_ShowMode)
			EndIf


				ToolBarOptions_ArrowSetXPosMode()
;~ 				$ToolBarOptions_aArrowPos[1] = $yStart+2

				$tmp1 = ToolBarOptions_ReCreateToolBarPreview()

				$ToolBar_xPos = $tmp1[0]
				$ToolBar_yPos = $tmp1[1]

;~ 			ToolBarOptions_ReCreateToolBarPreview()


		EndIf




		If $Software_MSG[1] <> $hGUI Then Return

		If TimerDiff($timer1) >= 500 Then
			$tmp = WinGetPos($hGUI)
			If Not @error And ($tmp[0] <> $hGUI_aPos[0] Or $tmp[1] <> $hGUI_aPos[1]) Then

				$xDiff = $tmp[0]-$hGUI_aPos[0]
				$yDiff = $tmp[1]-$hGUI_aPos[1]

				$ToolBarOptions_aArrowPos[0] += $xDiff
				$ToolBarOptions_aArrowPos[1] += $yDiff

				$ToolBar_xPos += $xDiff
				$ToolBar_yPos += $yDiff

				$ToolBarOptions_xStart += $xDiff
				$ToolBarOptions_xEnd += $xDiff


				WinMove($GUIMenuButton_h,Null,$ToolBarOptions_aArrowPos[0],$ToolBarOptions_aArrowPos[1])
				WinMove($GUMe_WinOptions_hgui,Null,$ToolBar_xPos,$ToolBar_yPos)

				WinSetOnTop($GUIMenuButton_h,Null,True)



				$hGUI_aPos = $tmp

			EndIf
			$timer1 = TimerInit()
		EndIf


		$tmp1 = Number(GUICtrlRead($iMaxItems_Combo))

		If $tmp1 <> $GUMe_WinOptions_iMaxItems Then
			$GUMe_WinOptions_iMaxItems = $tmp1
			$tmp1 = ToolBarOptions_ReCreateToolBarPreview()
			$ToolBar_xPos = $tmp1[0]
			$ToolBar_yPos = $tmp1[1]
		EndIf















		Switch $Software_MSG[0]


			Case $ChangeBkColor_Button
				$tmp = _ChooseColor (2, $GUMe_WinOptions_bkcolor,2, $hGUI)
				If $tmp <> -1 Then
					$GUMe_WinOptions_bkcolor = $tmp
					ToolBarOptions_ReCreateToolBarPreview()
				EndIf
			Case $ChangeBkColorToDef_Button
				If $GUMe_WinOptions_bkcolor <> $C_GUMe_WinOptions_def_bkcolor Then
					$GUMe_WinOptions_bkcolor = $C_GUMe_WinOptions_def_bkcolor
					ToolBarOptions_ReCreateToolBarPreview()
				EndIf

			Case $ToolbarDynamicBkColor_Checkbox

				If $GUMe_WinOptions_bDynamicBkColor Then
					$GUMe_WinOptions_bDynamicBkColor = 0
					$tmp = $GUI_ENABLE
				Else
					$GUMe_WinOptions_bDynamicBkColor = 1
					$tmp = $GUI_DISABLE
				EndIf



				GUICtrlSetState($ChangeBkColor_Label,$tmp)
				GUICtrlSetState($ChangeBkColor_Button,$tmp)
				GUICtrlSetState($ChangeBkColorToDef_Button,$tmp)


				ToolBarOptions_ReCreateToolBarPreview()

			Case $ApplySettings_Button

				; Save and set the bk color
					IniWrite($ini,'ToolBar','BkColor',$GUMe_WinOptions_bkcolor)


				; Save the dynamicBkColor
					IniWrite($ini,'ToolBar','DynamicBkColor',$GUMe_WinOptions_bDynamicBkColor)

				; Save the max buttons
					IniWrite($ini,'ToolBar','MaxItems',$GUMe_WinOptions_iMaxItems)

				; Save the arrow settings
					IniWrite($ini,'Arrow','PosMode',$GUMe_xPos_mode)


				; Save the arrow pos offset
					If $GUMe_xPos_mode <> $C_GUMe_xPos_mode_Center Then
						If $Save_Set_ArrowXPosMode = $C_GUMe_xPos_mode_Center Then
							; Reset the pos data in case we need to....
							For $a = 1 To $aWins[0][0]
								If Not $aWins[$a][$C_aWins_idx_hMB_fixed_x] Then ContinueLoop
								$aWins[$a][$C_aWins_idx_hMB_fixed_x] = 0
							Next
						EndIf
						IniWrite($ini,'Arrow','PosOffset',$GUMe_xPosFix)
					EndIf



				; The next code will not restore the settings
					$Save_bRestoreSettings = False



				; Close the GUI and exit
					ContinueCase

			Case $GUI_EVENT_CLOSE
				GUIDelete($hGUI)


				aExtraFuncCalls_RemoveFunc(GUIMenuButton_WinOptions)
				aExtraFuncCalls_RemoveFunc(ToolBarOptions)


				GUIMenuButton_WinOptions_remove()
				GUIMenuButton_Delete()

				TrayItemSetState($Tray_ToolBarOptions,$TRAY_ENABLE)
				$GUIMenuButton_bDisableUpdatePos = False


				If Not $Save_bRestoreSettings Then Return

			; Restore the toolbar settings
				$GUMe_WinOptions_iMaxItems = $Save_Set_iMaxItems
				$GUMe_WinOptions_bDynamicBkColor = $Save_Set_bDynamicBkColor
				$GUMe_WinOptions_bkcolor = $Save_Set_bkcolor

			; Restore the arrow settings
				$GUMe_xPosFix = $Save_Set_ArrowXPosOffSet
				$GUMe_xPos_mode = $Save_Set_ArrowXPosMode

		EndSwitch





	EndFunc


Func ToolBarOptions_ReCreateToolBarPreview()
	GUIMenuButton_Create(-1, $ToolBarOptions_aArrowPos)
	If $GUMe_WinOptions_hgui <> -1 Then
		aExtraFuncCalls_RemoveFunc(GUIMenuButton_WinOptions)
		GUIMenuButton_WinOptions_remove()
	EndIf
	Return GUIMenuButton_WinOptions(-1,$ToolBarOptions_xStart,$ToolBarOptions_xEnd-1)
EndFunc


Func ToolBarOptions_ArrowSetXPosMode()
	Switch $GUMe_xPos_mode
		Case $C_GUMe_xPos_mode_Center
			$ToolBarOptions_aArrowPos[0] = $ToolBarOptions_xStart+Round((($ToolBarOptions_xEnd-$ToolBarOptions_xStart)/2)-($C_GUIMenuButton_DefXsize/2))
		Case $C_GUMe_xPos_mode_Left
			$ToolBarOptions_aArrowPos[0] = $ToolBarOptions_xStart+$GUMe_xPosFix
			If $ToolBarOptions_aArrowPos[0] > $ToolBarOptions_xEnd Then $ToolBarOptions_aArrowPos[0] = $ToolBarOptions_xEnd-$C_GUIMenuButton_DefXsize
		Case $C_GUMe_xPos_mode_Right
			$ToolBarOptions_aArrowPos[0] = $ToolBarOptions_xEnd-$C_GUIMenuButton_DefXsize-$GUMe_xPosFix
;~ 			If $ToolBarOptions_aArrowPos[0] < $ToolBarOptions_xStart Then $ToolBarOptions_aArrowPos[0] = $ToolBarOptions_xStart
	EndSwitch
EndFunc




#EndRegion


Func FeatureOnlyProMSG($bStart = False)

	Local Static $hGUI, $ActivateOr30Days_Button, $Close_Button


	If $bStart Then
		If $hGUI Then
			WinActivate($hGUI)
			Return
		EndIf
		$hGUI = GUICreate("", 616, 147)
		GUICtrlCreateLabel("Sorry, this feature is available for the pro version only.", 30, 20, 548, 32)
		GUICtrlSetFont(-1, 17, 400, 0, "Tahoma")

		$Close_Button = GUICtrlCreateButton("Close", 427, 77, 158, 47)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
		GUISetState(@SW_SHOW)
		aExtraFuncCalls_AddFunc(FeatureOnlyProMSG)
		Return
	EndIf



	If $Software_MSG[1] <> $hGUI Then Return


	Switch $Software_MSG[0]
		Case $Close_Button, $GUI_EVENT_CLOSE
			GUIDelete($hGUI)
			$hGUI = Null
			Return True
	EndSwitch
EndFunc



Func SaveWinConfigGUI($bStart = False)
	Local Static $hGUI, $Close_Button
	If $bStart Then
		If $hGUI Then
			WinActivate($hGUI)
			Return
		EndIf
		$hGUI = GUICreate("How to save window configuration", 457, 428)
		GUICtrlCreateLabel('To save window configuration, right click on the arrow -> click on "Save window configuration..."', 15, 15, 424, 45)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
		Local $Pic = GUICtrlCreatePic("", 20, 70, 416, 279)
		_ResourceSetImageToCtrl($Pic, 'save_win_config')
		$Close_Button = GUICtrlCreateButton("Close", 22, 365, 415, 51)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

		GUISetState(@SW_SHOW)
		aExtraFuncCalls_AddFunc(SaveWinConfigGUI)
		Return

	EndIf

	If $Software_MSG[1] <> $hGUI Then Return

	Switch $Software_MSG[0]
		Case $Close_Button, $GUI_EVENT_CLOSE
			GUIDelete($hGUI)
			$hGUI = Null
			Return True
	EndSwitch

EndFunc
