#include-once
#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <InetConstants.au3>


;Global Const $WIN_STATE_VISIBLE = 2,$WIN_STATE_ACTIVE = 8,$WIN_STATE_MINIMIZED = 16,$WIN_STATE_MAXIMIZED = 32












Func GUIGetXYPosByParentButton(ByRef $x_out, ByRef $y_out, $iTarget_x_size, $iTarget_y_size, $GUIInfo, $ParentButtonInfo)
	Local $aParentGUIPos,$aParentButtonPos

	If Not IsArray($GUIInfo) Then
		$aParentGUIPos = WinGetPos($GUIInfo)
		If @error Then Return SetError(@ScriptLineNumber)
		Local $aTmp = WinGetClientSize($GUIInfo)
		If Not @error Then
			If $aTmp[0] < $aParentGUIPos[2] Then $aParentGUIPos[0] += $aParentGUIPos[2]-$aTmp[0]-2
			If $aTmp[1] < $aParentGUIPos[3] Then $aParentGUIPos[1] += $aParentGUIPos[3]-$aTmp[1]-2
		EndIf
	Else
		$aParentGUIPos = $GUIInfo
	EndIf

	If Not IsArray($ParentButtonInfo) Then
		$aParentButtonPos = ControlGetPos($GUIInfo,'',$ParentButtonInfo)
	Else
		$aParentButtonPos = $ParentButtonInfo
	EndIf

;~
;~ 	If Not IsArray($GUIInfo) Then
;~ 		$aParentGUIPos = WinGetPos($GUIInfo)
;~ 		If @error Then Return SetError(@ScriptLineNumber)
;~ 		Local $aTmp = WinGetClientSize($GUIInfo)
;~ 		If Not @error Then
;~ 			If $aTmp[0] < $aParentGUIPos[2] Then $aParentGUIPos[0] += $aParentGUIPos[2]-$aTmp[0]-2
;~ 			If $aTmp[1] < $aParentGUIPos[3] Then $aParentGUIPos[1] += $aParentGUIPos[3]-$aTmp[1]-2
;~ 		EndIf
;~ 		$aParentButtonPos = ControlGetPos($GUIInfo,'',$ParentButtonInfo)

;~ 		_ArrayDisplay($aParentButtonPos)
;~ 		If @error Then Return SetError(@ScriptLineNumber)
;~ 	Else
;~ 		$aParentGUIPos = $GUIInfo
;~ 		$aParentButtonPos = $ParentButtonInfo
;~ 	EndIf




	;Cal x pos
	CalCenter($x_out,$aParentButtonPos[0]+$aParentGUIPos[0],$aParentButtonPos[2],$iTarget_x_size)
	GUIGetXYPosByParentButton_FixPointPos($x_out,0,@DesktopWidth,$iTarget_x_size,0.1)
	; Cal y pos
	$y_out = $aParentGUIPos[1]+$aParentButtonPos[1]+$aParentButtonPos[3]
	GUIGetXYPosByParentButton_FixPointPos($y_out,0,@DesktopHeight,$iTarget_y_size,0.08)
EndFunc

Func CalCenter(ByRef $Out,$iParentPos,$iParentSize,$iTargetSize)
	If $iParentSize <> $iTargetSize Then
		$Out = $iParentPos+Round($iParentSize/2)-Round($iTargetSize/2)
	Else
		$Out = $iParentPos
	EndIf
EndFunc

Func GUIGetXYPosByParentButton_FixPointPos(ByRef $p_out,$iMin,$iMax,$iTargetSize,$fFix)
	If $p_out >= $iMin And $p_out+$iTargetSize <= $iMax Then Return
	Local $iFix = Round($iMax*$fFix)
	If $p_out < $iMin Then
		If $p_out >= $iFix*-1 Then $p_out = $iMin
	Else
		If $p_out <= $iMax+$iFix Then $p_out = $iMax-$iTargetSize
	EndIf
EndFunc

Func WAPI_Create_hDcImage($DC,$x_size,$y_size,$BkColor = 0xFFFFFF)
	Local $aOutput[4]
	Local $hDC = _WinAPI_CreateCompatibleDC($DC) ; $hDC = The main object....
	; Create $hSource
	Local $hSource = _WinAPI_CreateCompatibleBitmapEx($DC, $x_size, $y_size, $BkColor)

	Local $PreviousObject = _WinAPI_SelectObject($hDC, $hSource)
	;_WinAPI_DeleteObject($PreviousObject)

	$aOutput[0] = $hDC
	$aOutput[1] = $hSource
	$aOutput[2] = $x_size
	$aOutput[3] = $y_size
	Return $aOutput
