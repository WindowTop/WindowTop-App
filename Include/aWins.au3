


Func aWins_UpdateNewWinPos($iIndex);,$x_pos,$y_pos,$x_size,$y_size)
;~ 	Return
	Local Const $iMaxTime = 350
	If BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]), $WIN_STATE_MINIMIZED) Then Return
	Local $aPos = WinGetPos($aWins[$iIndex][$C_aWins_idx_hWin])
	If @error Then Return SetError(1)
	If $aPos[0] <> $aWins[$iIndex][$C_aWins_idx_x_pos] Or $aPos[1] <> $aWins[$iIndex][$C_aWins_idx_y_pos] Or $aPos[2] <> $aWins[$iIndex][$C_aWins_idx_x_size] _
	Or $aPos[3] <> $aWins[$iIndex][$C_aWins_idx_y_size] Then

		$aWins[$iIndex][$C_aWins_idx_x_pos] = $aPos[0]
		$aWins[$iIndex][$C_aWins_idx_y_pos] = $aPos[1]
		$aWins[$iIndex][$C_aWins_idx_x_size] = $aPos[2]
		$aWins[$iIndex][$C_aWins_idx_y_size] = $aPos[3]

		If $bRunFeatureInThislProcess Or $bIsExternalProcess Then
			Local $layer_pos = CreateLayerForWin_ReturnValidPos($aWins[$iIndex][$C_aWins_idx_hWin],$aPos)
			If $aWins[$iIndex][$C_aWins_idx_hMask] Then WinMove($aWins[$iIndex][$C_aWins_idx_hMask],'',$layer_pos[0],$layer_pos[1],$layer_pos[2],$layer_pos[3])
			If $aWins[$iIndex][$C_aWins_idx_hMask_hMag] Then WinMove($aWins[$iIndex][$C_aWins_idx_hMask_hMag],'',0,0,$layer_pos[2],$layer_pos[3])
			If $aWins_Shrink_LastGUI And _WinIsOnTop($aWins[$iIndex][$C_aWins_idx_hWin]) Then WinSetOnTop($aWins_Shrink_LastGUI,Null,True)
		EndIf


		If Not $bIsExternalProcess Then
			If Not $GUIMenuButton_bDisableUpdatePos And $GUIMenuButton_h > 0 Then
				Local $pos = GUIMenuButton_ReturnValidPos($iIndex)
				WinMove($GUIMenuButton_h,'',$pos[0],$pos[1],$C_GUIMenuButton_DefXsize,$C_GUIMenuButton_DefYsize)
			EndIf
		EndIf

		If Not $g_mw_IsNewWinPos Then $g_mw_IsNewWinPos = 1

		$g_mw_IsNewWinPos_timer = TimerInit()
	Else
		If $g_mw_IsNewWinPos And TimerDiff($g_mw_IsNewWinPos_timer) >= $iMaxTime Then $g_mw_IsNewWinPos = 0
	EndIf
EndFunc
Func aWins_Update()

	; Get window list into 2D array
	Local $l_aWins = WinList("[REGEXPTITLE:[A-Za-z0-9]]")


	If Not $GUIMenuButton_iActiveWin Then

		; Remove closed wins from the main array
		If $aWins[0][0] Then





			Local $a = 1
			Do
				If Array2DSearch($l_aWins, HWnd($aWins[$a][$C_aWins_idx_hWin]),1,1,$l_aWins[0][0]) > 0 Then
					$a += 1
				Else
					If $GUIMenuButton_h Then GUIMenuButton_Delete()
					aWins_Remove($a)
				EndIf
			Until $a > $aWins[0][0]

		EndIf
	EndIf

	; Add new wins to the main array
	aWins_UpdateNewWins($l_aWins)
EndFunc

Func aWins_UpdateNewWins($l_aWins = -1)

	If $l_aWins = -1 Then $l_aWins = WinList("[REGEXPTITLE:[A-Za-z0-9]]")
	For $a = 1 To $l_aWins[0][0]
		If $l_aWins[$a][0] <> 'Start' And $l_aWins[$a][0] <> 'Program Manager' And BitAND(WinGetState($l_aWins[$a][1]), $WIN_STATE_VISIBLE) _
			And Not BitAND(WinGetState($l_aWins[$a][1]), $WIN_STATE_MINIMIZED) And _WinAPI_GetParent($l_aWins[$a][1]) <> $g_DummyTopGui And _
			_ArraySearch($aWins,$l_aWins[$a][1],1,$l_aWins[0][0],0,0,1,$C_aWins_idx_hWin) < 0 Then

			Local $aTipList = WinList("[CLASS:tooltips_class32;REGEXPTITLE:[A-Za-z0-9]]")
			If _ArraySearch($aTipList,$l_aWins[$a][1],1,$l_aWins[0][0],0,0,1,1) < 0 Then
				aWins_Add($l_aWins[$a][1],BitAND(WinGetState($l_aWins[$a][1]), $WIN_STATE_ACTIVE))
			EndIf


			;If Not $iAdded Then $iAdded = 1
		EndIf
	Next
EndFunc
Func aWins_Add($hWin,$AddAsActive = False)

	; Check if we need to block the window
;~ 		If _ArraySearch($aWins_aBlackedWins,$hWin) >= 0 Then Return

	; Get the window pos
		Local $aPos = WinGetPos($hWin)
		If @error Then Return

		If $aPos[2] <= 80 Or $aPos[3] <= 80 Then Return

		;If $aPos[2]*$aPos[3] <= 80 Then Return




	; Add the the new window to the list
		Local $iIndex,$tmp1,$tmp2
		If Not $AddAsActive Or Not $aWins[0][0] Then
			$iIndex = $aWins[0][0]+1
			ReDim $aWins[$iIndex+1][$C_aWins_idxmax]
		Else
			_ArrayInsert($aWins,1)
			$iIndex = 1

		EndIf
		$aWins[0][0] += 1


	; initialize ...
		$aWins[$iIndex][$C_aWins_idx_hWin] = $hWin
		;$aWins[$iIndex][$C_aWins_idx_hMask] = CreateLayerForWin($hWin,$aPos,$hWin);GUICreateLayer($aPos[0],$aPos[1],$aPos[2],$aPos[3],$hWin)
		$aWins[$iIndex][$C_aWins_idx_x_pos] = $aPos[0]
		$aWins[$iIndex][$C_aWins_idx_y_pos] = $aPos[1]
		$aWins[$iIndex][$C_aWins_idx_x_size] = $aPos[2]
		$aWins[$iIndex][$C_aWins_idx_y_size] = $aPos[3]


		Local $ProcessName = _ProcessGetName(WinGetProcess($hWin))
		If Not @error Then $aWins[$iIndex][$C_aWins_idx_ProcessName] = $ProcessName



		If Not $bIsExternalProcess Then ; אם התהליך של WindowTop הוא host

			$tmp1 = WinGetTransLevel($aWins[$iIndex][$C_aWins_idx_hWin])
			If $tmp1 < 100 Then
				$aWins[$iIndex][$C_aWins_idx_opacitylevel] = $tmp1
				$aWins[$iIndex][$C_aWins_idx_opacitylevel_old] = $tmp1
				$aWins[$iIndex][$C_aWins_idx_opacityactive] = 1
				$aWins[0][$C_aWins_idx_opacityactive] += 1
			EndIf
			$aWins[$iIndex][$C_aWins_idx_IsTop] = _WinIsOnTop($aWins[$iIndex][$C_aWins_idx_hWin])
			$aWins[0][$C_aWins_idx_IsTop] += $aWins[$iIndex][$C_aWins_idx_IsTop]
			$aWins[$iIndex][$C_aWins_idx_IsTop_old] = $aWins[$iIndex][$C_aWins_idx_IsTop]

			$tmp = aWins_GetAverageColour($iIndex)
			If Not @error Then $aWins[$iIndex][$C_aWins_idx_AverageColor] = $tmp



			$aWins[$iIndex][$C_aWins_idx_aero_blur] = -1
			$aWins[$iIndex][$C_aWins_idx_aero_bkBrightness] = -1
			$aWins[$iIndex][$C_aWins_idx_aero_onlyDesktop] = -1


			$aWins[$iIndex][$C_aWins_idx_aero_background] = -1
			$aWins[$iIndex][$C_aWins_idx_aero_darkBackground] = -1
			$aWins[$iIndex][$C_aWins_idx_aero_images] = -1
			$aWins[$iIndex][$C_aWins_idx_aero_texts] = -1





			; Initilize with the ini file (load saved settings)

			aWins_LoadSettings($iIndex)



		EndIf




		Return $iIndex

	;~ 	WinIsOnTop($hWnd)







