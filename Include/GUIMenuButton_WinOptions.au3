;


Func GUIMenuButton_WinOptions($prm_iIndex = 0, $x1Pos = 0, $x2Pos = 0) ; ($iIndex,$iMaxItems = $GUMe_WinOptions_iMaxItems)
	#cs
		Function to create the win options menu

	#ce




	Local Static $ButtonMenu_aObject, $ButtonMenu_page, $aGuiCtrlMouseOver, $iIndex, $ButtonMenu_xPos, $xPos, $yPos, $mb_pos, _
				$Next_Button, $Back_Button, $bReActiveWindow


	#Region Start GUI
	If $prm_iIndex Then

		$iIndex = $prm_iIndex

		Local $iMaxItems = $GUMe_WinOptions_iMaxItems

		$GUMeBu_WinOptions_ActiveBkColor = $GUMe_WinOptions_bkcolor

		$bReActiveWindow = False




		Local $ButtonMenu_xSpace
		$aButtonsIds = $GUMe_WinOptions_aButtonsIds

	; Remove the dark mode feature in case it is not supported
		If $iIndex > 0 And $aWins[$iIndex][$C_aWins_idx_ProcessName] = 'ApplicationFrameHost.exe' Then
			$tmp = _ArraySearch($aButtonsIds,$GUMe_WinOptions_bl_id_dark,1)
			If $tmp > 0 Then
				_ArrayDelete($aButtonsIds,$tmp)
				$aButtonsIds[0] -= 1
			EndIf
		EndIf



	; Remove the aero pro if it is disabled

	$tmp = _ArraySearch($aButtonsIds,$GUMe_WinOptions_bl_id_aero,1)
	if $tmp > 0 Then
		_ArrayDelete($aButtonsIds,$tmp)
		$aButtonsIds[0] -= 1
	EndIf




		If $aButtonsIds[0] < $iMaxItems Then $iMaxItems = $aButtonsIds[0]
		$ButtonMenu_xSpace = ($C_ButtonMenu_Button_xSize+$C_ButtonMenu_Button_xDiffSpace)*$iMaxItems
		$ButtonMenu_aObject = CreateXPointsGeometryObject($aButtonsIds,$ButtonMenu_xSpace,$C_ButtonMenu_Button_xSize,$C_ButtonMenu_Button_xDiffSpace) ; Build the buttons grup object




		$GUMe_WinOptions_x_size = $ButtonMenu_xSpace

	;~ 		_ArrayDisplay($p[$ButtonMenu_aObject])


		; Calculates the x pos of the menu
		$ButtonMenu_xPos = 0
		$ButtonMenu_page = 1
		; If there is more than one page then resize the gui and ... for back and next buttons.
		If ($ButtonMenu_aObject)[2][1] > 1 Then
			$ButtonMenu_xPos = $C_NextBack_xEnd
			$GUMe_WinOptions_x_size += ($ButtonMenu_xPos*2)

			If $iIndex > 0 And $aWins[$iIndex][$C_aWins_idx_MwSettingsPage] Then $ButtonMenu_page = $aWins[$iIndex][$C_aWins_idx_MwSettingsPage]
		Else

			$GUMe_WinOptions_x_size += $i0DifSpace*2
			$ButtonMenu_xPos += $i0DifSpace-1

		EndIf




		; Calculating the POS of the GUI based on the POS of the menu GUI
			$mb_pos = WinGetPos($GUIMenuButton_h)
			$yPos = $mb_pos[1]+$C_GUIMenuButton_DefYsize
			$xPos = $mb_pos[0]+Int($C_GUIMenuButton_DefXsize/2)-Int($GUMe_WinOptions_x_size/2)

			If $iIndex > 0 Then
				$x1Pos = $aWins[$iIndex][$C_aWins_idx_x_pos]
				$x2Pos = $aWins[$iIndex][$C_aWins_idx_x_pos]+$aWins[$iIndex][$C_aWins_idx_x_size]
			EndIf

			If $xPos < $x1Pos Then
				$xPos = $x1Pos
			Else
				If $xPos+$GUMe_WinOptions_x_size > $x2Pos Then $xPos = $x2Pos-$GUMe_WinOptions_x_size
			EndIf



		; Create the GUI toolbar:

		If $GUMe_WinOptions_bDynamicBkColor Then
			If $iIndex > 0 Then
				If Not $aWins[$iIndex][$C_aWins_idx_opacityactive] Then
					$tmp = aWins_GetAverageColour($iIndex)
					If Not @error Then
						$GUMeBu_WinOptions_ActiveBkColor = $tmp
						$aWins[$iIndex][$C_aWins_idx_AverageColor] = $GUMeBu_WinOptions_ActiveBkColor
					EndIf
				Else
					If $aWins[$iIndex][$C_aWins_idx_AverageColor] Then $GUMeBu_WinOptions_ActiveBkColor = $aWins[$iIndex][$C_aWins_idx_AverageColor]
				EndIf
			Else
				$GUMeBu_WinOptions_ActiveBkColor = $C_GUMe_WinOptions_def_bkcolor
			EndIf
		EndIf




		$GUMe_WinOptions_hgui = CreateBaseGUI($xPos,$yPos,$GUMe_WinOptions_x_size,$GUMe_WinOptions_y_size,$g_DummyTopGui,$GUMeBu_WinOptions_ActiveBkColor)




		$GUMe_WinOptions_hgui_hgraphic = _GDIPlus_GraphicsCreateFromHWND($GUMe_WinOptions_hgui)


		; Defince space for buttons
		Local Const $ButtonMenu_y_pos = 4
		Local $ButtonMenu_y_space = $GUMe_WinOptions_y_size-($ButtonMenu_y_pos*2)


		$Next_Button = Null
		$Back_Button = Null

		; If there is more than one page then create next and the back buttons
		If ($ButtonMenu_aObject)[2][1] > 1 Then
			$Back_Button = GUICtrlCreateButton(3,$C_NextBack_xSpace,$ButtonMenu_y_pos,$C_NextBack_xSize,$ButtonMenu_y_space);,$BS_CENTER)
			GUICtrlSetFont(-1, $C_NextBack_iFontSize, 400, 0, "Webdings")
			$Next_Button = GUICtrlCreateButton(4,$GUMe_WinOptions_x_size-$C_NextBack_xSpace-$C_NextBack_xSize,$ButtonMenu_y_pos,$C_NextBack_xSize,$ButtonMenu_y_space);,$BS_CENTER)
			GUICtrlSetFont(-1, $C_NextBack_iFontSize, 400, 0, "Webdings")

			If $ButtonMenu_page = 1 Then GUICtrlSetState($Back_Button,$GUI_DISABLE)
			If $ButtonMenu_page = $ButtonMenu_aObject[2][1] Then GUICtrlSetState($Next_Button,$GUI_DISABLE)

		EndIf



		; Show the GUI
		GUISetState(@SW_SHOWNOACTIVATE,$GUMe_WinOptions_hgui)
		; Done


		; Draw the buttons on the GUI:
		;	a) Extract the page of buttons from the buttons grup object

		$GUMe_WinOptions_ButtonMenu_page_aButtons = CreateXPointsGeometryObject_GetXPointsPosInstructions($ButtonMenu_aObject,$ButtonMenu_page,$GUMe_WinOptions_aButtons_max)
		#cs
			זה מערך שמכיל מספר כפתורים שמזוהים לפי מספר ID
			לצד כל מספר מצויין המקום שצריך לצייר את הכפתור בציר X

		#ce
		;	b) Draw the page array on the gui




		GUIMenuButton_WinOptions_CreateButtonsPage($aGuiCtrlMouseOver,$iIndex,$ButtonMenu_xPos)
		#cs
			הפונקציה הזו משתמשת במערך הזה כדי לדעת מה לצייר ואיפה
			היא עוברת על המערך, לפי ה ID
			היא יודעת איזה תמונה צריכה להיות לכפתור
			ולפי המספר שמצורף ל ID
			היא יודעת היכן על ציר X יש ליצור את הכפתור

		#ce
		; Done (Create the GUI settings)


		AdlibRegister(GUIMenuButton_WinOptions_Adlib_ManageHoveringButtons,40)


		aExtraFuncCalls_AddFunc(GUIMenuButton_WinOptions)

		Local $tmp[2] = [$xPos,$yPos]
		Return	$tmp
	EndIf
	#EndRegion



	#Region Process GUI



	Switch $Software_MSG[1]
		Case $GUIMenuButton_h ; If user clicked on $GUIMenuButton_h then
			If $iIndex > 0 And $Software_MSG[0] = $GUIMenuButton_hDrag Then GUIMenuButton_UpdatePosByMouse($iIndex) ; Update the new pos of $GUISettings while the user draging the $GUIMenuButton_h GUI.


		Case $GUMe_WinOptions_hgui ; If the user clicked on something inside this GUI then

			Switch $Software_MSG[0]

				Case $Back_Button, $Next_Button
					; do something with [page number] of [the buttons array of the page]
					Switch $Software_MSG[0]
						Case $Back_Button
							If $ButtonMenu_page = 1 Then Return
							If $ButtonMenu_page = $ButtonMenu_aObject[2][1] Then GUICtrlSetState($Next_Button,$GUI_ENABLE)
							$ButtonMenu_page -= 1
							If $ButtonMenu_page = 1 Then GUICtrlSetState($Back_Button,$GUI_DISABLE)
						Case $Next_Button
							If $ButtonMenu_page = $ButtonMenu_aObject[2][1] Then Return
							If $ButtonMenu_page = 1 Then GUICtrlSetState($Back_Button,$GUI_ENABLE)
							$ButtonMenu_page += 1
							If $ButtonMenu_page = $ButtonMenu_aObject[2][1] Then GUICtrlSetState($Next_Button,$GUI_DISABLE)
					EndSwitch

					GUIMenuButton_WinOptions_RemoveButtonsPage()
					$GUMe_WinOptions_ButtonMenu_page_aButtons = CreateXPointsGeometryObject_GetXPointsPosInstructions($ButtonMenu_aObject,$ButtonMenu_page,$GUMe_WinOptions_aButtons_max)
					GUISwitch($GUMe_WinOptions_hgui)

					GUIMenuButton_WinOptions_CreateButtonsPage($aGuiCtrlMouseOver,$iIndex,$ButtonMenu_xPos)

					If $iIndex > 0 Then $aWins[$iIndex][$C_aWins_idx_MwSettingsPage] = $ButtonMenu_page
				Case Else

					If $iIndex > 0 Then
						; ניתור לחיצה על כפתורים
						For $a = 1 To $GUMe_WinOptions_ButtonMenu_page_aButtons[0][0]
							If $GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_hCtrl] <> $Software_MSG[0] Then ContinueLoop

							Switch $GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_CtrlId]

								Case $GUMe_WinOptions_bl_id_top
									aWins_SetOnTop($iIndex)
									WinSetOnTop($GUMe_WinOptions_hgui,'',1)
									GUIMenuButton_WinOptions_SetButtonActiveNonActive($a,$aWins[$iIndex][$C_aWins_idx_IsTop])

								Case $GUMe_WinOptions_bl_id_opacity

									aWins_Opacity_OnOff($iIndex)
									If $aWins[$iIndex][$C_aWins_idx_opacitylevel] = 100 Then
										aWins_Opacity_SetLevel($iIndex,$C_def_OpacityLevel)
										If $GUMe_WiOpt_OpacityGUI Then GUICtrlSetData($GUMe_WiOpt_Opacity_SliderCtrl,$C_def_OpacityLevel)
									EndIf

									GUIMenuButton_WinOptions_UpdateActiveButtons($iIndex)


								Case $GUMe_WinOptions_bl_id_dark
									aWins_ToggleColorEffect($iIndex,Default)
									GUIMenuButton_WinOptions_UpdateActiveButtons($iIndex)


								Case $GUMe_WinOptions_bl_id_shrink
									aWins_Shrink($iIndex,Default)
									GUIMenuButton_WinOptions_SetButtonActiveNonActive($a,$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI])
									GUIMenuButton_Delete()
									$mb_pos = Null


							EndSwitch

							ExitLoop

						Next
					EndIf



			EndSwitch




	EndSwitch
	; Done

	Local $msg2
	_GuiCtrlIsMouseOver($aGuiCtrlMouseOver,$msg2,1,$GUMe_WinOptions_aCursorInfo_new) ; Update $msg ...


	If $msg2 Then

		Switch $GUMe_WinOptions_ButtonMenu_page_aButtons[$msg2][$C_GUMe_WinOptions_aButtons_idx_CtrlId]

			Case $GUMe_WinOptions_bl_id_opacity
				; ConsoleWrite('$ButtonMenue_id_opacity' &' (L:'&@ScriptLineNumber&')'&@CRLF)
				If Not $GUMe_WiOpt_OpacityGUI Then
					Local $tmp[2] = [$iIndex,$msg2]
					GUIMenuButton_WinOptions_SetOpacityLevel($tmp)
				EndIf


		EndSwitch
		$msg2 = Null
	EndIf



	If $iIndex = -1 Then Return

	Local Static $timer1


	If $GUMe_WiOpt_bDisableExitWhenOutMouse Then
		$timer1 = TimerInit()
		Return
	EndIf

	If Not IsArray($mb_pos) Or ($MousePos_aPos[0] < $xPos Or $MousePos_aPos[0] > $xPos+$GUMe_WinOptions_x_size) Or _
	($MousePos_aPos[1] < $mb_pos[1]-1 Or $MousePos_aPos[1] > $yPos+$GUMe_WinOptions_y_size) Then

		If TimerDiff($timer1) > $C_GUMe_WinOptions_exit_timeout Then
			GUIMenuButton_WinOptions_remove()


			If $bReActiveWindow Then
				If Not $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] Then
					WinActivate($aWins[$iIndex][$C_aWins_idx_hWin])
					WinActivate("[CLASS:Shell_TrayWnd]")
					WinActivate($aWins[$iIndex][$C_aWins_idx_hWin])
				EndIf

			EndIf



			Return True ; return true to stop this function to be called again from the main loop
		EndIf

	Else
		$timer1 = TimerInit()
	EndIf

	#EndRegion




