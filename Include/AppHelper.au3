

Func AppHelper_CommanderAndSoldier_Init()

	If Not $Jobs_hAppGUI Then Jobs_Init(Default, AppHelper_Commander_ActionDecider)

	If ProcessExists($AppHelper_Soldier_iPid) Then Return
	$AppHelper_Soldier_hCommunicationGUI = Null
	$AppHelper_Soldier_iPid = Run('"'&@ScriptFullPath&'" helper '&@AutoItPID&' '&$Jobs_hAppGUI,@ScriptDir)

	Local $iTimer = TimerInit()
	Do
		Sleep(10)
		If $AppHelper_Soldier_hCommunicationGUI Then Return
	Until TimerDiff($iTimer) > 3000
	Return SetError(1)


EndFunc


Func AppHelper_CommanderAndCppSoldier_Init()
	If Not $Jobs_hAppGUI Then Jobs_Init(Default, AppHelper_Commander_ActionDecider)

	If ProcessExists($AppHelper_CPP_Soldier_iPid) Then Return
	$AppHelper_CPP_Soldier_hCommunicationGUI = Null
	;$AppHelper_CPP_Soldier_iPid = Run(@ScriptDir&'\C++\rtwl.vcxproj\x64\Release\main.exe '&$Jobs_hAppGUI,@ScriptDir)
	$AppHelper_CPP_Soldier_iPid = Run(@ScriptDir&'\WindowTopPro\WindowTopHelper.exe '&$Jobs_hAppGUI,@ScriptDir)
	;$AppHelper_CPP_Soldier_iPid = Run(@ComSpec&' /c "'&@ScriptDir&'\WindowTopPro\WindowTopHelper.exe" '&$Jobs_hAppGUI,@ScriptDir)




	If @error Then Return SetError(1)

	Local $iTimer = TimerInit()
	Do
		Sleep(10)
		If $AppHelper_CPP_Soldier_hCommunicationGUI Then Return
	Until TimerDiff($iTimer) > 3000

	Return SetError(1)
EndFunc