EndFunc

Func WAPI_DrawText(ByRef $aWPI,$sText,$sFontSize=Default,$iFlags=Default,$x_pos=Default,$y_pos=Default,$x_size=Default,$y_size=Default, _
	$sFont=Default,$Color=Default,$hBkColor=Default,$iWeight=Default)

	If $sFontSize = Default Then $sFontSize = 12
	If $iFlags = Default Then $iFlags = $DT_CENTER
	If $x_pos = Default Then $x_pos = 0
	If $y_pos = Default Then $y_pos = 0
	If $x_size = Default Then $x_size = $aWPI[2]
	If $y_size = Default Then $y_size = $aWPI[3]
	If $sFont = Default Then $sFont = 'Arial'
	If $Color = Default Then $Color = 0
	If $iWeight = Default Then $iWeight = $FW_NORMAL


	Local $tRECT = DllStructCreate($tagRect)
	DllStructSetData($tRECT, "Left", $x_pos)
	DllStructSetData($tRECT, "Top", $y_pos)
	DllStructSetData($tRECT, "Right", $x_pos+$x_size)
	DllStructSetData($tRECT, "Bottom", $y_pos+$y_size)

	Local $hFont = _WinAPI_CreateFont($sFontSize, 0, 0, 0, $iWeight, False, False, False, $DEFAULT_CHARSET, _
	$OUT_DEFAULT_PRECIS, $CLIP_DEFAULT_PRECIS, $DEFAULT_QUALITY, 0, $sFont)

	_WinAPI_SelectObject($aWPI[0], $hFont)

	If $Color Then _WinAPI_SetTextColor($aWPI[0], $Color)

	If $hBkColor = Default Then
		_WinAPI_SetBkMode($aWPI[0], $TRANSPARENT)

	Else
		_WinAPI_SetBkColor($aWPI[0], $hBkColor)
	EndIf

	_WinAPI_DrawText($aWPI[0], $sText, $tRECT, $iFlags)
EndFunc

Func WAPI_SetImageToPic(ByRef $aWPI,$iPic,$hDev = 0,$hGUI = 0)

	Local Const $STM_SETIMAGE = 0x0172,$STM_GETIMAGE = 0x0173

	Local $Relese_hDev

	If Not $hDev Then
		$hDev = _WinAPI_GetDC($hGUI)
		$Relese_hDev = 1
	EndIf


	; Create  $hBitmap
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDev,$aWPI[2], $aWPI[3])



	; <------------------------ Working on $hBitmap --------------------------->
	_WinAPI_SelectObject($aWPI[0], $hBitmap)
	; Draw the result($hSource) on [empty bitmap]
	_WinAPI_DrawBitmap($aWPI[0], 0, 0, $aWPI[1], $MERGECOPY)



	; Delete $hSource & $hDC because it is not needed anymore
	_WinAPI_DeleteObject($aWPI[1])
	_WinAPI_DeleteDC($aWPI[0])
	$aWPI = 0

	Local $hPic = GUICtrlGetHandle($iPic)
	; Set $hBitmap to control
	_SendMessage($hPic, $STM_SETIMAGE, 0, $hBitmap)
	_WinAPI_DeleteObject($hBitmap)

	If $Relese_hDev Then _WinAPI_ReleaseDC($hGUI,$hDev)
	If _SendMessage($hPic, $STM_GETIMAGE) <> $hBitmap Then Return SetError(@ScriptLineNumber)

EndFunc

Func WAPI_DrawEllipsShape(ByRef $aWPI,$x_size, $y_size,$iWidthEllipse,$iHeightEllipse,$PenColor = Default,$iPenWidth=Default,$iPenStyle=Default,$BkColor = Default,$x_pos=Default,$y_pos=Default)

	Local $PreviousObject, $oOldBrush,$hPen
	If $PenColor <> Default Or $iPenWidth <> Default Or $iPenStyle <> Default Then
		If $PenColor = Default Then $PenColor = $COLOR_BLACK
		If $iPenWidth = Default Then $iPenWidth = 1
		If $iPenStyle = Default Then $iPenStyle = $PS_SOLID
		$hPen = _WinAPI_CreatePen($iPenStyle, $iPenWidth, $PenColor)
		$PreviousObject = _WinAPI_SelectObject($aWPI[0], $hPen) ; $PreviousObject is the old object pen and it was deleted
		_WinAPI_SetDCPenColor($aWPI[0], $PenColor)
		_WinAPI_DeleteObject($PreviousObject)
	EndIf

	If $BkColor <> Default Then
		$oOldBrush = _WinAPI_SelectObject($aWPI[0], _WinAPI_GetStockObject($DC_BRUSH))
		_WinAPI_SetDCBrushColor($aWPI[0], $BkColor)
	EndIf

	; Create RoundRect
	If $x_pos = Default Then $x_pos = 0
	If $y_pos = Default Then $y_pos = 0
	Local $tRECT = _WinAPI_CreateRect($x_pos, $y_pos, $x_size, $y_size)
	_WinAPI_RoundRect($aWPI[0], $tRECT, $iWidthEllipse, $iHeightEllipse)

	If $oOldBrush Then
		$PreviousObject = _WinAPI_SelectObject($aWPI[0], $oOldBrush)
		_WinAPI_DeleteObject($PreviousObject)
	EndIf

	If $hPen Then _WinAPI_DeleteObject($hPen)