EndFunc

Func GUIMenuButton_WinOptions_remove()
	_GDIPlus_GraphicsDispose($GUMe_WinOptions_hgui_hgraphic)
	GUIDelete($GUMe_WinOptions_hgui)
	$GUMe_WinOptions_hgui = -1

	AdlibUnRegister(GUIMenuButton_WinOptions_Adlib_ManageHoveringButtons)
	$GUMe_WinOptions_aCursorInfo_new = 0
	$GUMe_WinOptions_ButtonMenu_page_aButtons = 0
EndFunc

#include 'CreateXPointsGeometryObject.au3'



Func GUIMenuButton_WinOptions_Adlib_ManageHoveringButtons()

#cs
	GUIGetCursorInfo return:
		$aArray[0] = X coord (horizontal)
		$aArray[1] = Y coord (vertical)
		$aArray[2] = Primary down (1 if pressed, 0 if not pressed)
		$aArray[3] = Secondary down (1 if pressed, 0 if not pressed)
		$aArray[4] = ID of the control that the mouse cursor is hovering over (or 0 if none)

#ce
	Local Static $tmp1
	$tmp1 = GUIGetCursorInfo($GUMe_WinOptions_hgui)
	If @error Then Return

	$GUMe_WinOptions_aCursorInfo_new = $tmp1


	If $GUMe_WinOptions_aCursorInfo_new[4] = $GUMe_WinOptions_aCursorInfo_now[4] Then Return


	#cs
		חלק זה בקוד אחראי על צייור המסגרת החלשה סביב הכפתור כאשר לחצן העכבר עומד עליו
	#ce


	; אם כבר יש כפתור שצויירה מסביבו מסגרת ירוקה חלשה אז נקה את המסגרת למסגרת רגילה ושחורה
		If $GUMe_WinOptions_iHoveringCtrlIndex > 0 Then _
		GUIImageButton_SetSquareFrame($GUMe_WinOptions_hgui,$GUMe_WinOptions_hgui_hgraphic,$GUMe_WinOptions_ButtonMenu_page_aButtons[$GUMe_WinOptions_iHoveringCtrlIndex][2],$C_GUMe_WinOptions_Normal_LineWidth,$GUMe_WinOptions_Normal_LineColor)

	; חפש את הפוזיציה של הקונטרול הנוכחי שעליו העכבר נמצא
		$tmp1 = Array2DSearch($GUMe_WinOptions_ButtonMenu_page_aButtons, $GUMe_WinOptions_aCursorInfo_new[4],$C_GUMe_WinOptions_aButtons_idx_hCtrl,1,$GUMe_WinOptions_ButtonMenu_page_aButtons[0][0])

	If $tmp1 > 0 Then ; במקרה זה העכבר עבר להיות על כפתור אחר
		; ולכן יש לצייר מסגרת ירוקה חלשה מסביבו וזה מה שנעשה כאן
		If Not $GUMe_WinOptions_ButtonMenu_page_aButtons[$tmp1][$C_GUMe_WinOptions_aButtons_idx_IsActive] Then
			GUIImageButton_SetSquareFrame($GUMe_WinOptions_hgui,$GUMe_WinOptions_hgui_hgraphic,$GUMe_WinOptions_ButtonMenu_page_aButtons[$tmp1][2],$C_GUMe_WinOptions_OnHover_LineWidth,$GUMe_WinOptions_OnHover_LineColor)
			$GUMe_WinOptions_iHoveringCtrlIndex = $tmp1
		EndIf

		; ונזכור עבור איזה כפתור ציירנו מסגרת חלשה ומיהו הכפתור שעליו לחצן העכבר נמצא כעת
		If $tmp1 <> $GUMe_WinOptions_iLastActiveCtrlIndex Then $GUMe_WinOptions_iLastActiveCtrlIndex = $tmp1
	EndIf

	; במקרה זה שטמפ1 לא גדול מ 0 העכבר לא נמצא על אף כפתור ולכן אין צורך לצייר מסגרת ירוקה חלשה מסביבו

	; ונעדכן את מידע לחצן העכבר כדי שבעתיד הבדיקה תזהה שינוי חדש
		$GUMe_WinOptions_aCursorInfo_now[4] = $GUMe_WinOptions_aCursorInfo_new[4]