EndFunc
Func aWins_Remove($iIndex)

;~ 	Return




	If Not $bIsExternalProcess Then

	; Update the number of windows with opacity ...
		If $aWins[$iIndex][$C_aWins_idx_aeroactive] Then $aWins[0][$C_aWins_idx_aeroactive] -= 1

	; Update the number of windows with click through mode ...
		If $aWins[$iIndex][$C_aWins_idx_IsClickThrough] Then $aWins[0][$C_aWins_idx_IsClickThrough] -= 1

	; Update the number of windows top list
		If $aWins[$iIndex][$C_aWins_idx_IsTop] Then $aWins[0][$C_aWins_idx_IsTop] -= 1

	; Save some settings to the ini
		aWins_SaveSettings($iIndex)
	EndIf

	If $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] Then $aWins[0][$C_aWins_idx_hMask_hMag_active] -= 1

	; In dpi aware mode or when the dpi is set to 1:
	If $bRunFeatureInThislProcess Or $bIsExternalProcess Then

		; Delete the layer from the window if exists
			If $aWins[$iIndex][$C_aWins_idx_hMask] Then GUIDelete($aWins[$iIndex][$C_aWins_idx_hMask])

		; Delete the shrink gui if exists
			If $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] Then
				$aWins[0][$C_aWins_idx_Shrink_hGUI] -= 1
				aWins_Shrink_DeleteGUI($iIndex)
			EndIf


	EndIf


	If Not $bRunFeatureInThislProcess And Not $bIsExternalProcess Then _
		Jobs_CallAction($AppHelper_Soldier_hCommunicationGUI, $C_AppHelper_Soldier_Action_WinDeleted, _
		$aWins[$iIndex][$C_aWins_idx_hWin], Null)


	; Delete the window from the lst
		_ArrayDelete($aWins,$iIndex)
		$aWins[0][0] -= 1


EndFunc

Func aWins_LoadSettings($iIndex)
#cs
לפונקציה זו אנו קוראים כאשר נרצה לטעון הגדרות של החלון.
הפונקציה מיועדת בדרך כלל להיקרא בעת הוספת חלון חדש שזוהה למערך החלונות המרכזי.
הפונקציה תטען את ההגדרות עבור אותו חלון ספציפי אם קיימות כאלה
#ce

	$tmp = GetSet('WindowsSettings',$aWins[$iIndex][$C_aWins_idx_ProcessName],0)
	If Not $tmp Then Return ; No settings were found for this window


	$tmp = StringReplace($tmp,'|@|',@CRLF) ; Convert it to valid virtual ini
	StrDB_Load($tmp)  ; Load the virtual ini the string processor

	; Load the settings

	#Region Load settings
		$tmp = Number(StrDB_Ini_Read(Null,'ArrowXPos',0,1))
		If $tmp Then
			Switch $GUMe_xPos_mode
				Case $C_GUMe_xPos_mode_Left, $C_GUMe_xPos_mode_Right
					If $tmp >= 1 Then $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] = $tmp

				Case $C_GUMe_xPos_mode_Center
					If $tmp < 1 Then $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] = $tmp

			EndSwitch
		EndIf
	#EndRegion



	StrDB_UnLoad() ; Unload it (to clean memory)

EndFunc
Func aWins_SaveSettings($iIndex, $bSaveOtherSettings = False)
	Local $tmp, $bChanged = False
	; Load the virtual ini data
		$tmp = GetSet('WindowsSettings',$aWins[$iIndex][$C_aWins_idx_ProcessName],0)
		$tmp = StringReplace($tmp,'|@|',@CRLF) ; Convert it to valid virtual ini
		StrDB_Load($tmp)  ; Load the virtual ini the string processor

	; Save the pos of the menu bar button (if changed
		If $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x] Then
			; update the value in the vr ini
				StrDB_Ini_Write(Null, 'ArrowXPos', $aWins[$iIndex][$C_aWins_idx_hMB_fixed_x])
				$bChanged = True
		EndIf


		If $bSaveOtherSettings Then


			If $aWins[$iIndex][$C_aWins_idx_IsTop] Then
				StrDB_Ini_Write(Null, 'settop','1')
			Else
				StrDB_Ini_Write(Null, 'settop','0')
			EndIf


			If $aWins[$iIndex][$C_aWins_idx_opacityactive] Then
				StrDB_Ini_Write(Null, 'opa','1')
				StrDB_Ini_Write(Null, 'opa_level',$aWins[$iIndex][$C_aWins_idx_opacitylevel])
			Else
				StrDB_Ini_Write(Null, 'opa','0')
			EndIf


			If $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] Then
				StrDB_Ini_Write(Null, 'darkmode','1')
			Else
				StrDB_Ini_Write(Null, 'darkmode','0')
			EndIf


			$bChanged = True

		EndIf

	; Write the value in the ini
		If $bChanged Or $bSaveOtherSettings Then
			If Not IniWrite($ini,'WindowsSettings',$aWins[$iIndex][$C_aWins_idx_ProcessName],StrDB_GetFullString('|@|')) Then Return SetError(1)
		EndIf

	; Unload the virtual ini data
		StrDB_UnLoad()
EndFunc

