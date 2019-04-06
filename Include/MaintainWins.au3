


#cs
Func MaintainWins_LoopFunc()
	Local Static $timer_UpdateWins


	; Update the windows in aWins every 1 sec or on first check
		If TimerDiff($timer_UpdateWins) >= 1000 Then
			aWins_Update()
			$timer_UpdateWins = TimerInit()
		EndIf


	;
		MaintainWins()

EndFunc
#ce

Func MaintainWins()

	;aWins_Show() ; <--------------------------------------------------- Debug Only




	If Not $aWins[0][0] Then Return


	; Set the timer for refresh rate
		If $aWins[0][$C_aWins_idx_hMask_hMag_active] Then $g_mw_hMag_update_timerdiff = TimerDiff($g_mw_hMag_update_timer)


	; Update $MousePos_aPos[0] , $MousePos_aPos[1] , $MousePos_IsNew
		If Not $bDisableMenuToolbar Then MousePos_Update()
		;If $MousePos_IsNew Then ErrorCheck(' $MousePos_IsNew')


	; Set
		If $bRunFeatureInThislProcess And $aWins[0][$C_aWins_idx_Shrink_hGUI] Then _
			$aWins_Shrink_TimerDiff = TimerDiff($aWins_Shrink_UpdateImageTimer)


	For $a = 1 To $aWins[0][0] ; Go on every window and:


		; Update the window pos
			aWins_UpdateNewWinPos($a)





		If $bRunFeatureInThislProcess Then
		; If dark mode is on, redraw it as dark....
			If $aWins[$a][$C_aWins_idx_hMask_hMag_active] And Not $aWins[$a][$C_aWins_idx_Shrink_hGUI] And _
			(BitAND(WinGetState($aWins[$a][$C_aWins_idx_hWin]), $WIN_STATE_ACTIVE) Or $g_mw_IsNewWinPos Or $aWins[$a][$C_aWins_idx_IsTop] Or _ ; BitAND(WinGetState($aWins[1][$C_aWins_idx_hWin]), $WIN_STATE_ACTIVE) isnted of $a = 1
			($aWins[$a][$C_aWins_idx_opacitylevel] And $aWins[$a][$C_aWins_idx_opacitylevel] < 100) Or _
			$g_mw_hMag_update_timerdiff >= $g_mw_hMag_update_refreshrate) Then aWins_UpdateDisplayOutput($a)

		EndIf

		; Maintain the shrink guis
			If $aWins[0][$C_aWins_idx_Shrink_hGUI] Then aWins_Shrink_UpdateShrinkGUI($a)

		; Stop here if the menu button is disabled
			If $bDisableMenuToolbar Then ContinueLoop


		; Show the menu button on the top of the window in case the mouse is on top of the window
			If Not $aWins[$a][$C_aWins_idx_Shrink_hGUI] Then MaintainWins_MenuButtonShowEvent($a)
			;If $MousePos_IsNew Then MaintainWins_MenuButtonShowEvent($a)




	Next


	; Check this
;~ 	If Not $ProFe_bDarkMode And $aWins[0][$C_aWins_idx_hMask_hMag_active] And $bRunFeatureInThislProcess And _
;~ 	$g_mw_hMag_update_timerdiff >= $g_mw_hMag_update_refreshrate Then _
;~ 		$g_mw_hMag_update_timer = TimerInit()

	If $aWins[0][$C_aWins_idx_hMask_hMag_active] And _
			$g_mw_hMag_update_timerdiff >= $g_mw_hMag_update_refreshrate Then $g_mw_hMag_update_timer = TimerInit()


	If $bRunFeatureInThislProcess And $aWins[0][$C_aWins_idx_Shrink_hGUI] And $aWins_Shrink_TimerDiff > $C_aWins_Shrink_UpdateTime Then _
		$aWins_Shrink_UpdateImageTimer = TimerInit()


	;If $MousePos_IsNew Then $MousePos_aPos_old = $MousePos_aPos ; <<<

	If $g_mw_hMag_aFilterWins <> -1 Then $g_mw_hMag_aFilterWins = -1