EndFunc

Func GUIMenuButton_WinOptions_SetOpacityLevel($aData = Null)


	Local Static $iIndex, $hSetClickT_Checkbox, $SetClickT_label , $hParentButton_hCtrl, $hParentButton_iButtonIndex , $SetTop_iButtonIndex , $xPos1, $xPos2, $yPos1, $yPos2 , $timer


	Local Const $C_GUIxSize = 140, $C_GUIySize = 55

	If IsArray($aData) Then

		$iIndex = $aData[0]
		$hParentButton_iButtonIndex = $aData[1]






		$hParentButton_hCtrl = $GUMe_WinOptions_ButtonMenu_page_aButtons[$hParentButton_iButtonIndex][$C_GUMe_WinOptions_aButtons_idx_hCtrl]


		Local $aButtonPos, $oaButtun = $GUMe_WinOptions_ButtonMenu_page_aButtons[$hParentButton_iButtonIndex][$C_GUMe_WinOptions_aButtons_idx_button_object]
		If IsArray($oaButtun) And IsArray($oaButtun[1]) Then
			$aButtonPos = $oaButtun[1]
			$aButtonPos[3] += $oaButtun[2]
		Else
			$aButtonPos = $hParentButton_hCtrl
		EndIf

		Local $xPos = -1, $yPos = -1
		GUIGetXYPosByParentButton($xPos,$yPos,$C_GUIxSize,$C_GUIySize,$GUMe_WinOptions_hgui,$aButtonPos)
		$GUMe_WiOpt_OpacityGUI = CreateBaseGUI($xPos,$yPos,$C_GUIxSize,$C_GUIySize,$GUMe_WinOptions_hgui,$GUMeBu_WinOptions_ActiveBkColor)

		Local Const $C_Slider_ySize = 30
		$GUMe_WiOpt_Opacity_SliderCtrl = GUICtrlCreateSlider(1, 1, $C_GUIxSize-2,$C_Slider_ySize)
		GUICtrlSetLimit($GUMe_WiOpt_Opacity_SliderCtrl,100,5)

		If $iIndex > 0 Then

			; TODO: fix here the bug "Array variable has incorrect number of subscripts or subscript dimension range exceeded.:" that sometimes (rare cases) happen

			If Not $aWins[$iIndex][$C_aWins_idx_opacitylevel] Then $aWins[$iIndex][$C_aWins_idx_opacitylevel] = $C_def_OpacityLevel
			GUICtrlSetData($GUMe_WiOpt_Opacity_SliderCtrl,$aWins[$iIndex][$C_aWins_idx_opacitylevel])
		Else
			GUICtrlSetData($GUMe_WiOpt_Opacity_SliderCtrl,$C_def_OpacityLevel)
		EndIf

		#cs
		$p[$hSetClickT_Checkbox] = GUICtrlCreateCheckbox('Enable click through',6,$C_Slider_ySize+2,$C_GUIxSize-12)
		GUICtrlSetFont(-1, 9, 400, 0, "Tahoma")
		GUICtrlSetTip(-1,'This will make the window just like a ghost. use this if you find yourself moving the window around...'&@CRLF&@CRLF& _
		'If you click on the window, you will click on bverything behind the window.')
		#ce

		$hSetClickT_Checkbox = GUICtrlCreateCheckbox('',6,$C_Slider_ySize+2,16,18)
		GUICtrlSetFont(-1, 9, 400, 0, "Tahoma")


		$SetClickT_label = GUICtrlCreateLabel('Enable click through',22,$C_Slider_ySize+3)
		GUICtrlSetTip(-1,'This will make the window just like a ghost. use this if you find yourself moving the window around...'&@CRLF&@CRLF& _
		'If you click on the window, you will click on bverything behind the window.')


		GUICtrlSetBkColor($GUMe_WiOpt_Opacity_SliderCtrl,$GUMeBu_WinOptions_ActiveBkColor);GUICtrlSetBkColor($GUMe_WiOpt_Opacity_SliderCtrl,$C_GUMe_WinOptions_def_bkcolor)
		GUICtrlSetColor(-1,Color_GetInvertedBlackOrWhite($GUMeBu_WinOptions_ActiveBkColor))


		If $iIndex > 0 Then
			If $aWins[$iIndex][$C_aWins_idx_ProcessName] = 'ApplicationFrameHost.exe' Then
				GUICtrlSetState($hSetClickT_Checkbox,$GUI_DISABLE)
				GUICtrlSetState($SetClickT_label,$GUI_DISABLE)

				Local Const $C_msg = 'Sorry, the "click through" is not supported on Windows 10 *only* apps.'
				GUICtrlSetTip($SetClickT_label,$C_msg)
				GUICtrlSetTip($GUMe_WiOpt_Opacity_SliderCtrl,$C_msg)


			Else
				If $aWins[$iIndex][$C_aWins_idx_IsClickThrough] Then GUICtrlSetState($hSetClickT_Checkbox,$GUI_CHECKED)
			EndIf
		EndIf

		GUISetState(@SW_SHOWNOACTIVATE,$GUMe_WiOpt_OpacityGUI)




		$xPos1 = $xPos
		$xPos2 = $xPos+$C_GUIxSize
		$yPos1 = $yPos
		$yPos2 = $yPos+$C_GUIySize



		$SetTop_iButtonIndex = -1
		For $a = 1 To $GUMe_WinOptions_ButtonMenu_page_aButtons[0][0]
			If $GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_CtrlId] <> $GUMe_WinOptions_bl_id_top Then ContinueLoop
			$SetTop_iButtonIndex = $a
			ExitLoop
		Next


	;~ 	$aWins_UpdateNewActiveWin_disable = True
		aExtraFuncCalls_AddFunc(GUIMenuButton_WinOptions_SetOpacityLevel)

		Return

	EndIf



	If Not $GUMe_WiOpt_bDisableExitWhenOutMouse Then $GUMe_WiOpt_bDisableExitWhenOutMouse = True




	If $iIndex > 0 Then
		$tmp = GUICtrlRead($GUMe_WiOpt_Opacity_SliderCtrl)
		If $tmp <> $aWins[$iIndex][$C_aWins_idx_opacitylevel] Then


			If $tmp < 100 Then
				If Not $aWins[$iIndex][$C_aWins_idx_opacityactive] Then
					$aWins[$iIndex][$C_aWins_idx_opacitylevel] = $tmp
					aWins_Opacity_OnOff($iIndex,True)
					GUIMenuButton_WinOptions_UpdateActiveButtons($iIndex)

				Else
					aWins_Opacity_SetLevel($iIndex,$tmp)
				EndIf



			Else
				$aWins[$iIndex][$C_aWins_idx_opacitylevel] = $tmp
				aWins_Opacity_OnOff($iIndex,False)
				GUIMenuButton_WinOptions_SetButtonActiveNonActive($hParentButton_iButtonIndex,False)
			EndIf
		EndIf


		If $Software_MSG[1] = $GUMe_WiOpt_OpacityGUI Then

			Switch $Software_MSG[0]

				Case $SetClickT_label
					If Not $aWins[$iIndex][$C_aWins_idx_IsClickThrough] Then
						GUICtrlSetState($hSetClickT_Checkbox,$GUI_CHECKED)
					Else
						GUICtrlSetState($hSetClickT_Checkbox,$GUI_UNCHECKED)
					EndIf
					ContinueCase
				Case $hSetClickT_Checkbox


					If Not $aWins[$iIndex][$C_aWins_idx_IsClickThrough] Then

						If Not $bShowClickTWarning Then
							aWins_ToggleClickThrough($iIndex,True)
							If Not $aWins[$iIndex][$C_aWins_idx_opacityactive] Then
								aWins_Opacity_OnOff($iIndex,True)
								GUIMenuButton_WinOptions_UpdateActiveButtons($iIndex)

							EndIf
						Else
							ClickTrWarning($aWins[$iIndex][$C_aWins_idx_hWin],1)


						EndIf

					Else
						aWins_ToggleClickThrough($iIndex,False)

					EndIf

					If $SetTop_iButtonIndex <> -1 Then _
						GUIMenuButton_WinOptions_SetButtonActiveNonActive($SetTop_iButtonIndex,$aWins[$iIndex][$C_aWins_idx_IsTop])

					WinSetOnTop($GUMe_WiOpt_OpacityGUI,Null,True)


			EndSwitch




		EndIf























	EndIf