EndFunc

Func GUICreateSquareFrameForCtrl($hGUI,$hCtrl,$hex_color = 0)
	$ctrl_pos = ControlGetPos($hGUI,'',$hCtrl)

	;_ArrayDisplay($ctrl_pos)
	If @error Then Return SetError(1)
	GUICreateSquareFrame($ctrl_pos[0]-1,$ctrl_pos[1]-1,$ctrl_pos[2]+2,$ctrl_pos[3]+2,$hex_color)
EndFunc
Func GDICreateSquareFrameForCtrl($hGUI,$hGraphic,$hCtrl,$hex_rgba_color = 0xFF000000,$iLineWidth = 1)
	$ctrl_pos = ControlGetPos($hGUI,'',$hCtrl)

	;_ArrayDisplay($ctrl_pos)
	If @error Then Return SetError(1)
	GDIPCreateSquareFrame($hGraphic,$ctrl_pos[0],$ctrl_pos[1],$ctrl_pos[2],$ctrl_pos[3],$iLineWidth,$hex_rgba_color)
EndFunc
Func GUICreateSquareFrame($x_pos,$y_pos,$x_size,$y_size,$hex_color = 0)
	Local $Output = GUICtrlCreateGraphic($x_pos,$y_pos,Default,Default,0)
	If $hex_color Then GUICtrlSetGraphic(-1, $GUI_GR_COLOR,$hex_color) ; 0x00A300
	GUICtrlSetGraphic(-1, $GUI_GR_RECT,0,0,$x_size,$y_size)
	Return $Output
EndFunc
Func _GUICtrlButton_Type_A_Create($rImage,$x_pos,$y_pos,$x_size,$y_size,$hex_color = 0)
	Local $Output[2]
	$Output[1] = GUICtrlCreateGraphic($x_pos-1,$y_pos-1,Default,Default,0)
	If $hex_color Then GUICtrlSetGraphic(-1, $GUI_GR_COLOR,$hex_color) ; 0x00A300
	GUICtrlSetGraphic(-1, $GUI_GR_RECT,0,0,$x_size+2,$y_size+2)

	$Output[0] = GUICtrlCreatePic('',$x_pos,$y_pos,$x_size,$y_size)
	GUICtrlSetCursor(-1,0)

	_ResourceSetImageToCtrl($Output[0],$rImage)

;~ 	$Output[0] = GUICtrlCreateLabel('',$x_pos,$y_pos,$x_size,$y_size)
;~ 	GUICtrlSetBkColor($Output[0],0xe58d03)


	Return $Output
EndFunc



Func CreateLayerForWin($hWin,$aPos,$hParent = 0)
	Local $layer_pos = CreateLayerForWin_ReturnValidPos($hWin,$aPos)
	Return GUICreateLayer($layer_pos[0],$layer_pos[1],$layer_pos[2],$layer_pos[3],$hParent)
EndFunc
Func CreateLayerForWin_ReturnValidPos($hWin,$aPos = -1)
	If BitAND(WinGetState($hWin), $WIN_STATE_MAXIMIZED) Then
		Local $aOutput[5] = [0,0,@DesktopWidth,@DesktopHeight]
	Else
		If IsArray($aPos) Then Return $aPos
		Local $aOutput = WinGetPos($hWin)
		If @error Then Return SetError(1)
	EndIf
	Return $aOutput