EndFunc


Func MaintainWins_MenuButtonShowEvent($iIndex)
	#cs
		תפקיד הפונקציה הוא להציג את כפתור החץ מתי שסמן העכבר נמצא בחלק העליון של החלון


	#ce




	If $GUIMenuButton_iIsDrag Then Return ; Or Not $MousePos_IsNew





	If $GUIMenuButton_iActiveWin And $GUIMenuButton_iActiveWin <= $aWins[0][0] Then $iIndex = $GUIMenuButton_iActiveWin


	If Not BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]),$WIN_STATE_MAXIMIZED) Then
		Local $iX = $aWins[$iIndex][$C_aWins_idx_x_pos],$iY = $aWins[$iIndex][$C_aWins_idx_y_pos]
	Else
		Local $iX = 0,$iY = 0
	EndIf

;~ 	If $MousePos_aPos[1] >= $iY And $MousePos_aPos[1] <= $iY+$C_GUIMenuButton_max_y_show_area And _
;~ 	$MousePos_aPos[0] >= $iX And $MousePos_aPos[0] <= $iX+$aWins[$iIndex][$C_aWins_idx_x_size] Then

	If ( $aWins[$iIndex][$C_aWins_idx_IsClickThrough] Or (MouseIsHoveredWnd($aWins[$iIndex][$C_aWins_idx_hWin],$MousePos_tPoint) Or _
	($GUIMenuButton_h > 0 And MouseIsHoveredWnd($GUIMenuButton_h,$MousePos_tPoint))) _
	) _
	And $MousePos_aPos[1] >= $iY And $MousePos_aPos[1] <= $iY+$C_GUIMenuButton_max_y_show_area And _
	$MousePos_aPos[0] >= $iX And $MousePos_aPos[0] <= $iX+$aWins[$iIndex][$C_aWins_idx_x_size] Then

		If $GUIMenuButton_h = -1 Then
			;$aWins_UpdateNewActiveWin_disable = True
			GUIMenuButton_Create($iIndex)
			$GUIMenuButton_iActiveWin = $iIndex
			$GUIMenuButton_iActiveWin_old = $iIndex
			If $aWins[$iIndex][$C_aWins_idx_IsTop] Then WinSetOnTop($GUIMenuButton_h,Null,True)

		Else
			If $Software_MSG[1] = $GUIMenuButton_h Then



				If $Software_MSG[0] = $GUIMenuButton_hDrag Then
					If $iIndex > 0 Then GUIMenuButton_UpdatePosByMouse($iIndex) ; Update the new pos of $GUISettings while the user draging the $GUIMenuButton_h GUI.
				EndIf

			EndIf




		EndIf


		;
		If $MousePos_aPos[1] <= $iY+$C_GUIMenuButton_DefYsize Then
			Local $x_local_pos = _WinAPI_GetMousePosX(True,$GUIMenuButton_h)
			If Not @error And $x_local_pos >= 0 And $x_local_pos <= $C_GUIMenuButton_DefXsize Then

				If $GUMe_WinOptions_hgui <= 0 Then
					If Not $GUIMenuButton_MouseOver Then
						$GUIMenuButton_MouseOver_timer = TimerInit()
						$GUIMenuButton_MouseOver = 1
					EndIf
					If TimerDiff($GUIMenuButton_MouseOver_timer) >= $gcmb_showtimetrigger Then GUIMenuButton_WinOptions($GUIMenuButton_iActiveWin)
				EndIf









			Else
				$GUIMenuButton_MouseOver = 0
			EndIf
		Else
			$GUIMenuButton_MouseOver = 0
		EndIf
	Else
		If $GUIMenuButton_iActiveWin Then
			GUIMenuButton_Delete()
			;$aWins_UpdateNewActiveWin_disable = False
			$GUIMenuButton_iActiveWin = 0

		EndIf



		$GUIMenuButton_MouseOver = 0
	EndIf






EndFunc