#cs
	If GUICtrlRead($ps[$hSetClickT_Checkbox]) = $GUI_CHECKED Then
		If Not $aWins[$ps[$l_iIndex]][$C_aWins_idx_IsClickThrough] Then
			aWins_ToggleClickThrough($ps[$l_iIndex],True)
			If Not $aWins[$ps[$l_iIndex]][$C_aWins_idx_opacityactive] Then
				aWins_Opacity_OnOff($ps[$l_iIndex],True)
				GUIMenuButton_WinOptions_SetButtonActiveNonActive($ps[$hParentButton_iButtonIndex],True)

				If $ps[$SetTop_iButtonIndex] <> -1 Then _
				GUIMenuButton_WinOptions_SetButtonActiveNonActive($ps[$SetTop_iButtonIndex],True)
				aWins_SetOnTop($ps[$l_iIndex],True)
				WinSetOnTop($GUMe_WiOpt_OpacityGUI,Null,True)

			EndIf


		EndIf
	Else
		If $aWins[$ps[$l_iIndex]][$C_aWins_idx_IsClickThrough] Then
			aWins_ToggleClickThrough($ps[$l_iIndex],False)
			WinSetOnTop($GUMe_WiOpt_OpacityGUI,Null,True)
		EndIf
	EndIf
#ce





	If $GUMe_WinOptions_aCursorInfo_new[4] = $hParentButton_hCtrl Or _
		($MousePos_aPos[0] >= $xPos1 And $MousePos_aPos[0] <= $xPos2 And _
		$MousePos_aPos[1] >= $yPos1 And $MousePos_aPos[1] <= $yPos2) Then
		$timer = TimerInit()


	Else
		If TimerDiff($timer) > $C_GUMe_WinOptions_exit_timeout Then

			GUIDelete($GUMe_WiOpt_OpacityGUI)
			$GUMe_WiOpt_OpacityGUI = 0
			$GUMe_WiOpt_bDisableExitWhenOutMouse = False