EndFunc
Func GUICreateLayer($x_pos,$y_pos,$x_size,$y_size,$hParent = 0)
	;Local $Output[2]
	$Output = GUICreate('', $x_size, $y_size, $x_pos, $y_pos,0x80000000, BitOR(0x08000000, 0x080000, 0x80, 0x20),$hParent);,WinGetHandle(AutoItWinGetTitle()))
	GUISetBkColor($COLOR_BLACK,$Output)
	;$Output[0] = GUICreate('',$x_size,$y_size,$x_pos,$y_pos,0x80000000, -1,0)

	_WinAPI_SetLayeredWindowAttributes($Output, 0, 255, 0x02, 0)
	;WinSetOnTop($Output[0],'',1)
	;GUISetBkColor($COLOR_BLUE,$Output[0])

	;GUISetState(@SW_SHOWNOACTIVATE,$Output)

	Return $Output
;~ 	$Output[1] = _GuiCtrlCreateMagnify($Output[0],@DesktopWidth,@DesktopHeight,0,0,False)
;~ 	_MagnifierSetSource($Output[1], $x_pos, $y_pos, $x_pos+$x_size, $y_pos+$y_size)
;~ 	_MagnifierSetInvertColorsStyle($Output[1],True)
;~ 	Return $Output
EndFunc
Func GUICreateMagnifierCtrl($hGUI,$x_pos,$y_pos,$x_size,$y_size)
	_MagnifierInit()
	$hMagCtrl = _GuiCtrlCreateMagnify($hGUI,@DesktopWidth,@DesktopHeight,0,0,False)
	_MagnifierSetSource($hMagCtrl, $x_pos, $y_pos, $x_pos+$x_size, $y_pos+$y_size)
	_MagnifierSetInvertColorsStyle($hMagCtrl,True)
	Return $hMagCtrl
EndFunc
Func GUICreateHole($hGUI,$CreateHole,$x1=Default,$x2=Default,$y1=Default,$y2=Default,$gui_x_size=Default,$gui_y_size=Default)

	If $CreateHole Then
		GUICreateHole_int1($hGUI,$gui_x_size,$gui_y_size)
		If @error Then Return SetError(@error)
	Else
		$gui_x_size = @DesktopWidth*2
		$gui_y_size = @DesktopHeight*2
	EndIf



	Local $hMain_rgn = _WinAPI_CreateRectRgn(0,0,$gui_x_size,$gui_y_size)

	If $CreateHole Then
		Local $hAdd_rgn = _WinAPI_CreateRectRgn($x1, $y1, $x2, $y2)
		_WinAPI_CombineRgn($hMain_rgn, $hMain_rgn,$hAdd_rgn , $RGN_DIFF)
		_WinAPI_DeleteObject($hAdd_rgn)
	EndIf

	_WinAPI_SetWindowRgn($hGUI,$hMain_rgn)
	_WinAPI_DeleteObject($hMain_rgn)
EndFunc
; $aHoles: [n][0]=x1,[n][1]=x2,[n][2]=y1,[n][3]=y2
Func GUICreateHolesByArray($hGUI,$aHoles,$gui_x_size = Default ,$gui_y_size = Default)

	GUICreateHole_int1($hGUI,$gui_x_size,$gui_y_size)
	If @error Then Return SetError(@error)


	Local $hMain_rgn = _WinAPI_CreateRectRgn(0,0,$gui_x_size,$gui_y_size), $hAdd_rgn

	For $a = 1 To $aHoles[0][0]
		$hAdd_rgn = _WinAPI_CreateRectRgn($aHoles[$a][0], $aHoles[$a][2], $aHoles[$a][1], $aHoles[$a][3])
		_WinAPI_CombineRgn($hMain_rgn, $hMain_rgn,$hAdd_rgn , $RGN_DIFF)
		_WinAPI_DeleteObject($hAdd_rgn)
	Next
	_WinAPI_SetWindowRgn($hGUI,$hMain_rgn)
	_WinAPI_DeleteObject($hMain_rgn)
EndFunc
Func GUICreateHole_int1($hGUI, ByRef $gui_x_size, ByRef $gui_y_size)
	If $gui_x_size = Default Or $gui_y_size = Default Then
		Local $pos = WinGetPos($hGUI)
		If @error Then Return SetError(@ScriptLineNumber)
		$gui_x_size = $pos[2]
		$gui_y_size = $pos[3]
	EndIf

EndFunc
Func IsPosNew($aNewPos,$aOldPos,$iSaveOutput = 0)
	Local Static $iSavedOutput
	If $iSavedOutput And Not $iSaveOutput Then Return $iSavedOutput
	Local $Output
	If $aNewPos[0] <> $aOldPos[0] Or $aNewPos[1] <> $aOldPos[1] Then $Output = 1
	If $iSaveOutput Then $iSavedOutput = $Output
EndFunc
Func IsPointInSquare($x,$y,$x1,$x2,$y1,$y2)
	If $x >= $x1 And $x <= $x2 And $y >= $y1 And $y <= $y2 Then Return 1
