
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
; REMOVED
#EndRegion