;~ 			$aWins_UpdateNewActiveWin_disable = False
			Return True
		EndIf

	EndIf


EndFunc


Func GUIMenuButton_WinOptions_SetButtonActiveNonActive($iButtonIndex,$bSetActive = Default)

	If Not IsArray($GUMe_WinOptions_ButtonMenu_page_aButtons) Or Not $GUMe_WinOptions_ButtonMenu_page_aButtons[0][0] Then Return


	If $bSetActive = Default Then
		If $GUMe_WinOptions_ButtonMenu_page_aButtons[$iButtonIndex][$C_GUMe_WinOptions_aButtons_idx_IsActive] Then
			$bSetActive = 1
		Else
			$bSetActive = 0
		EndIf
	EndIf

	$GUMe_WinOptions_iHoveringCtrlIndex = 0


	If $bSetActive Then
		GUIImageButton_SetSquareFrame($GUMe_WinOptions_hgui,$GUMe_WinOptions_hgui_hgraphic,$GUMe_WinOptions_ButtonMenu_page_aButtons[$iButtonIndex][$C_GUMe_WinOptions_aButtons_idx_button_object],$C_GUMe_WinOptions_Active_LineWidth,$GUMe_WinOptions_Active_LineColor)
	Else
		GUIImageButton_SetSquareFrame($GUMe_WinOptions_hgui,$GUMe_WinOptions_hgui_hgraphic,$GUMe_WinOptions_ButtonMenu_page_aButtons[$iButtonIndex][$C_GUMe_WinOptions_aButtons_idx_button_object],$C_GUMe_WinOptions_Normal_LineWidth,$GUMe_WinOptions_Normal_LineColor)
	EndIf
	$GUMe_WinOptions_ButtonMenu_page_aButtons[$iButtonIndex][$C_GUMe_WinOptions_aButtons_idx_IsActive] = $bSetActive



