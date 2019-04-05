




Func GUIMenuButton_Create($iIndex, $aPos = Default)


	If $iIndex > 0 And Not $aWins[0][0] Then Return SetError(1)

	GUIMenuButton_Delete()


	;$aWins[$iIndex][$C_aWins_idx_AverageColor] = aWins_WinGetAverageColor($iIndex,$pos[0]+Int($C_GUIMenuButton_DefXsize/2)-$aWins[$iIndex][$C_aWins_idx_x_pos]) ; <------------- DISABLED

	Local Const $iFontSize = 25, $BkColor = 0x686968,$iLineSize = 2





	; Create the GUI
	If $aPos = Default Then $aPos = GUIMenuButton_ReturnValidPos($iIndex)


	$GUIMenuButton_h = GUICreate('',$C_GUIMenuButton_DefXsize,$C_GUIMenuButton_DefYsize,$aPos[0],$aPos[1],$WS_POPUP,$WS_EX_TOPMOST,$g_DummyTopGui)
	$GUIMenuButton_hOld = $GUIMenuButton_h

	$GUIMenuButton_hDrag = GUICtrlCreateLabel('',0,0,$C_GUIMenuButton_DefXsize,$C_GUIMenuButton_DefYsize)
	GUICtrlSetCursor(-1, 9)

	$GUIMeBu_Menu = GUICtrlCreateContextMenu($GUIMenuButton_hDrag)
;~ 	_GUICtrlCreateODMenuItem('Run with the software', $GUIMeBu_Menu)
	$GUIMeBu_SaveWinSettings = GUICtrlCreateMenuItem('Save window configuration', $GUIMeBu_Menu)





	; Set Round shape to the GUI
		; Create the [RectRgn] for the GUI
	$hMain_rgn = _WinAPI_CreateRoundRectRgn(0, 0, $C_GUIMenuButton_DefXsize, $C_GUIMenuButton_DefYsize, $C_GUIMenuButton_DefXsize*0.22, $C_GUIMenuButton_DefYsize)
		; Set the [RectRgn] to the GUI
	_WinAPI_SetWindowRgn($GUIMenuButton_h,$hMain_rgn)
	_WinAPI_DeleteObject($hMain_rgn)
	; Done




	Local $iPic = GUICtrlCreatePic('',0,0)
;~ 		GUICtrlSetBkColor($iPic, $GUI_BKCOLOR_TRANSPARENT)

	$GUIMenuButton_hDC = _WinAPI_GetDC($GUIMenuButton_h)

	WinSetTrans($GUIMenuButton_h,'',0)
	GUISetState(@SW_SHOWNOACTIVATE,$GUIMenuButton_h)



	Local $aWPI = WAPI_Create_hDcImage($GUIMenuButton_hDC,$C_GUIMenuButton_DefXsize,$C_GUIMenuButton_DefYsize,$COLOR_WHITE) ; _WinAPI_GetSysColor($COLOR_3DFACE)


	WAPI_DrawEllipsShape($aWPI,$C_GUIMenuButton_DefXsize-$iLineSize/2, $C_GUIMenuButton_DefYsize-$iLineSize/2, _
	($C_GUIMenuButton_DefXsize-2)*0.22,$C_GUIMenuButton_DefYsize-$iLineSize/2,$COLOR_WHITE,$iLineSize,Default,$BkColor)
	;											xsize	ysize
	WAPI_DrawText($aWPI,6,$iFontSize,Default,Default,-7,Default,20, _
	'Webdings',$COLOR_WHITE);,$hBkColor=Default,$iWeight=Default)
	WAPI_SetImageToPic($aWPI,$iPic,$GUIMenuButton_hDC)
	_WinAPI_ReleaseDC($GUIMenuButton_h,$GUIMenuButton_hDC)
	WinSetTrans($GUIMenuButton_h,'',0.5*255)

EndFunc



Func GUIMenuButton_Delete()
	;ConsoleWrite('GUIMenuButton_Delete' &' (L: '&@ScriptLineNumber&')'&@CRLF)
	If $GUIMenuButton_h = -1 Then Return
	;_WinAPI_ReleaseDC($GUIMenuButton_h,$GUIMenuButton_hDC)
	GUIDelete($GUIMenuButton_h)
	$GUIMenuButton_h = -1

	;Return $hMenuButton
EndFunc
Func GUIMenuButton_ReturnValidPos($iIndex)

	Local $x_pos = $aWins[$iIndex][$C_aWins_idx_x_pos]
	Local $y_pos = $aWins[$iIndex][$C_aWins_idx_y_pos]+1
	Local $x_size = $aWins[$iIndex][$C_aWins_idx_x_size]
	Local $y_size = $aWins[$iIndex][$C_aWins_idx_y_size]

	Local $WinState = WinGetState($aWins[$iIndex][$C_aWins_idx_hWin])

	If BitAND($WinState,$WIN_STATE_MAXIMIZED) Then
		$x_pos = 0
		$y_pos = 1

		$tmp = WinGetClientSize($aWins[$iIndex][$C_aWins_idx_hWin])
		If Not @error Then
			$x_size = $tmp[0]
			$y_size = $tmp[1]
		EndIf

	EndIf