Func aWins_GetDisplay($iIndex)
	Local $aMonitors = _WinAPI_EnumDisplayMonitors()
	If IsArray($aMonitors) Then

		Local $xCenter = $aWins[$iIndex][$C_aWins_idx_x_pos] + $aWins[$iIndex][$C_aWins_idx_x_size] / 2
		Local $yCenter = $aWins[$iIndex][$C_aWins_idx_y_pos] + $aWins[$iIndex][$C_aWins_idx_y_size] / 2

		For $a = 1 To $aMonitors[0][0]
			Local $aRect = _WinAPI_GetPosFromRect($aMonitors[$a][1])

			If $xCenter >= $aRect[0] And $xCenter <= $aRect[0]+$aRect[2] And $yCenter >= $aRect[1] And $yCenter <= $aRect[1]+$aRect[3] Then _
				Return $aRect
		Next
	EndIf

	Local $aOutput[4] = [0,0,@DesktopWidth,@DesktopHeight]
	Return $aOutput

EndFunc


#cs
Func aWins_UpdateAverageColour()
	Local Static $iTimer
	If TimerDiff($iTimer) < 5000 Then Return
	For $a = 1 To $aWins[0][0]
;~ 		If BitAND(WinGetState($aWins[$a][$C_aWins_idx_hWin]), $WIN_STATE_ACTIVE) Then
			If Not $aWins[$a][$C_aWins_idx_hMask_hMag_active] And $GUIMenuButton_h = -1 Then
				$tmp = aWins_GetAverageColour($a)
				If Not @error Then $aWins[$a][$C_aWins_idx_AverageColor] = $tmp

			EndIf
			ExitLoop
;~ 		EndIf
	Next
	$iTimer = TimerInit()
EndFunc
#ce


Func aWins_CaptureImage($iIndex)
	Local $hGDI_Image


;~ 	If 	$aWins[$iIndex][$C_aWins_idx_ProcessName] <> 'ApplicationFrameHost.exe' And _
;~ 		$aWins[$iIndex][$C_aWins_idx_ProcessName] <> 'chrome.exe' Then


;~ 		$hGDI_Image = Capture_Window($aWins[$iIndex][$C_aWins_idx_hWin], True, $aWins[$iIndex][$C_aWins_idx_x_size], $aWins[$iIndex][$C_aWins_idx_y_size])
;~ 		If Not @error Then Return $hGDI_Image
;~ 	EndIf


	Local $xPos = $aWins[$iIndex][$C_aWins_idx_x_pos], $yPos = $aWins[$iIndex][$C_aWins_idx_y_pos]

	Local $bIsMaximized = BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]), 32)


	If Not $bIsMaximized Then ; if not maximaized

		$aDisplay = aWins_GetDisplay($iIndex)

		If $xPos < $aDisplay[0] Then
			$xPos = $aDisplay[0]
		ElseIf $xPos+$aWins[$iIndex][$C_aWins_idx_x_size] > $aDisplay[0]+$aDisplay[2] Then
			$xPos = $aDisplay[0]+$aDisplay[2]-$aWins[$iIndex][$C_aWins_idx_x_size]
		EndIf


		If $yPos < $aDisplay[1] Then
			$yPos = $aDisplay[1]
		ElseIf $yPos+$aWins[$iIndex][$C_aWins_idx_y_size] > $aDisplay[1]+$aDisplay[3] Then
			$yPos = $aDisplay[1]+$aDisplay[3]-$aWins[$iIndex][$C_aWins_idx_y_size]
		EndIf

		WinMove($aWins[$iIndex][$C_aWins_idx_hWin],"",$xPos,$yPos)

	EndIf

	WinSetOnTop($aWins[$iIndex][$C_aWins_idx_hWin],"",1)



	If $GUMe_WinOptions_hgui <> -1 Then GUISetState(@SW_HIDE,$GUMe_WinOptions_hgui)
	Local $tmp = _ScreenCapture_Capture("", $xPos,$yPos, $xPos+$aWins[$iIndex][$C_aWins_idx_x_size], $yPos+$aWins[$iIndex][$C_aWins_idx_y_size])
	$hGDI_Image = _GDIPlus_BitmapCreateFromHBITMAP($tmp)
	_WinAPI_DeleteObject($tmp)
	If $GUMe_WinOptions_hgui <> -1 Then GUISetState(@SW_SHOWNOACTIVATE,$GUMe_WinOptions_hgui)

	If Not $bIsMaximized Then WinMove($aWins[$iIndex][$C_aWins_idx_hWin],"",$aWins[$iIndex][$C_aWins_idx_x_pos],$aWins[$iIndex][$C_aWins_idx_y_pos])

	If Not $aWins[$iIndex][$C_aWins_idx_IsTop] Then WinSetOnTop($aWins[$iIndex][$C_aWins_idx_hWin],"",0)

	If Not $hGDI_Image Then Return SetError(1)

	Return $hGDI_Image

EndFunc




