


; _GuiCtrlIsMouseOver
Global Const $C_gcsmo_iMouseOverTime = 800
Global Const $C_gcsmo_OnlyWhenGUIActive = 1
Global Const $C_gcsmo_aCtrls_max = 11
Global Const $C_gcsmo_aCtrls_ix_hGui = 1
Global Const $C_gcsmo_aCtrls_ix_active_ctrl = 2
Global Const $C_gcsmo_aCtrls_ix_active_ctrl_index = 3
Global Const $C_gcsmo_aCtrls_ix_timer = 4
Global Const $C_gcsmo_aCtrls_ix_OverTimeTrigger = 5
Global Const $C_gcsmo_aCtrls_ix_retuned = 6
Global Const $C_gcsmo_aCtrls_ix_OnOverFunction = 7
Global Const $C_gcsmo_aCtrls_ix_OnOverFunction_called = 8
Global Const $C_gcsmo_aCtrls_ix_extra_data = 9
Global Const $C_gcsmo_aCtrls_ix_OnlyWhenGuiActive = 10






Func _GuiCtrlIsMouseOver(ByRef $aGUICtrls, ByRef $msg, $bReturnIndex = 0,$CursorInfo = -1)

	If Not IsArray($CursorInfo) Then
		$CursorInfo = GUIGetCursorInfo($aGUICtrls[0][$C_gcsmo_aCtrls_ix_hGui])
		If @error Then Return SetError(1)
	EndIf

;~ 	Return ToolTip($CursorInfo[4])

	Local $iIndex

	If $CursorInfo[4] Then $iIndex = Array2DSearch($aGUICtrls,$CursorInfo[4],0,1,$aGUICtrls[0][0])

	If $CursorInfo[4] And $iIndex > 0 Then


		If $CursorInfo[4] <> $aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl] Then
			$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl] = $CursorInfo[4]
			If $aGUICtrls[0][$C_gcsmo_aCtrls_ix_retuned] Then $aGUICtrls[0][$C_gcsmo_aCtrls_ix_retuned] = 0

			Local $OnlyWhenGUIActive = $aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnlyWhenGuiActive]
			If String($aGUICtrls[$iIndex][$C_gcsmo_aCtrls_ix_OnlyWhenGuiActive]) <> '' Then _
			$OnlyWhenGUIActive = $aGUICtrls[$iIndex][$C_gcsmo_aCtrls_ix_OnlyWhenGuiActive]

			If $OnlyWhenGUIActive And Not MouseIsHoveredWnd($aGUICtrls[0][$C_gcsmo_aCtrls_ix_hGui]) Then _
			Return




;~ 			If $tmp > 0 Then

				;If $aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction_called] Then $aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction_called] = 0
				$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index] = $iIndex
				$aGUICtrls[0][$C_gcsmo_aCtrls_ix_timer] = TimerInit()
;~ 				ToolTip(1234)
;~ 			EndIf
		Else

			If Not $aGUICtrls[0][$C_gcsmo_aCtrls_ix_retuned] And $aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index] > 0 Then
				If $aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][$C_gcsmo_aCtrls_ix_OverTimeTrigger] Then
					Local $iMaxTime = $aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][$C_gcsmo_aCtrls_ix_OverTimeTrigger]
				Else
					Local $iMaxTime = $aGUICtrls[0][$C_gcsmo_aCtrls_ix_OverTimeTrigger]
				EndIf


				Local $sFunction = $aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction]
				If IsFunc($aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][$C_gcsmo_aCtrls_ix_OnOverFunction]) Then _
				$sFunction = $aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][$C_gcsmo_aCtrls_ix_OnOverFunction]

				If IsFunc($sFunction) And Not IsFunc($aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction_called]) Then
					$aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction_called] = $sFunction