EndFunc


Func GUIMenuButton_WinOptions_UpdateActiveButtons($iIndex)

	Local $IsFeatureActive
	For $a = 1 To $GUMe_WinOptions_ButtonMenu_page_aButtons[0][0]
;~ 		_ArrayDisplay($aWins,$iIndexWin)
		$IsFeatureActive = 0
		Switch $GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_CtrlId]
			Case $GUMe_WinOptions_bl_id_top
				If $aWins[$iIndex][$C_aWins_idx_IsTop] Then $IsFeatureActive = 1
			Case $GUMe_WinOptions_bl_id_opacity
				If $aWins[$iIndex][$C_aWins_idx_opacityactive] Then $IsFeatureActive = 1
			Case $GUMe_WinOptions_bl_id_dark
				If $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] Then $IsFeatureActive = 1
			Case $GUMe_WinOptions_bl_id_aero
				If $aWins[$iIndex][$C_aWins_idx_aeroactive] Then $IsFeatureActive = 1
			Case Else
				ContinueLoop

		EndSwitch


		If $GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_IsActive] <> $IsFeatureActive Then _
				GUIMenuButton_WinOptions_SetButtonActiveNonActive($a,$IsFeatureActive)



	Next

EndFunc



Func GUIMenuButton_WinOptions_CreateButtonsPage(ByRef $aGuiCtrlMouseOver,$iIndexWin,$x_start)
	Local $aButton,$ImageSet,$iFrameWidth,$FrameColor,$sText,$IsFeatureActive


	$aGuiCtrlMouseOver = _GuiCtrlMouseOver_CreateGuiCtrls($GUMe_WinOptions_hgui,$GUMe_WinOptions_HoveringTriggerTime)
	;_ArrayDisplay($aGuiCtrlMouseOver)


	For $a = 1 To $GUMe_WinOptions_ButtonMenu_page_aButtons[0][0]
		$IsFeatureActive = 0