EndFunc
Func _WinIsOnTop($hWnd)
    If IsHWnd($hWnd) = 0 And WinExists($hWnd) Then $hWnd = WinGetHandle($hWnd)
	$hWinStyle = _WinAPI_GetWindowLong ($hWnd,$GWL_EXSTYLE)
	If @error Then Return SetError(1)
    If BitAND($WS_EX_TOPMOST,$hWinStyle) Then Return 1
EndFunc
Func Array1DSearch($aArray,$sDlem1,$Dimension,$StartIndex = 1, $EndIndex = 0)
	If Not $EndIndex Then $EndIndex = UBound($aArray)-1
	Local $tmp1
	For $a = $StartIndex To $EndIndex
		$tmp1 = StringSplit($aArray[$a],$sDlem1,1)
		If $tmp1[0] <= 1 Then ContinueLoop

	Next
EndFunc
;~ Func Area_Average_Color($x_pos,$y_pos,$x_size,$y_size,$hWnd = 0,$bRetunAsHex = 1)
;~ 	Local $Output = -1,$hHBmp
;~ 	If Not $hWnd Then
;~ 		$hHBmp = _ScreenCapture_Capture('', $x_pos, $y_pos, $x_pos+$x_size, $y_pos+$y_size,False) ;create a GDI bitmap by capturing full screen of the desktop
;~ 	Else
;~ 		$hHBmp = _ScreenCapture_CaptureWnd('',$hWnd,$x_pos,$y_pos,$x_pos+$x_size,$y_pos+$y_size,False)
;~ 	EndIf

;~ 	If @error Then Return SetError(1,0,0)
;~ 	Local $hBitmap = _GDIPlus_BitmapCreateFromHBITMAP($hHBmp) ;convert GDI bitmap to GDI+ bitmap
;~ 	If Not @error Then
;~ 		$Output = GetAverageColorFromGDIPlusImage($hBitmap,$bRetunAsHex)
;~ 		 _GDIPlus_BitmapDispose($hBitmap) ; release $hBitmap
;~ 	EndIf

;~ 	If $Output = -1 Then Return SetError(1,0,0)
;~ 	Return $Output
;~ EndFunc



Func GetAverageColorFromGDIPlusImage($hBitmap,$bRetunAsHex = 1)
	Local $Output = -1, _
	$hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, 1, 1) ;resize image to 1x1
	If Not @error Then
		$Output = _GDIPlus_BitmapGetPixel($hBitmap_Scaled,0,0) ; Get color of the 1x1 pixel
		If Not @error Then
			If $bRetunAsHex Then $Output = '0x'&Hex($Output,6)
		EndIf
		_GDIPlus_BitmapDispose($hBitmap_Scaled) ; release $hBitmap_Scaled
	EndIf
	If $Output = -1 Then Return SetError(1,0,0)
	Return $Output
EndFunc




Func GetSet($Sec,$Key,$Def)
	$tmp = StringStripWS(IniRead($ini,$Sec,$Key,$Def),3)
	If Not $tmp Then $tmp = $Def
	Return $tmp
EndFunc

Func OnExit()

	; Restore previous windows state

	$bIsExiting = True

		For $a = 1 To $aWins[0][0]

			If $bRunFeatureInThislProcess Or $bIsExternalProcess Then
			; Delete the layer that used for "SET DARK"
				GUIDelete($aWins[$a][$C_aWins_idx_hMask])
			; Disable "shrink"
				If $aWins[$a][$C_aWins_idx_Shrink_hGUI] Then aWins_Shrink($a,False)
			EndIf

			If Not $bIsExternalProcess Then
			; Save some settings to the ini
				aWins_SaveSettings($a)

			; Restore "SET TOP"
				If Number($aWins[$a][$C_aWins_idx_IsTop]) <> Number($aWins[$a][$C_aWins_idx_IsTop_old]) Then _
				aWins_SetOnTop($a,$aWins[$a][$C_aWins_idx_IsTop_old])

			; Restore Opacity level
				If $aWins[$a][$C_aWins_idx_opacitylevel] <> $aWins[$a][$C_aWins_idx_opacitylevel_old] Then
					If Not $aWins[$a][$C_aWins_idx_opacitylevel_old] Then $aWins[$a][$C_aWins_idx_opacitylevel_old] = 100
					aWins_Opacity_SetLevel($a,$aWins[$a][$C_aWins_idx_opacitylevel_old])
				EndIf
			; Disable "click through"
				If $aWins[$a][$C_aWins_idx_IsClickThrough] Then aWins_ToggleClickThrough($a,0)



			EndIf




		Next


	;If $AppHelper_Soldier_iPid Then ProcessClose($AppHelper_Soldier_iPid)
	If $AppHelper_CPP_Soldier_iPid Then ProcessClose($AppHelper_CPP_Soldier_iPid)



	; Un init magnifier
		If $bRunFeatureInThislProcess Or $bIsExternalProcess Then
			_MagnifierUnInit()
		Else

			If $AppHelper_Soldier_iPid Then ; Case when some features was runned in external process
				Jobs_CallAction($AppHelper_Soldier_hCommunicationGUI, $C_AppHelper_Soldier_Action_ExitEvent)
			EndIf
		EndIf