Func aWins_GetAverageColour($iIndex)



	If $aWins[$iIndex][$C_aWins_idx_opacityactive] Then Return SetError(1)

	Switch $aWins[$iIndex][$C_aWins_idx_ProcessName]
		Case 'firefox.exe', 'chrome.exe', 'iexplore.exe', 'ApplicationFrameHost.exe'
			Return SetError(2)
	EndSwitch



    Local $iBlue = 0, $iGreen = 0, $iRed = 0, $iInterim_Blue = 0, $iInterim_Green = 0, $iInterim_Red = 0, $iInner_Count = 0, $iOuter_Count = 0, _
	$iX1, $iY1, $iX2, $iY2, $iFullX = _WinAPI_GetSystemMetrics(78), $iFullY = _WinAPI_GetSystemMetrics(79)


	Local Const $C_iStep = 10


	If Not BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]), 32) Then ; If not maximized

		$iX1 = $aWins[$iIndex][$C_aWins_idx_x_pos]
		$iY1 = $aWins[$iIndex][$C_aWins_idx_y_pos]

		$iX2 = $iX1+$aWins[$iIndex][$C_aWins_idx_x_size]
		If $iX2 > $iFullX Then $iX2 = $iFullX
		$iY2 = $iY1+$aWins[$iIndex][$C_aWins_idx_y_size]
		If $iY2 > $iFullY Then $iY2 = $iFullY

	Else ; If maximized

		$iX1 = 0
		$iY1 = 0
		$iX2 = $aWins[$iIndex][$C_aWins_idx_x_size]
		If $iX2 > $iFullX Then $iX2 = $iFullX
		$iY2 = $aWins[$iIndex][$C_aWins_idx_y_size]
		If $iY2 > $iFullY Then $iY2 = $iFullY
	EndIf


    Local $hBMP = _ScreenCapture_Capture("", $iX1,$iY1, $iX2, $iY2)
    If @error Then Return SetError(1)


    Local $hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBMP)
    If Not $hImage Then
        _WinAPI_DeleteObject($hBMP)
        Return SetError(1)
    EndIf


	Local $iXsize = $iX2-$iX1, $iYsize = $iY2-$iY1

    Local $tRes = _GDIPlus_BitmapLockBits($hImage, 0, 0, $iXsize, $iYsize, BitOR($GDIP_ILMREAD, $GDIP_ILMWRITE), $GDIP_PXF32ARGB)
    If @error Then
        _GDIPlus_BitmapDispose($hImage)
        _WinAPI_DeleteObject($hBMP)
        Return SetError(2)
    EndIf

    ;Get the returned values of _GDIPlus_BitmapLockBits()
    Local $iLock_Width  = DllStructGetData($tRes, "width")
    Local $iLock_Height = DllStructGetData($tRes, "height")
    Local $iLock_Stride = DllStructGetData($tRes, "stride")
    Local $iLock_Scan0  = DllStructGetData($tRes, "Scan0")

    ; Run through the BitMap testing pixels at the step distance
    For $i = 0 To $aWins[$iIndex][$C_aWins_idx_x_size] - 1 Step $C_iStep
        For $j = 0 To $iYsize - 1 Step $C_iStep
            Local $v_Buffer = DllStructCreate("dword", $iLock_Scan0 + ($j * $iLock_Stride) + ($i * 4))
            ; Get colour value of pixel
            Local $v_Value = DllStructGetData($v_Buffer, 1)
            ; Add components
            $iBlue  += _ColorGetBlue($v_Value)
            $iGreen += _ColorGetGreen($v_Value)
            $iRed   += _ColorGetRed($v_Value)
            ; Adjust counter
            $iInner_Count += 1
        Next
        ; Determine average value so far - this prevents value becoming too large
        $iInterim_Blue  += $iBlue / $iInner_Count
        $iBlue = 0
        $iInterim_Green += $iGreen / $iInner_Count
        $iGreen = 0
        $iInterim_Red   += $iRed / $iInner_Count
        $iRed = 0
        ; Adjust counters
        $iInner_Count = 0
        $iOuter_Count += 1
    Next
    ; Determine final average
    Local $avBlue = Hex(Int(Round($iInterim_Blue / $iOuter_Count, 0)), 2)
    Local $avGreen = Hex(Int(Round($iInterim_Green / $iOuter_Count, 0)), 2)
    Local $avRed = Hex(Int(Round($iInterim_Red / $iOuter_Count, 0)), 2)

    ; Clear up

    _GDIPlus_BitmapUnlockBits($hImage, $tRes)
    _GDIPlus_BitmapDispose($hImage) ; <<<<<<<<<<<<<
    _WinAPI_DeleteObject($hBMP)     ; <<<<<<<<<<<<<

    Return '0x'&($avRed & $avGreen & $avBlue)

EndFunc   ;==>_Area_Average_Colour



#Region  Features

	Func aWins_ToggleColorEffect($iIndex,$iEnableEffect = Default)

		If $iEnableEffect = Default Then
			If $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active]  Then
				$iEnableEffect = 0
			Else
				$iEnableEffect = 1
			EndIf
		EndIf


		If $iEnableEffect And $aWins[$iIndex][$C_aWins_idx_opacityactive] Then aWins_Opacity_OnOff($iIndex,False)


		If $bRunFeatureInThislProcess Or $bIsExternalProcess Then


			_MagnifierInit()



			If $iEnableEffect Then




				If Not BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]), $WIN_STATE_MAXIMIZED) Then
					Local $aPos[4] = [$aWins[$iIndex][$C_aWins_idx_x_pos],$aWins[$iIndex][$C_aWins_idx_y_pos],$aWins[$iIndex][$C_aWins_idx_x_size], _
					$aWins[$iIndex][$C_aWins_idx_y_size]]
				Else
					Local $aPos[4] = [0,0,@DesktopWidth,@DesktopHeight]
				EndIf



				If Not $aWins[$iIndex][$C_aWins_idx_hMask_hMag] Then
					If Not $aWins[$iIndex][$C_aWins_idx_hMask] Then