;~ 		_ArrayDisplay($aWins,$iIndexWin)
		Switch $GUMe_WinOptions_ButtonMenu_page_aButtons[$a][0]
			Case $GUMe_WinOptions_bl_id_top
				If $iIndexWin > 0 And $aWins[$iIndexWin][$C_aWins_idx_IsTop] Then $IsFeatureActive = 1
				$ImageSet = $GUMe_WinOptions_bl_img_top
				$sText = 'Set window on top'

			Case $GUMe_WinOptions_bl_id_opacity
				If $iIndexWin > 0 And $aWins[$iIndexWin][$C_aWins_idx_opacityactive] Then $IsFeatureActive = 1
				$ImageSet = $GUMe_WinOptions_bl_img_opacity
				$sText = 'Set window opacity'

			Case $GUMe_WinOptions_bl_id_dark
				If $iIndexWin > 0 And $aWins[$iIndexWin][$C_aWins_idx_hMask_hMag_active] Then $IsFeatureActive = 1
				$ImageSet = $GUMe_WinOptions_bl_img_dark
				$sText = 'Set dark'
			Case $GUMe_WinOptions_bl_id_shrink
				$ImageSet = $GUMe_WinOptions_bl_img_shrink
				$sText = 'Shrink window!'


		EndSwitch
		If @error Then ContinueLoop

		;If $a = 2 Then $IsFeatureActive = 1 ; <-------------------------------------------- DEBUG ONLY
		$aButton = GUIImageButton_Create($GUMe_WinOptions_hgui_hgraphic,$ImageSet,$x_start+$GUMe_WinOptions_ButtonMenu_page_aButtons[$a][1],$ButtonMenu_Button_y_pos)
		$GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_button_object] = $aButton

		GUIMenuButton_WinOptions_SetButtonActiveNonActive($a,$IsFeatureActive)
		GUICtrlSetTip(-1,$sText)
		$GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_hCtrl] = $aButton[0]
		_GuiCtrlMouseOver_AddCtrl($aGuiCtrlMouseOver,$aButton[0],Default,$a)

	Next
	$GUMe_WinOptions_iHoveringCtrlIndex = 0
	$GUMe_WinOptions_iLastActiveCtrlIndex = -1