;~ 					Call($sFunction,$aGUICtrls[0][$C_gcsmo_aCtrls_ix_hGui],$aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][0],1, _
;~ 					$aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][$C_gcsmo_aCtrls_ix_extra_data])

					$sFunction($aGUICtrls[0][$C_gcsmo_aCtrls_ix_hGui],$aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][0],1, _
								$aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][$C_gcsmo_aCtrls_ix_extra_data])
				EndIf


				If TimerDiff($aGUICtrls[0][$C_gcsmo_aCtrls_ix_timer]) >= $iMaxTime Then
					$aGUICtrls[0][$C_gcsmo_aCtrls_ix_retuned] = 1
					If Not $bReturnIndex Then
						If IsArray($msg) Then
							$msg[0] = $CursorInfo[4]
							$msg[1] = $aGUICtrls[0][$C_gcsmo_aCtrls_ix_hGui]
						Else
							$msg = $CursorInfo[4]
						EndIf
						Return $CursorInfo[4]
					Else
						$msg = $aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]
						Return $msg
					EndIf
				EndIf
			EndIf


		EndIf
	Else

		If $aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl] Then
			If IsFunc($aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction_called]) Then
;~ 				Call($aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction_called],$aGUICtrls[0][$C_gcsmo_aCtrls_ix_hGui],$aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][0],0, _
;~ 					$aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][$C_gcsmo_aCtrls_ix_extra_data])

					$aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction_called]($aGUICtrls[0][$C_gcsmo_aCtrls_ix_hGui],$aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][0],0, _
																			$aGUICtrls[$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index]][$C_gcsmo_aCtrls_ix_extra_data])
				$aGUICtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction_called] = 0
			EndIf

			$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl] = 0
			$aGUICtrls[0][$C_gcsmo_aCtrls_ix_active_ctrl_index] = 0
			;$aGUICtrls[0][$C_gcsmo_aCtrls_ix_retuned] = 0
		EndIf

	EndIf
EndFunc



;~ $C_gcsmo_aCtrls_ix_extra_data
Func _GuiCtrlMouseOver_CreateGuiCtrls($hGui,$iOverTimeTrigger = Default,$OnOverFunction = Default,$OnlyWhenGUIActive = Default)

	If $iOverTimeTrigger = Default Then $iOverTimeTrigger = $C_gcsmo_iMouseOverTime
	If $OnlyWhenGUIActive = Default Then $OnlyWhenGUIActive = $C_gcsmo_OnlyWhenGUIActive
	Local $aCtrls[1][$C_gcsmo_aCtrls_max] = [[0]]
	$aCtrls[0][$C_gcsmo_aCtrls_ix_hGui] = $hGui
	$aCtrls[0][$C_gcsmo_aCtrls_ix_OverTimeTrigger] = $iOverTimeTrigger
	If $OnOverFunction <> Default Then $aCtrls[0][$C_gcsmo_aCtrls_ix_OnOverFunction] = $OnOverFunction
	$aCtrls[0][$C_gcsmo_aCtrls_ix_OnlyWhenGuiActive] = $OnlyWhenGUIActive

	Return $aCtrls
EndFunc



Func _GuiCtrlMouseOver_AddCtrl(ByRef $aCtrls,$hCtrl,$OnOverFunction = Default,$ExtraData = Default ,$iOverTimeTrigger = Default, _
	$OnlyWhenGUIActive = Default)
	;If $iOverTimeTrigger = Default Then $iOverTimeTrigger = $C_gcsmo_iMouseOverTime
	$aCtrls[0][0] += 1
	ReDim $aCtrls[$aCtrls[0][0]+1][$C_gcsmo_aCtrls_max]
	$aCtrls[$aCtrls[0][0]][0] = $hCtrl
	If $iOverTimeTrigger <> Default Then $aCtrls[$aCtrls[0][0]][$C_gcsmo_aCtrls_ix_OverTimeTrigger] = $iOverTimeTrigger
	If $OnOverFunction <> Default Then $aCtrls[$aCtrls[0][0]][$C_gcsmo_aCtrls_ix_OnOverFunction] = $OnOverFunction
	If $ExtraData <> Default Then $aCtrls[$aCtrls[0][0]][$C_gcsmo_aCtrls_ix_extra_data] = $ExtraData
	If $OnlyWhenGUIActive <> Default Then $aCtrls[$aCtrls[0][0]][$C_gcsmo_aCtrls_ix_OnlyWhenGuiActive] = $OnlyWhenGUIActive

EndFunc