;~ 						Local $aPos[4] = [$aWins[$iIndex][$C_aWins_idx_x_pos],$aWins[$iIndex][$C_aWins_idx_y_pos],$aWins[$iIndex][$C_aWins_idx_x_size], _
;~ 						$aWins[$iIndex][$C_aWins_idx_y_size]]
						$aWins[$iIndex][$C_aWins_idx_hMask] = CreateLayerForWin($aWins[$iIndex][$C_aWins_idx_hWin],$aPos,$aWins[$iIndex][$C_aWins_idx_hWin])
					EndIf
					$aWins[$iIndex][$C_aWins_idx_hMask_hMag] = _GuiCtrlCreateMagnify($aWins[$iIndex][$C_aWins_idx_hMask],$aPos[2],$aPos[3],0,0,False)

	;~ 				_MagnifierSetScale($aWins[$iIndex][$C_aWins_idx_hMask_hMag], 1)

				Else
					WinMove($aWins[$iIndex][$C_aWins_idx_hMask_hMag],'',0,0,$aPos[2],$aPos[3])
				EndIf

				_MagnifierSetInvertColorsStyle($aWins[$iIndex][$C_aWins_idx_hMask_hMag],True)

		;~ 		aWins_hMag_SetWindowFilter()

				aWins_UpdateDisplayOutput($iIndex)
				GUISetState(@SW_SHOWNOACTIVATE,$aWins[$iIndex][$C_aWins_idx_hMask])
				$aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] = 1
				$aWins[0][$C_aWins_idx_hMask_hMag_active] += 1

			Else
				GUIDelete($aWins[$iIndex][$C_aWins_idx_hMask])
				$aWins[$iIndex][$C_aWins_idx_hMask_hMag] = 0
				$aWins[$iIndex][$C_aWins_idx_hMask] = 0
				$aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] = 0
				$aWins[0][$C_aWins_idx_hMask_hMag_active] -= 1
			EndIf

		Else

			AppHelper_CommanderAndSoldier_Init()
			If @error Then Return SetError(1)

			$tmp = Jobs_CallAction($AppHelper_Soldier_hCommunicationGUI, $C_AppHelper_Soldier_Action_SetDarkMode, _
			$aWins[$iIndex][$C_aWins_idx_hWin]&'|'&$iEnableEffect)

			If $tmp <> 'E' Then $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] = $iEnableEffect
		EndIf


	EndFunc

	Func aWins_hMag_SetWindowFilter()
		If Not $aWins[0][$C_aWins_idx_hMask_hMag_active] Then Return
		Local $aEWins[0],$iAdded
		For $a = 1 To $aWins[0][0]
			If $aWins[$a][$C_aWins_idx_hMask_hMag_active] Then ContinueLoop
			_ArrayAdd($aEWins,$aWins[$a][$C_aWins_idx_hWin])
			$iAdded += 1
			;_MagnifierSetWindowFilter($aWins[$a][$C_aWins_idx_hMask_hMag], $aWins[$iWinIndex][$C_aWins_idx_hWin]);, $bIncludeList = False)
		Next


		If $iAdded Then $g_mw_hMag_aFilterWins = $aEWins

	;~ 	_ArrayDisplay($aEWins)
	;~ 	For $a = 1 To $aWins[0][0]
	;~ 		If $aWins[$a][$C_aWins_idx_hMask_hMag_active] Then _
	;~ 		_MagnifierSetWindowFilter($aWins[$a][$C_aWins_idx_hMask_hMag], $aEWins,False)
	;~ 	Next

	;~ 	For $a = 1 To $aWins[0][0]
	;~ 		If $a = $iWinIndex Or Not $aWins[$a][$C_aWins_idx_hMask_hMag_active] Then ContinueLoop
	;~ 		_MagnifierSetWindowFilter($aWins[$a][$C_aWins_idx_hMask_hMag], $aWins[$iWinIndex][$C_aWins_idx_hWin]);, $bIncludeList = False)
	;~ 	Next
	EndFunc

	Func aWins_ToggleClickThrough($iIndex, $bMode = Default, $bUpdateCTiStop = True)



		If $aWins[$iIndex][$C_aWins_idx_ProcessName] = 'ApplicationFrameHost.exe' Then Return SetError(1)

		If $bMode = Default Then
			$bMode = $aWins[$iIndex][$C_aWins_idx_IsClickThrough]
			If $bMode Then
				$bMode = False
			Else
				$bMode = True
			EndIf
		EndIf




		If $bMode Then

			If Not $aWins[$iIndex][$C_aWins_idx_PreviousExStyle] Then
				$aWins[$iIndex][$C_aWins_idx_PreviousExStyle] = _WinAPI_GetWindowLong($aWins[$iIndex][$C_aWins_idx_hWin],$GWL_EXSTYLE)
				If @error Then $aWins[$iIndex][$C_aWins_idx_PreviousExStyle] = -1
			EndIf

			If $aWins[$iIndex][$C_aWins_idx_PreviousExStyle] = -1 Then Return ;ConsoleWrite('Error' &' (L: '&@ScriptLineNumber&')'&@CRLF)


			;_WinAPI_SetWindowLong($aWins[$iIndex][$C_aWins_idx_hWin],$GWL_EXSTYLE,BitOR($WS_EX_COMPOSITED, $WS_EX_LAYERED, $WS_EX_TRANSPARENT, $WS_EX_TOPMOST)) ; v1
			_WinAPI_SetWindowLong($aWins[$iIndex][$C_aWins_idx_hWin], $GWL_EXSTYLE, BitOR(_WinAPI_GetWindowLong($aWins[$iIndex][$C_aWins_idx_hWin], $GWL_EXSTYLE), $WS_EX_TRANSPARENT)) ; v2






			$aWins[$iIndex][$C_aWins_idx_IsClickThrough] = True
			$aWins[0][$C_aWins_idx_IsClickThrough] += 1
			If $bUpdateCTiStop Then $aWins[$iIndex][$C_aWins_idx_ClickThrough_IsTop_old] = $aWins[$iIndex][$C_aWins_idx_IsTop]
			aWins_SetOnTop($iIndex,True,False)


		Else

			If Not $aWins[$iIndex][$C_aWins_idx_PreviousExStyle] Then Return

			_WinAPI_ShowWindow($aWins[$iIndex][$C_aWins_idx_hWin],@SW_HIDE)

			;If $aWins[$iIndex][$C_aWins_idx_opacitylevel] < 100 Then WinSetTrans($aWins[$iIndex][$C_aWins_idx_hWin],'',100) ; שורה זו אולי תתקן בעיה אם בכלל קיימת

			;_WinAPI_SetWindowLong($aWins[$iIndex][$C_aWins_idx_hWin],$GWL_EXSTYLE,$aWins[$iIndex][$C_aWins_idx_PreviousExStyle]) ; v1
			_WinAPI_SetWindowLong($aWins[$iIndex][$C_aWins_idx_hWin], $GWL_EXSTYLE, BitAND(_WinAPI_GetWindowLong($aWins[$iIndex][$C_aWins_idx_hWin], $GWL_EXSTYLE), BitNOT($WS_EX_TRANSPARENT))) ; v2

			If $aWins[$iIndex][$C_aWins_idx_opacityactive] Then aWins_Opacity_SetLevel($iIndex,$aWins[$iIndex][$C_aWins_idx_opacitylevel])


			$IsMaximized = BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]),32)

			If Not $IsMaximized Then
				_WinAPI_ShowWindow($aWins[$iIndex][$C_aWins_idx_hWin],@SW_SHOWNOACTIVATE)
			Else
				_WinAPI_ShowWindow($aWins[$iIndex][$C_aWins_idx_hWin],@SW_MAXIMIZE)
			EndIf

	;~ 			If $IsMaximized Then WinSetState($aWins[$iIndex][$C_aWins_idx_hWin],Null,@SW_MAXIMIZE)


			If Not $aWins[$iIndex][$C_aWins_idx_opacityactive] Then WinSetTrans($aWins[$iIndex][$C_aWins_idx_hWin],'',255)



			; Fix bug that the window may not redraw correctly when the user disable the click through
				$tmp = WinGetPos($aWins[$iIndex][$C_aWins_idx_hWin])
				If IsArray($tmp) Then
					WinSetTrans($aWins[$iIndex][$C_aWins_idx_hWin],Null,1)
					WinMove($aWins[$iIndex][$C_aWins_idx_hWin],Null,$tmp[0],$tmp[1],$tmp[2]+1,$tmp[3]+1)
					WinMove($aWins[$iIndex][$C_aWins_idx_hWin],Null,$tmp[0],$tmp[1],$tmp[2],$tmp[3])

					If $aWins[$iIndex][$C_aWins_idx_opacityactive] Then
						aWins_Opacity_SetLevel($iIndex,$aWins[$iIndex][$C_aWins_idx_opacitylevel])
					Else
						WinSetTrans($aWins[$iIndex][$C_aWins_idx_hWin],Null,255)
					EndIf
				EndIf


			$aWins[$iIndex][$C_aWins_idx_IsClickThrough] = False
			$aWins[0][$C_aWins_idx_IsClickThrough] -= 1

			If $aWins[$iIndex][$C_aWins_idx_ClickThrough_IsTop_old] <> $aWins[$iIndex][$C_aWins_idx_IsTop] Then
				aWins_SetOnTop($iIndex,$aWins[$iIndex][$C_aWins_idx_ClickThrough_IsTop_old],False)
			EndIf

		EndIf


		;$aWins[$iIndex][$C_aWins_idx_IsClickThrough] = $bMode

	EndFunc

	Func aWins_ToggleClickThrough_OpacityWins($bMode)
		For $a = 1 To $aWins[0][0]
			If Not $aWins[$a][$C_aWins_idx_opacityactive] Then ContinueLoop
			If $aWins[$a][$C_aWins_idx_Shrink_hGUI] Then ContinueLoop
			aWins_ToggleClickThrough($a,$bMode)
		Next
	EndFunc

	Func aWins_SetOnTop($iIndex,$bMode = Default, $bUpdateCTiStop = True)
		If $bMode = Default Then
			If $aWins[$iIndex][$C_aWins_idx_IsTop] Then
				$bMode = False
			Else
				$bMode = True
			EndIf
		EndIf
		If $bMode Then
			If $aWins[$iIndex][$C_aWins_idx_IsTop] Then Return
			WinActivate($aWins[$iIndex][$C_aWins_idx_hWin])
			WinSetOnTop($aWins[$iIndex][$C_aWins_idx_hWin],'',1)
			If $aWins[$iIndex][$C_aWins_idx_hMask] Then WinSetOnTop($aWins[$iIndex][$C_aWins_idx_hMask],Null,True)
			;ToolTip('1',$aWins[$iIndex][$C_aWins_idx_x_pos],$aWins[$iIndex][$C_aWins_idx_y_pos])
			$aWins[$iIndex][$C_aWins_idx_IsTop] = True
			$aWins[0][$C_aWins_idx_IsTop] += 1

		Else
			If Not $aWins[$iIndex][$C_aWins_idx_IsTop] Then Return ; <-------------------------------------------------
			WinSetOnTop($aWins[$iIndex][$C_aWins_idx_hWin],'',0)
			;ToolTip('0',$aWins[$iIndex][$C_aWins_idx_x_pos],$aWins[$iIndex][$C_aWins_idx_y_pos])
			$aWins[$iIndex][$C_aWins_idx_IsTop] = False
			$aWins[0][$C_aWins_idx_IsTop] -= 1
		EndIf

		If $bUpdateCTiStop Then $aWins[$iIndex][$C_aWins_idx_ClickThrough_IsTop_old] = $aWins[$iIndex][$C_aWins_idx_IsTop]


	;~ 		MsgBox(0,'','')


	EndFunc

	Func aWins_Opacity_SetLevel($iIndex,$iOpacityLevel)

		If $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] Then aWins_ToggleColorEffect($iIndex,0)

		WinSetTrans($aWins[$iIndex][$C_aWins_idx_hWin],'',Round(($iOpacityLevel/100)*255))
		$aWins[$iIndex][$C_aWins_idx_opacitylevel] = $iOpacityLevel
		If Not $aWins[$iIndex][$C_aWins_idx_opacityactive] Then $aWins[$iIndex][$C_aWins_idx_opacityactive] = True
	EndFunc

	Func aWins_Opacity_OnOff($iIndex,$bMode = Default)


		If $bMode = Default Then
			If $aWins[$iIndex][$C_aWins_idx_opacityactive] Then
				$bMode = False
			Else
				$bMode = True
			EndIf
		EndIf

		$aWins[$iIndex][$C_aWins_idx_opacityactive] = $bMode
		If $bMode Then

			If $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] Then aWins_ToggleColorEffect($iIndex,0)

			If Not $aWins[$iIndex][$C_aWins_idx_opacitylevel] Then $aWins[$iIndex][$C_aWins_idx_opacitylevel] = 75
			WinSetTrans($aWins[$iIndex][$C_aWins_idx_hWin],'',Round(($aWins[$iIndex][$C_aWins_idx_opacitylevel]/100)*255))

			If $aWins[$iIndex][$C_aWins_idx_IsClickThrough] Then aWins_ToggleClickThrough($iIndex, True, False)

		Else
			WinSetTrans($aWins[$iIndex][$C_aWins_idx_hWin],'',255)

			If $aWins[$iIndex][$C_aWins_idx_IsClickThrough] Then aWins_ToggleClickThrough($iIndex, False)

		EndIf




	EndFunc


	Func aWins_Shrink($iIndex,$bMode = Default)

		; $C_GuiShrink_xySize is 80



		If $bMode = Default Then
			If $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] Then
				$bMode = 0
			Else
				$bMode = 1
			EndIf
		EndIf


		If $bRunFeatureInThislProcess Or $bIsExternalProcess Then
			If $bMode Then

				If $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] Then Return

				If $bIsExternalProcess Then
					If $aWins[$iIndex][$C_aWins_idx_hMask] Then
						WinSetState($aWins[$iIndex][$C_aWins_idx_hMask],Null,@SW_HIDE)
						$aWins[$iIndex][$C_aWins_idx_hMask_bIsHidden] = True
					EndIf
				EndIf

				; Take image of the window

					aWins_Shrink_HideAllWindows(True)

					$tmp = aWins_CaptureImage($iIndex)

					If Not @error Then
						$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_hImage] = _GDIPlus_ImageResize($tmp, $C_GuiShrink_xySize-2, $C_GuiShrink_xySize-2) ;resize image
						_GDIPlus_BitmapDispose($tmp)
					EndIf

					aWins_Shrink_HideAllWindows(False)



				; Take the title of the window
					Local $sWinTitle = StringStripWS(WinGetTitle($aWins[$iIndex][$C_aWins_idx_hWin]),3)
					If Not $sWinTitle Then
						$sWinTitle = $aWins[$iIndex][$C_aWins_idx_ProcessName]
					Else
						$sWinTitle &= ' ['&$aWins[$iIndex][$C_aWins_idx_ProcessName]&']'
					EndIf

				; Hide the window
					WinSetState($aWins[$iIndex][$C_aWins_idx_hWin],Null,@SW_HIDE)





				; Create the shrink GUI with the image of the window
					; Get the xPos and yPos
						Local $xPos, $yPos
						$tmp = $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_aPos]
						If IsArray($tmp) Then
							$xPos = $tmp[0]
							$yPos = $tmp[1]

						 Else

							$xPos = $aWins[$iIndex][$C_aWins_idx_x_pos] + $aWins[$iIndex][$C_aWins_idx_x_size]/2 - $C_GuiShrink_xySize/2;$xPos = ($aWins[$iIndex][$C_aWins_idx_x_size]/2)-($C_GuiShrink_xySize/2)
							$yPos = $aWins[$iIndex][$C_aWins_idx_y_pos] + $aWins[$iIndex][$C_aWins_idx_y_size]/2 - $C_GuiShrink_xySize/2


							Local $aRectDisplay = aWins_GetDisplay($iIndex)

							If $xPos < $aRectDisplay[0] Then
								$xPos = $aRectDisplay[0]
							ElseIf $xPos+$C_GuiShrink_xySize > $aRectDisplay[0]+$aRectDisplay[2] Then
								$xPos = $aRectDisplay[0]+$aRectDisplay[2]-$C_GuiShrink_xySize
							EndIf

							If $yPos < $aRectDisplay[1] Then
								$yPos = $aRectDisplay[1]
							ElseIf $yPos+$C_GuiShrink_xySize > $aRectDisplay[1]+$aRectDisplay[3] Then
								$yPos = $aRectDisplay[1]+$aRectDisplay[3]-$C_GuiShrink_xySize
							EndIf

							Local $tmp[2] = [$xPos,$yPos]
							$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_aPos] = $tmp

						EndIf



					; make sure that the pos is not taken. chage it a bit if the pos was taken

					Local $iIndex2 = $iIndex

						For $a = 1 To $aWins[0][0]

							If Not $aWins[$a][$C_aWins_idx_Shrink_hGUI] Then ContinueLoop
							If $a = $iIndex2 Then ContinueLoop

							$tmp = WinGetPos($aWins[$a][$C_aWins_idx_Shrink_hGUI])
							If @error Then ContinueLoop

							If $tmp[0] = $xPos And $tmp[1] = $yPos Then
								$xPos += 20
								$yPos += 20
								$a = 0
							EndIf
						Next








				; Create the shrink GUI

					$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] = CreateBaseGUI($xPos,$yPos,$C_GuiShrink_xySize,$C_GuiShrink_xySize,$g_DummyTopGui,$aWins[$iIndex][$C_aWins_idx_AverageColor],1)