;~ 	_ArrayDisplay(WinGetPos($aWins[$iIndex][$C_aWins_idx_hWin]))

	Local $x_pos_final

	Switch $GUMe_xPos_mode

		Case $C_GUMe_xPos_mode_Center
			If Not $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] Then
				$x_pos_final = Round(($x_size/2))-($C_GUIMenuButton_DefXsize/2)
			Else
				$x_pos_final = Round(($x_size*$aWins[$iIndex][$C_aWins_idx_hMB_fixed_x])); -($C_GUIMenuButton_DefXsize/2)
				If $x_pos_final+$C_GUIMenuButton_DefXsize > $x_size Then $x_pos_final = $x_size-$C_GUIMenuButton_DefXsize
				If $x_pos_final <= 0 Then $x_pos_final = 1
			EndIf
		Case $C_GUMe_xPos_mode_Left

			If Not $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] Then
				$x_pos_final = $GUMe_xPosFix
			Else
				$x_pos_final = $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x]
			EndIf


		Case $C_GUMe_xPos_mode_Right


			If Not $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] Then
				$x_pos_final = $x_size-$C_GUIMenuButton_DefXsize-$GUMe_xPosFix
			Else
				$x_pos_final = $x_size-$C_GUIMenuButton_DefXsize-$aWins[$iIndex][$C_aWins_idx_hMB_fixed_x]
			EndIf


			If $x_pos_final <= 0 Then $x_pos_final = 1
	EndSwitch



	Local $Output[2] = [$x_pos+$x_pos_final,$y_pos]
	Return $Output
EndFunc

Func GUIMenuButton_UpdatePosByMouse($iIndex = 1, $x_local_pos = -1)

	If $iIndex > $aWins[0][0] Then Return SetError(3)
	If $x_local_pos = -1 Then $x_local_pos = _WinAPI_GetMousePosX(True,$GUIMenuButton_h)
	If @error Then Return SetError(1)
	Local $hDll_user32 = DllOpen("user32.dll")
	If $hDll_user32 = -1 Then Return SetError(2)
	$mw_mousepos = MouseGetPos()
	Local $mw_finalX,$y_mouse_pos_start = $mw_mousepos[1]
	$GUIMenuButton_iIsDrag = 1
	;If $aWins[1][$C_aWins_idx_x_pos] >= 0 And $aWins[1][$C_aWins_idx_y_pos] >= 0 Then
	If Not BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]),$WIN_STATE_MAXIMIZED) Then
		Local $x_pos = $aWins[$iIndex][$C_aWins_idx_x_pos],$y_pos = $aWins[$iIndex][$C_aWins_idx_y_pos],$x_size = $aWins[$iIndex][$C_aWins_idx_x_size]
	Else
		Local $x_pos = 0,$y_pos = 1,$x_size = @DesktopWidth
		$tmp = WinGetClientSize($aWins[$iIndex][$C_aWins_idx_hWin])
		If Not @error Then $x_size = $tmp[0]
	EndIf
	Do
		$mw_mousepos = MouseGetPos()
		$mw_finalX = $mw_mousepos[0]-$x_local_pos
		If $mw_finalX < $x_pos Then
			$mw_finalX = $x_pos
		Else
			If $mw_finalX > $x_pos+$x_size-$C_GUIMenuButton_DefXsize Then $mw_finalX = $x_pos+$x_size-$C_GUIMenuButton_DefXsize
		EndIf
		;If $mw_finalX < $x_pos Or $mw_finalX > $x_pos+$x_size-$C_GUIMenuButton_DefXsize Then ContinueLoop
		WinMove($GUIMenuButton_h,'',$mw_finalX,$y_pos,$C_GUIMenuButton_DefXsize,$C_GUIMenuButton_DefYsize)
	Until Not _IsPressed('01',$hDll_user32)
	DllClose($hDll_user32)

	Switch $GUMe_xPos_mode
		Case $C_GUMe_xPos_mode_Center
			$aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] = ($mw_finalX-$x_pos)/$x_size
			If $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] <= 0 Then $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] = 1/$x_size

		Case $C_GUMe_xPos_mode_Left
			$aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] = $mw_finalX-$x_pos

		Case $C_GUMe_xPos_mode_Right
			$aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] = $x_size-($mw_finalX-$x_pos)-$C_GUIMenuButton_DefXsize
	EndSwitch

	$GUIMenuButton_iIsDrag = 0
EndFunc




Func GUIMeBu_Menu_Show2($start = 0)

	Local Static $dummy

	If $start Then

		$dummy = GUICtrlCreateDummy()
		$GUIMeBu_Menu = GUICtrlCreateContextMenu($dummy)
	;~ 	_GUICtrlCreateODMenuItem('Run with the software', $GUIMeBu_Menu)
		$GUIMeBu_SaveWinSettings = GUICtrlCreateMenuItem('Save window configuration', $GUIMeBu_Menu)

		BasicShowMenu2($GUIMeBu_Menu)

		;ConsoleWrite(1 &' (L: '&@ScriptLineNumber&')'&@CRLF)

		Do
			ToolTip(2)
		Until GUIGetMsg() = $GUI_EVENT_CLOSE



	EndIf



EndFunc