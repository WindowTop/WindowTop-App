
#Region Tray - HotKeys

	Func Tray_HotKeys_TClickThroughForAllTransWins_SetText()
		Tray_HotKeys_SetText($Tray_HK_TClickThroughForAllTransWins,$TClickThroughAnyOpcWin_aSKey, 'Enable/Disable "Click Through" mode for all transparent windows')
	EndFunc

	Func Tray_HotKeys_TSetTop_SetText()
		Tray_HotKeys_SetText($Tray_HK_TSetTop,$SetWindowTop_aSKey, 'Enable/Disable "Set Top" mode for the active window')
	EndFunc

	Func Tray_HotKeys_SetWindowOpacity_SetText()
		Tray_HotKeys_SetText($Tray_HK_SetWindowOpacity,$SetWindowOpc_aSKey, 'Enable/Disable window opacity')
	EndFunc

	Func Tray_HotKeys_TShrink_SetText()
		Tray_HotKeys_SetText($Tray_HK_SetShrinkMode,$TShrink_aSKey, 'Enable/Disable "Shrink" mode')
	EndFunc

	Func Tray_HotKeys_SetText($TrayItem,$aKeyData, $sText)
		If $aKeyData[$SoftHotKeys_idx_key] <= 0 Then
			$tmp = 'NONE'
		Else
			$tmp = SoftHotKeys_GetKeyShortcutString($aKeyData)
		EndIf
		TrayItemSetText($TrayItem,$sText&' ['&$tmp&']')
	EndFunc


	Func Tray_HotKeys_ItemsSetState($State)
		TrayItemSetState($Tray_HK_TClickThroughForAllTransWins, $State)
		TrayItemSetState($Tray_HK_TSetTop, $State)
		TrayItemSetState($Tray_HK_SetWindowOpacity, $State)
		TrayItemSetState($Tray_HK_SetShrinkMode, $State)
	EndFunc
#EndRegion


#Region Tray - WindowTop PRO

	Func Tray_WindowTopPro_ActivationState_SetText()

		;If $bIsInstalled Then
			If Not $SellSoftSys_bIsActivated Then
				If Not $SellSoftSys_TrialRegisterTime Then
					TrayItemSetText($Tray_WTP_ActivationState,'Not activated, click to start '&$C_SellSoftSys_iTrialModeMaxDays& _
					' days trial / buy and activate now')
				Else
					TrayItemSetText($Tray_WTP_ActivationState,'Not activated, click to buy and activate now')
				EndIf
			Else
				If Not $SellSoftSys_bIsTrailMode Then
					TrayItemSetText($Tray_WTP_ActivationState,'WindowTop Pro is activated')
				Else
					TrayItemSetText($Tray_WTP_ActivationState,'Activated for '&$C_SellSoftSys_iTrialModeMaxDays-$SellSoftSys_iTrialModeDaysDiff&' days, Click to change!')
				EndIf
			EndIf
		;Else
		;	TrayItemSetText($Tray_WTP_ActivationState,'Please install WindowTop in order to use *all* Pro features (click for more info)')

		;EndIf
	EndFunc

	Func Tray_AllProFeaturesSetState($iState)
		TrayItemSetState($Tray_WTP_DarkModePro,$iState)
		If @OSVersion = 'WIN_10' Then TrayItemSetState($Tray_WTP_SmartAero,$iState)
	EndFunc



	Func Tray_ActivationState_SetText()
		If $SellSoftSys_bIsActivated Then
			If Not $SellSoftSys_bIsTrailMode Then
				TrayItemSetText($Tray_ActivationState,'Activated for commercial environment')
			Else
				TrayItemSetText($Tray_ActivationState, 'Commercial environment for '&$C_SellSoftSys_iTrialModeMaxDays-$SellSoftSys_iTrialModeDaysDiff&' days, Click to change!')
			EndIf
		Else
			TrayItemSetText($Tray_ActivationState,'For non-commercial environment (click to change)')
		EndIf
	EndFunc



#EndRegion