;~ 					$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] = GUICreate('Changing log',$C_xSize,$C_ySize)
					WinSetOnTop($aWins[$iIndex][$C_aWins_idx_Shrink_hGUI],Null,True)

					$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_label] = GUICtrlCreateLabel(Null,0,0,$C_GuiShrink_xySize,$C_GuiShrink_xySize);,-1,$GUI_WS_EX_PARENTDRAG)
					GUICtrlSetBkColor(-1,$GUI_BKCOLOR_TRANSPARENT)
	;~ 				GUICtrlSetTip(-1,$aWins[$iIndex][$C_aWins_idx_ProcessName],WinGetText($aWins[$iIndex][$C_aWins_idx_hWin]),64)
					GUICtrlSetTip(-1,$sWinTitle)

					GUICtrlSetCursor(-1,0)

					$aWins_Shrink_LastGUI = $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI]
				; Show the GUI
					GUISetState(@SW_SHOWNOACTIVATE,$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI])

				; Draw the image on the gui
				If $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_hImage] Then

					$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_hGraphics] = _GDIPlus_GraphicsCreateFromHWND($aWins[$iIndex][$C_aWins_idx_Shrink_hGUI]) ; Create the graphics for the GUI

					aWins_Shrink_Redraw($iIndex)


				EndIf

				; Update the number of shrinked wins
					$aWins[0][$C_aWins_idx_Shrink_hGUI] += 1


			Else ; Unshrink

				If Not $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] Then Return




				If Not $bIsExiting Then

					; Get the pos of the shrink GUI
						Local $aShrinkGUIPos = WinGetPos($aWins[$iIndex][$C_aWins_idx_Shrink_hGUI])



						If $aWins_Shrink_LastGUI = $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] Then
							$aWins_Shrink_LastGUI = Null
							For $a = 1 To $aWins[0][0]
								If $a = $iIndex Or Not $aWins[$a][$C_aWins_idx_Shrink_hGUI] Then ContinueLoop
								$aWins_Shrink_LastGUI = $aWins[$a][$C_aWins_idx_Shrink_hGUI]
								ExitLoop
							Next
						EndIf

					; Delete the shrink GUI
						aWins_Shrink_DeleteGUI($iIndex)

				; Move the window to the new pos if it was not maximized before.
					If Not BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]), 32) Then
					; Get the new pos for the window
						Local $xPos = $aShrinkGUIPos[0]+($aShrinkGUIPos[2]/2)-($aWins[$iIndex][$C_aWins_idx_x_size]/2)
						Local $yPos = $aShrinkGUIPos[1]+($aShrinkGUIPos[3]/2)-($aWins[$iIndex][$C_aWins_idx_y_size]/2)
						Local $xSize = $aWins[$iIndex][$C_aWins_idx_x_size], $ySize = $aWins[$iIndex][$C_aWins_idx_y_size]

						Local $iFullDesktopX = _WinAPI_GetSystemMetrics(78), $iFullDesktopY = _WinAPI_GetSystemMetrics(79)

						If $iFullDesktopX And $iFullDesktopY Then
							If $xPos < 0 Then $xPos = 0
							If $xPos+$xSize > $iFullDesktopX Then $xPos = $iFullDesktopX-$xSize

							If $yPos < 0 Then $yPos = 0
							If $yPos+$ySize > $iFullDesktopY Then $yPos = $iFullDesktopY-$ySize
						EndIf

						WinMove($aWins[$iIndex][$C_aWins_idx_hWin],Null,$xPos,$yPos,$xSize,$ySize)

					EndIf
				EndIf

				; Show the window
					WinSetState($aWins[$iIndex][$C_aWins_idx_hWin],Null,@SW_SHOW)


					If Not $bIsExiting And $aWins[$iIndex][$C_aWins_idx_hMask] Then
						WinSetState($aWins[$iIndex][$C_aWins_idx_hMask],Null,@SW_SHOW)
						$aWins[$iIndex][$C_aWins_idx_hMask_bIsHidden] = False
					EndIf

					WinActivate($aWins[$iIndex][$C_aWins_idx_hWin])


				; Update the number of shrinked wins
					$aWins[0][$C_aWins_idx_Shrink_hGUI] -= 1


				; If this is soldier process then tell to the commander process that
				; the shrink mode is disabled
					If $bIsExternalProcess Then
						Jobs_CallAction($AppHelper_Commander_hCommunicationGUI, _
										$C_AppHelper_Commander_Action_ShrinkModeIsDisabled, _
										$aWins[$iIndex][$C_aWins_idx_hWin], Null, 0)
					Else