;~ 		DllClose($Software_U32Dll)
		If Not $bIsExternalProcess Then _GDIPlus_Shutdown()


	Settings_Save()


EndFunc


Func InstallStartup()
	Return _StartupFolder_Install(@ScriptName,@ScriptFullPath,'startup');,'delay_run')
EndFunc

Func BasicShowMenu2($nContextID)
	DllCall("user32.dll", "int", "TrackPopupMenuEx", "hwnd", GUICtrlGetHandle($nContextID), "int", 0, "int", $MousePos_aPos[0], "int", $MousePos_aPos[1], "hwnd", $g_DummyTopGui, "ptr", 0)
EndFunc   ;==>ShowMenu




Func AskForSurvey($bStart = False)

	Local Static $hGUI, $Continue_Button, $Close_Button, $DoNotShow_Checkbox, $bNotShowAgain

	If $bStart Then


		If $SellSoftSys_bIsActivated Or $SellSoftSys_bIsTrailMode Or Not Number(GetSet('Messages','AskForSurvey',1)) Then
			TriggerEvery_RemoveCurrentFunc()
			TriggerEvery_CallNextFunc()
			Return
		EndIf



		Local $iDaysPassed
		If $SellSoftSys_TrialRegisterTime Then
			$iDaysPassed = $SellSoftSys_iTrialModeDaysDiff
		Else
			$iFirstUseTimeDaysDiff = GetSet('Main','FirstUseTime','')
			If $iFirstUseTimeDaysDiff Then
				$iDaysPassed = _DateDiff ('d', $iFirstUseTimeDaysDiff, _NowCalc())
			Else
				IniWrite($ini,'Main','FirstUseTime',_NowCalc())
				$iDaysPassed = 0
			EndIf
		EndIf

		If $iDaysPassed < 45 Then
			TriggerEvery_CallNextFunc()
			Return
		EndIf

		$bNotShowAgain = False

		$hGUI = GUICreate("WindowTop survey", 547, 239)
		GUICtrlCreateLabel("Seems that you are using WindowTop for quite a long time."&@CRLF&@CRLF& _
							"Please fill in a quick (about 5 questions) survey", 8, 8, 527, 121)
		GUICtrlSetFont(-1, 18, 400, 0, "Tahoma")
		$Continue_Button = GUICtrlCreateButton("Continue to survey", 16, 192, 353, 33)
		GUICtrlSetFont(-1, 12, 800, 0, "Tahoma")
		$Close_Button = GUICtrlCreateButton("Close", 392, 192, 129, 33)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
		$DoNotShow_Checkbox = GUICtrlCreateCheckbox("Do not show me this message again", 16, 152, 361, 25)
		GUICtrlSetFont(-1, 14, 400, 0, "Tahoma")
		GUISetState(@SW_SHOW)

		aExtraFuncCalls_AddFunc(AskForSurvey)

		Return

	EndIf


	If $Software_MSG[1] <> $hGUI Then Return


	Switch $Software_MSG[0]
		Case $Continue_Button

			$bNotShowAgain = True
			ShellExecute('http://windowtop.info/windowtop-user-feedback-survey/')

			ContinueCase
		Case $Close_Button, $GUI_EVENT_CLOSE

			If $bNotShowAgain Or GUICtrlRead($DoNotShow_Checkbox) = $GUI_CHECKED Then _
				IniWrite($ini,'Messages','AskForSurvey',0)

			GUIDelete($hGUI)
			TriggerEvery_RegisterCallNextFunc()
			Return True
	EndSwitch

EndFunc

