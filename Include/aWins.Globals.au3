




Global Enum $C_aWins_idx_hWin , _
			$C_aWins_idx_hMask , _
			$C_aWins_idx_hMask_hMag , _
			$C_aWins_idx_hMask_bIsHidden, _
			$C_aWins_idx_ProcessName , _
			$C_aWins_idx_x_pos , _
			$C_aWins_idx_y_pos , _
			$C_aWins_idx_x_size , _
			$C_aWins_idx_y_size , _
			$C_aWins_idx_AverageColor , _
			$C_aWins_idx_hMB_fixed_x , _
			$C_aWins_idx_MwSettingsPage , _
			$C_aWins_idx_hMask_hMag_active , _
			$C_aWins_idx_IsTop , _
			$C_aWins_idx_IsTop_old, _
			$C_aWins_idx_opacityactive , _
			$C_aWins_idx_opacitylevel , _
			$C_aWins_idx_opacitylevel_old, _
			$C_aWins_idx_aeroactive, _
			$C_aWins_idx_aero_blur, _
			$C_aWins_idx_aero_bkBrightness, _
			$C_aWins_idx_aero_onlyDesktop, _
			$C_aWins_idx_aero_background, _
			$C_aWins_idx_aero_darkBackground, _
			$C_aWins_idx_aero_images, _
			$C_aWins_idx_aero_texts, _
			$C_aWins_idx_Shrink_hGUI, _
			$C_aWins_idx_Shrink_hGUI_label, _
			$C_aWins_idx_Shrink_hGUI_hGraphics, _
			$C_aWins_idx_Shrink_hGUI_hImage, _
			$C_aWins_idx_Shrink_hGUI_aPos, _
			$C_aWins_idx_IsClickThrough , _
			$C_aWins_idx_ClickThrough_IsTop_old, _
			$C_aWins_idx_PreviousExStyle , _
			$C_aWins_idxmax

;Global Const $C_aWins_idx_IsClickThrough_hDisableLayer = 13



Global $aWins[1][$C_aWins_idxmax] = [[0]]

Global Const $C_aWins_update_updaterate = 100

Global $aWins_Shrink_LastGUI, $aWins_Shrink_UpdateImageTimer = 0, $aWins_Shrink_TimerDiff
Global Const $C_aWins_Shrink_UpdateTime = 5000


Global $aWins_aBlackedWins[0]

Global $aWins_iAppliedDPI




;Global $aWins_UpdateNewActiveWin_disable = False