;~ 		_ArrayDisplay($aGuiCtrlMouseOver)
;~ 		_ArrayDisplay($GUMe_WinOptions_ButtonMenu_page_aButtons)
EndFunc


Func GUIMenuButton_WinOptions_RemoveButtonsPage()
	If Not IsArray($GUMe_WinOptions_ButtonMenu_page_aButtons) Or Not $GUMe_WinOptions_ButtonMenu_page_aButtons[0][0] Then Return

	For $a = 1 To $GUMe_WinOptions_ButtonMenu_page_aButtons[0][0]
		If Not IsArray($GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_button_object]) Then ContinueLoop
		GUIImageButton_Delete($GUMe_WinOptions_hgui,$GUMe_WinOptions_ButtonMenu_page_aButtons[$a][$C_GUMe_WinOptions_aButtons_idx_button_object])
	Next
	Local $aOutput[1][UBound($GUMe_WinOptions_ButtonMenu_page_aButtons,2)] = [[0]]
	$GUMe_WinOptions_ButtonMenu_page_aButtons = $aOutput
EndFunc
Func GUIMenuButton_WinOptions_OnMouseOverCtrl($hGUI,$hCtrl,$IsOnOver,$ExtraData)
	;GUICtrlDelete($ExtraData)
	;GUICreateSquareFrameForCtrl($hGUI,$hCtrl,0x00A300)

	If $IsOnOver Then
		GDICreateSquareFrameForCtrl($hGUI,$GUMe_WinOptions_hgui_hgraphic,$hCtrl,0xFF00A300);,$hex_rgba_color = 0xFF000000,$iLineWidth = 2)
	Else
		GDICreateSquareFrameForCtrl($hGUI,$GUMe_WinOptions_hgui_hgraphic,$hCtrl)
	EndIf
	;GUISetState(@SW_HIDE,$hGUI)
	;GUISetState(@SW_SHOWNOACTIVATE,$hGUI)





EndFunc