#Region CheckForUpdates

	Func CheckForUpdates($bStart = False)
		Local Static $timer, $tmpfile = $ProgramDataDir&'\check_update.xml', $hDownload, _
		$aCheckURLs[] = ['http://windowtop.info/category/stable_versions/feed/', 'http://windowtop.info/category/beta_versions/feed/'] , _
		$aCheckURLs_iIndex = -1


		If $bStart Then

			FileDelete($tmpfile)

			$aCheckURLs_iIndex += 1

			If $aCheckURLs_iIndex > UBound($aCheckURLs)-1 Then
				$aCheckURLs_iIndex = -1
				TriggerEvery_RegisterCallNextFunc()
				Return True
			EndIf

			If Not $aCheckURLs_iIndex Then
				Local $LastCheckTime = GetSet('Other','Updates_LastCheck',Null)
				If $LastCheckTime And _DateDiff('d', $LastCheckTime, _NowCalc()) < 3 Then
					$aCheckURLs_iIndex = -1
					TriggerEvery_CallNextFunc()
					Return True
				EndIf
				aExtraFuncCalls_AddFunc(CheckForUpdates)
			EndIf

			$hDownload = InetGet($aCheckURLs[$aCheckURLs_iIndex],$tmpfile,$INET_FORCERELOAD,$INET_DOWNLOADBACKGROUND)
			$timer = TimerInit()

			Return
		EndIf



		If InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE) Then
			InetClose($hDownload)



			$tmp = CheckForUpdates_step2($tmpfile)
			FileDelete($tmpfile)

			If $tmp Then
				$aCheckURLs_iIndex = -1
				IniWrite($ini,'Other','Updates_LastCheck',_NowCalc())

				ConsoleWrite("TriggerEvery_RegisterCallNextFunc" & @CRLF)
				TriggerEvery_RegisterCallNextFunc()


				Return True ; remove the function from aExtraFuncCalls
			Else
				Return CheckForUpdates(True)
			EndIf

		EndIf

		If TimerDiff($timer) > 10000 Then
			InetClose($hDownload)
			Return CheckForUpdates(True)
		EndIf


	EndFunc



	Func CheckForUpdates_step2($sUpdateFilePath)
		;$TriggerEveryUpdates_TtmpFile = 'windowtop.info.txt'
		Local $sFileRead = FileRead($sUpdateFilePath)
		If @error Then Return SetError(1)

		Local $aItems = XMLTags_GetList($sFileRead, 'item')
		If Not IsArray($aItems) Then Return SetError(2)


		Local $sInternetVer

		For $a = 0 To UBound($aItems)-1
			$tmp = XMLTags_GetList($aItems[$a], 'title')


			If @error Then ContinueLoop
			For $a2 = 0 To UBound($tmp)-1



				; Get the ver number
				$tmp2 = StringSplit($tmp[$a2],'v',1)
				If $tmp2[0] <> 2 Then ContinueLoop

				If Not StringIsDigit(StringLeft($tmp2[2],1)) Then ContinueLoop
				$sInternetVer = StringSplit($tmp2[2],' ',1)[1]


				If CheckForUpdates_IsVerNewer($sInternetVer) Then
					If MsgBox ( $MB_YESNO,'WindowTop - New version released', 'A new version has been released ('&$sInternetVer&')'&@CRLF& _
					'Would you like to download it now?') = $IDYES Then
						ShellExecute($C_DownloadPage)
					EndIf

					Return True
				EndIf

			Next


		Next

	EndFunc

	Func CheckForUpdates_IsVerNewer($sInternetVer)
		; Get only the ver number
			; Get the ver number from $sInternetVer
				$sInternetVer = CheckForUpdates_IsVerNewer_GetVerOnly($sInternetVer)

			; Get the ver number from the the software
				Local $sSoftwareVer = CheckForUpdates_IsVerNewer_GetVerOnly($ProgramVersion_Text)

		; Set imax ..
			Local $aInternetVer = StringSplit($sInternetVer,'.',1)
			Local $aSoftwareVer = StringSplit($sSoftwareVer,'.',1)


		; compere

			For $a = 1 To 4
				If $aInternetVer[0] >= $a Then
					If $aSoftwareVer[0] < $a Then
						Return True
					Else
						If $aInternetVer[$a] > $aSoftwareVer[$a] Then
							Return True
						ElseIf $aInternetVer[$a] < $aSoftwareVer[$a] Then
							Return False
						EndIf
					EndIf
				EndIf
			Next


	EndFunc

	Func CheckForUpdates_IsVerNewer_GetVerOnly($sVerText)
		; Get the ver number from $sVerText
			If StringLeft($sVerText,1) = 'v' Then $sVerText = StringTrimLeft($sVerText,1) ; Remove the 'v'
			$sVerText = StringSplit($sVerText,'-',1)[1] ; Remove the *-*
			Return $sVerText
	EndFunc


#EndRegion