#Region Soldier
	Func AppHelper_Soldier_Init()
		AppHelper_Soldier_GetCommanderInfoFromCmd()
		If @error Then Return SetError(1)

		Jobs_Init(Default, AppHelper_Soldier_ActionDecider)
		$g_DummyTopGui = $Jobs_hAppGUI
		Jobs_CallAction($AppHelper_Commander_hCommunicationGUI, $C_AppHelper_Commander_Action_GetSoldierInfo, $Jobs_hAppGUI)

	EndFunc

	Func AppHelper_Soldier_GetCommanderInfoFromCmd()
		If $CmdLine[0] <> 3 Then Return SetError(1)
		$AppHelper_Commander_iPid = Number($CmdLine[2])
		$AppHelper_Commander_hCommunicationGUI = HWnd($CmdLine[3])
	EndFunc

	Func AppHelper_Soldier_ActionDecider($hCallerGUI, $iActionID, $sActionData, $iJobID)
		Switch $iActionID
			Case $C_AppHelper_Soldier_Action_SetDarkMode

				$tmp = StringSplit($sActionData,'|',1)
				If $tmp[0] <> 2 Then Return Jobs_SendJobDone($hCallerGUI, $iJobID, 'E')

				Local $hWin = HWnd($tmp[1]), $iDarkModeActive = Number($tmp[2]), _
				$iIndex = AppHelper_Soldier_GetWindowIndex($hWin)
				If @error Then Return Jobs_SendJobDone($hCallerGUI, $iJobID, 'E')

				aWins_ToggleColorEffect($iIndex,$iDarkModeActive)

				Jobs_SendJobDone($hCallerGUI, $iJobID)

			Case $C_AppHelper_Soldier_Action_Shrink
				$tmp = StringSplit($sActionData,'|',1)
				If $tmp[0] <> 2 Then Return Jobs_SendJobDone($hCallerGUI, $iJobID, 'E')

				Local $hWin = HWnd($tmp[1]), $iShrinkModeActive = Number($tmp[2]), _
				$iIndex = AppHelper_Soldier_GetWindowIndex($hWin)
				If @error Then Return Jobs_SendJobDone($hCallerGUI, $iJobID, 'E')
				aWins_Shrink($iIndex,$iShrinkModeActive)


				Jobs_SendJobDone($hCallerGUI, $iJobID)

			Case $C_AppHelper_Soldier_Action_MinimizeAllShrinkedWinsToTaskbar
				aWins_MinimizeAllShrinkedWinsToTaskbar()

			Case $C_AppHelper_Soldier_Action_UnShrinkAllWindows
				aWins_ShrinkAllWins_EnableDisable(False)

			Case $C_AppHelper_Soldier_Action_WinDeleted

				Local $iIndex = _ArraySearch($aWins,$sActionData,1,$aWins[0][0],0,0,1,$C_aWins_idx_hWin)
				If $iIndex < 1 Then Return
				$AppHelper_iWin2Delete = $iIndex

			Case $C_AppHelper_Soldier_Action_ExitEvent
				$bIsExiting = True

		EndSwitch
	EndFunc

	Func AppHelper_Soldier_GetWindowIndex($hWin)
		If Not $hWin Then Return SetError(1)
		Local $iIndex = _ArraySearch($aWins,$hWin,1,$aWins[0][0],0,0,1,$C_aWins_idx_hWin)
		Local $bIsWinExist = WinExists($hWin)
		If $iIndex >= 1 Then
			If Not $bIsWinExist Then
				aWins_Remove($iIndex)
				Return SetError(1)
			EndIf
			Return $iIndex
		Else
			If Not $bIsWinExist Then Return SetError(1)
			$iIndex = aWins_Add($hWin)
			If Not $iIndex Or $iIndex < 1 Then Return SetError(1)
			Return $iIndex
		EndIf
	EndFunc

	Func AppHelper_Soldier_MainLoop()

		Local $iTimer_CheckCommanderPid = TimerInit()


		While Sleep(10)

	#Region Other stuff

		; Check every x seconds if the commander process is running. if not then exit

		If Not $bIsExiting Then
			If TimerDiff($iTimer_CheckCommanderPid) > 15000 Then
				If Not ProcessExists($AppHelper_Commander_iPid) Then ExitLoop
				$iTimer_CheckCommanderPid = TimerInit()
			EndIf
		Else
			ExitLoop
		EndIf



		; Call to a dynamic list of functions. every function that return True is removed from the list
			aExtraFuncCalls_CallFuncs()


	#EndRegion

	#Region Maintain Windows
			If Not $aWins[0][0] Then ContinueLoop

		; Set the timer for refresh rate
			If $aWins[0][$C_aWins_idx_hMask_hMag_active] Then $g_mw_hMag_update_timerdiff = TimerDiff($g_mw_hMag_update_timer)


			$Software_MSG = GUIGetMsg(1)

			If $aWins[0][$C_aWins_idx_Shrink_hGUI] Then $aWins_Shrink_TimerDiff = TimerDiff($aWins_Shrink_UpdateImageTimer)

			For $a = 1 To $aWins[0][0] ; Go on every window and:


				; Update the window pos
					aWins_UpdateNewWinPos($a)


					If $aWins[$a][$C_aWins_idx_hMask_hMag_active] And Not $aWins[$a][$C_aWins_idx_Shrink_hGUI] And _
					(BitAND(WinGetState($aWins[$a][$C_aWins_idx_hWin]), $WIN_STATE_ACTIVE) Or $g_mw_IsNewWinPos Or _ ; BitAND(WinGetState($aWins[1][$C_aWins_idx_hWin]), $WIN_STATE_ACTIVE) isnted of $a = 1
					$g_mw_hMag_update_timerdiff >= $g_mw_hMag_update_refreshrate) Then aWins_UpdateDisplayOutput($a)


				; Maintain the shrink guis
					If $aWins[0][$C_aWins_idx_Shrink_hGUI] Then
						aWins_Shrink_UpdateShrinkGUI($a)
	;~ 					ToolTip(1)
					EndIf


			Next

			If $aWins[0][$C_aWins_idx_hMask_hMag_active] And $aWins_Shrink_TimerDiff > $C_aWins_Shrink_UpdateTime Then
				$aWins_Shrink_UpdateImageTimer = TimerInit()
			EndIf

			If $AppHelper_iWin2Delete Then
				aWins_Remove($AppHelper_iWin2Delete)
				$AppHelper_iWin2Delete = Null
			EndIf


	#EndRegion

		WEnd


		OnExit()

	EndFunc
















#EndRegion

Func AppHelper_Commander_ActionDecider($hCallerGUI, $iActionID, $sActionData, $iJobID)

	Switch $iActionID

		Case $C_AppHelper_Commander_Action_GetSoldierInfo
			$AppHelper_Soldier_hCommunicationGUI = HWnd($sActionData)
			Jobs_SendJobDone($hCallerGUI, $iJobID)

		Case $C_AppHelper_Commander_Action_ShrinkModeIsDisabled
			Local $iIndex = _ArraySearch($aWins,HWnd($sActionData),1,$aWins[0][0],0,0,1,$C_aWins_idx_hWin)
			If $iIndex < 1 Then Return
			$aWins[$iIndex][$C_aWins_idx_Shrink_hGUI] = 0



		Case $C_AppHelper_Commander_Action_GetCppSoldierInfo

			If StringLeft($sActionData,2) <> '0x' Then $sActionData = '0x'&$sActionData
			$AppHelper_CPP_Soldier_hCommunicationGUI = HWnd($sActionData)




	EndSwitch


EndFunc