;~ 						If $ProFe_bDarkMode And $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] Then
;~ 				Jobs_CallAction($AppHelper_CPP_Soldier_hCommunicationGUI, $C_AppHelper_CPP_Soldier_Action_SetDarkMode, _
;~ 					$aWins[$iIndex][$C_aWins_idx_hWin]&'|1')
;~ 			EndIf


;~ 			If $ProFe_bSmartAero And $aWins[$iIndex][$C_aWins_idx_opacityactive] Then _
;~ 					Jobs_CallAction($AppHelper_CPP_Soldier_hCommunicationGUI, $C_AppHelper_CPP_Soldier_Action_SmartAero_Enable, _
;~ 							$aWins[$iIndex][$C_aWins_idx_hWin]&','& _
;~ 							$aWins[$iIndex][$C_aWins_idx_aero_background]&','& _
;~ 							$aWins[$iIndex][$C_aWins_idx_aero_images]&','& _
;~ 							$aWins[$iIndex][$C_aWins_idx_aero_texts])

						If $aWins[$iIndex][$C_aWins_idx_hMask_hMag_active] Then
							aWins_ToggleColorEffect($iIndex,1)
						EndIf



					EndIf


			EndIf

		Else
			AppHelper_CommanderAndSoldier_Init()
			If Not @error Then
				$tmp = Jobs_CallAction($AppHelper_Soldier_hCommunicationGUI, $C_AppHelper_Soldier_Action_Shrink, _
				$aWins[$iIndex][$C_aWins_idx_hWin]&'|'&$bMode)

				If $tmp <> 'E' Then $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] = $bMode
			EndIf

		EndIf


	EndFunc

	Func aWins_Shrink_DeleteGUI($iIndex)
		_GDIPlus_GraphicsDispose($aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_hImage])
		_GDIPlus_GraphicsDispose($aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_hGraphics])
		GUIDelete($aWins[$iIndex][$C_aWins_idx_Shrink_hGUI])
		$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] = Null

	EndFunc


	Func aWins_Shrink_UpdateShrinkGUI($iIndex)

		Local Static $hActiveWindow, $hActiveWindow_old = -1

		If Not $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] Then Return

		If BitAND(WinGetState($aWins[$iIndex][$C_aWins_idx_hWin]), $WIN_STATE_VISIBLE) Then
			aWins_Shrink_DeleteGUI($iIndex)
			$aWins[0][$C_aWins_idx_Shrink_hGUI] -= 1
			Return
		EndIf


		If $aWins_Shrink_TimerDiff > $C_aWins_Shrink_UpdateTime Then _
				aWins_Shrink_Redraw($iIndex)


		If  $Software_MSG[1] = $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] And _
			$Software_MSG[0] = $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_label] Then

			$aWins_Shrink_LastGUI = $aWins[$iIndex][$C_aWins_idx_Shrink_hGUI]
			WinSetOnTop($aWins_Shrink_LastGUI,Null,True)

			aWins_Shrink_ProcessMovent($iIndex)
		EndIf


		$hActiveWindow = WinGetHandle('[ACTIVE]')
		If $hActiveWindow <> $hActiveWindow_old Then
			If _WinIsOnTop($hActiveWindow) Then WinSetOnTop($aWins_Shrink_LastGUI,Null,True)
			$hActiveWindow_old = $hActiveWindow
		EndIf


	EndFunc


	Func aWins_Shrink_ProcessMovent($l_iIndex = 0)
		Local Static $aMousePos, $aGUIpos, $iIndex, $iTimer, $aGUIpos_old

		If $l_iIndex Then
			MousePos_Update()
			$aMousePos = $MousePos_aPos
			$aGUIpos = WinGetPos($aWins[$l_iIndex][$C_aWins_idx_Shrink_hGUI])
			$aGUIpos_old = $aGUIpos
			;$hDLL = DllOpen("user32.dll")
			$iIndex = $l_iIndex
			$iTimer = TimerInit()
			aExtraFuncCalls_AddFunc(aWins_Shrink_ProcessMovent)
			Return
		EndIf


		MousePos_Update()
		If $aMousePos[0] <> $MousePos_aPos[0] Or $aMousePos[1] <> $MousePos_aPos[1] Then
			$aGUIpos[0] -= $aMousePos[0]-$MousePos_aPos[0]
			$aGUIpos[1] -= $aMousePos[1]-$MousePos_aPos[1]
			WinMove($aWins[$iIndex][$C_aWins_idx_Shrink_hGUI],Null,$aGUIpos[0],$aGUIpos[1])
			$aMousePos = $MousePos_aPos
			aWins_Shrink_Redraw($iIndex)
		EndIf

		If _IsPressed('01',$user32_dll) Then Return


		If $aGUIpos[0] <> $aGUIpos_old[0] Or $aGUIpos[1] <> $aGUIpos_old[1] Then
			Local $tmp[2] = [$aGUIpos[0],$aGUIpos[1]]
			$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_aPos] = $tmp
			Return True
		EndIf

		If TimerDiff($iTimer) < 500 Then aWins_Shrink($iIndex,False)

		Return True










	EndFunc

	Func aWins_Shrink_Redraw($iIndex)
		_GDIPlus_GraphicsDrawImage($aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_hGraphics],$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI_hImage],1,1)
	EndFunc


	Func aWins_ShrinkAllWins_EnableDisable($bMode)
		For $a = 1 To $aWins[0][0]
			If BitAND(WinGetState($aWins[$a][$C_aWins_idx_hWin]), 16) Then ContinueLoop ; If the window is minimized then skip it
			aWins_Shrink($a,$bMode)
		Next
	EndFunc

	Func aWins_MinimizeAllShrinkedWinsToTaskbar()
		For $a = 1 To $aWins[0][0]
			If Not $aWins[$a][$C_aWins_idx_Shrink_hGUI] Then ContinueLoop
			aWins_Shrink_DeleteGUI($a)
			$aWins[0][$C_aWins_idx_Shrink_hGUI] -= 1
			WinSetState($aWins[$a][$C_aWins_idx_hWin],Null,@SW_MINIMIZE)
			;If $aWins[$a][$C_aWins_idx_hMask] Then WinSetState($aWins[$a][$C_aWins_idx_hMask],Null,@SW_MINIMIZE)

		; If this is soldier process then tell to the commander process that
		; the shrink mode is disabled
			If $bIsExternalProcess Then _
				Jobs_CallAction($AppHelper_Commander_hCommunicationGUI, _
								$C_AppHelper_Commander_Action_ShrinkModeIsDisabled, _
								$aWins[$a][$C_aWins_idx_hWin], Null, 0)

		Next
	EndFunc

	Func aWins_Shrink_HideAllWindows($bHide)
		For $a = 1 To $aWins[0][0]
			If Not $aWins[$a][$C_aWins_idx_Shrink_hGUI] Then ContinueLoop
			If Not IsWindowOnCurrentVirtualDesktop($aWins[$a][$C_aWins_idx_Shrink_hGUI]) Then ContinueLoop

			Local $aPos = WinGetPos($aWins[$a][$C_aWins_idx_Shrink_hGUI])

			If $bHide Then
				GUISetState(@SW_HIDE, $aWins[$a][$C_aWins_idx_Shrink_hGUI])
			Else
				GUISetState(@SW_SHOW, $aWins[$a][$C_aWins_idx_Shrink_hGUI])
				aWins_Shrink_Redraw($a)
			EndIf

		Next


	EndFunc