Func ToggleClickThrough_OpacityWins()
	If $ToggleClickThrough_OpacityWins_bActive Then
		$ToggleClickThrough_OpacityWins_bActive = False
		ToolTipTimeOut('"Click through" mode DISABLED for any transparent windows')
	Else
		$ToggleClickThrough_OpacityWins_bActive = True
		ToolTipTimeOut('"Click through" mode ENABLED for any transparent windows')
	EndIf

	aWins_ToggleClickThrough_OpacityWins($ToggleClickThrough_OpacityWins_bActive)

EndFunc

Func  ToggleOpacityForActiveWin()
	; Get the active window
	Local $hWin = WinGetHandle("[ACTIVE]")
	For $a = 1 To $aWins[0][0]
		If $aWins[$a][$C_aWins_idx_hWin] <> $hWin Then ContinueLoop

		aWins_Opacity_OnOff($a)

		ExitLoop
	Next

EndFunc

Func ToggleTopForActiveWin()
	Local $hWin = WinGetHandle("[ACTIVE]")
	For $a = 1 To $aWins[0][0]
		If $aWins[$a][$C_aWins_idx_hWin] <> $hWin Then ContinueLoop
		If $aWins[$a][$C_aWins_idx_IsTop] Then
			aWins_SetOnTop($a,False)
			ToolTipTimeOut('Active window unset on top')
		Else
			aWins_SetOnTop($a,True)
			ToolTipTimeOut('Active window set on top')
		EndIf

		ExitLoop
	Next

EndFunc


Func ToggleShrinkWin()
	Local Static $hLastShrinked = 0

	Local $hWin = WinGetHandle("[ACTIVE]")

	For $a = 1 To $aWins[0][0]
		If $aWins[$a][$C_aWins_idx_hWin] <> $hWin Then ContinueLoop
		If $aWins[$a][$C_aWins_idx_Shrink_hGUI] Then Return
		aWins_Shrink($a,1)
		$hLastShrinked = $aWins[$a][$C_aWins_idx_hWin]
		WinActivate($g_DummyTopGui)

		If $GUMe_WinOptions_hgui <> -1 Then
			GUIMenuButton_WinOptions_remove()
			aExtraFuncCalls_RemoveFunc(GUIMenuButton_WinOptions)
		EndIf

		If $GUIMenuButton_h <> -1 Then
			GUIMenuButton_Delete()
			$mb_pos = Null
		EndIf

		Return
	Next

	If Not $hLastShrinked Then Return

	For $a = 1 To $aWins[0][0]
		If $aWins[$a][$C_aWins_idx_hWin] <> $hLastShrinked Then ContinueLoop
		aWins_Shrink($a,0)
		ExitLoop
	Next

	$hLastShrinked = 0

EndFunc




Func Capture_Window($hWnd, $ReturnAsGDI, $w = 0, $h = 0)


	;_GDIPlus_BitmapDispose($hBmp) ;otherwise memory leak
	;_WinAPI_DeleteObject($hBitmap_s)
	$undo_chk = False
	Local $hDC_Capture = _WinAPI_GetDC(HWnd($hWnd))
;~ 	If Not $hDC_Capture Then Return SetError(1)

	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
;~ 	If Not $hMemDC Then
;~ 		_WinAPI_ReleaseDC($hWnd, $hDC_Capture)
;~ 		Return SetError(2)
;~ 	EndIf

	Local $hBitmap_s = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $w, $h)
;~ 	If Not $hBitmap_s Then
;~ 		_WinAPI_DeleteDC($hMemDC)
;~ 		_WinAPI_ReleaseDC($hWnd, $hDC_Capture)
;~ 		Return SetError(3)
;~ 	EndIf

	Local $hObjectOld = _WinAPI_SelectObject($hMemDC, $hBitmap_s)
	DllCall($__g_hGDIPDll, "int", "SetStretchBltMode", "hwnd", $hDC_Capture, "uint", 4)
	Local $at = DllCall($user32_dll, "int", "PrintWindow", "hwnd", $hWnd, "handle", $hMemDC, "int", 0)

	_WinAPI_DeleteDC($hMemDC)
	_WinAPI_SelectObject($hMemDC, $hObjectOld)
	_WinAPI_ReleaseDC($hWnd, $hDC_Capture)

	If $ReturnAsGDI Then
		Local $hGDIbitmap = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap_s)
		_WinAPI_DeleteObject($hBitmap_s)
		Return $hGDIbitmap
	Else
		Return $hBitmap_s
	EndIf

;~ 	Exit DebugGDI_OpenImage($hBmp)
;~ 	Return $hBmp

EndFunc   ;==>Capture_Window




#Region Pro Features


#EndRegion