#EndRegion



Func aWins_UpdateDisplayOutput($iIndex)
;~ 	ToolTip(1)
	$tmp = WinGetState($aWins[$iIndex][$C_aWins_idx_hWin])

	If BitAND($tmp,$WIN_STATE_MINIMIZED) Then Return

	If $aWins[$iIndex][$C_aWins_idx_hMask_bIsHidden] Then
		WinSetState($aWins[$iIndex][$C_aWins_idx_hMask],Null,@SW_SHOWNOACTIVATE)
		$aWins[$iIndex][$C_aWins_idx_hMask_bIsHidden] = False
	EndIf


	If Not BitAND($tmp,$WIN_STATE_MAXIMIZED) Then
		_MagnifierSetSource($aWins[$iIndex][$C_aWins_idx_hMask_hMag], $aWins[$iIndex][$C_aWins_idx_x_pos], $aWins[$iIndex][$C_aWins_idx_y_pos], $aWins[$iIndex][$C_aWins_idx_x_pos]+$aWins[$iIndex][$C_aWins_idx_x_size], $aWins[$iIndex][$C_aWins_idx_y_pos]+$aWins[$iIndex][$C_aWins_idx_y_size])
	Else
		_MagnifierSetSource($aWins[$iIndex][$C_aWins_idx_hMask_hMag],0,0,@DesktopWidth,@DesktopHeight)
	EndIf
EndFunc


;~ Func PrintAve($diff)
;~ 	Local Static $count = 0, $diffSum = 0
;~ 	$diffSum += $diff
;~ 	$count += 1

;~ 	ToolTip($diffSum/$count)

;~ EndFunc



#EndRegion