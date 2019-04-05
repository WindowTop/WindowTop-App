



#Region *_WinOptions: varibals declaration

#EndRegion

; GUI
	Global  $GUIMenuButton_h = -1, _
			$GUIMenuButton_hOld, _
			$GUIMenuButton_hDrag, _
			$GUIMenuButton_hDC

; GUI menu
	Global $GUIMeBu_Menu = -1, $GUIMeBu_SaveWinSettings = -1, $GUIMeBu_MenuActive = False

; Settings
	Global	$GUIMenuButton_bDisableUpdatePos, _
			$GUIMenuButton_MouseOver_timer, _
			$GUMe_xPos_mode, _
			$GUMe_xPosFix



	Global Const $C_GUIMenuButton_DefXsize = 61, _
				 $C_GUIMenuButton_DefYsize = 14, _
				 $C_GUIMenuButton_max_y_show_area = 20, _
				 $C_GUMe_xPos_mode_Center = 1, $C_GUMe_xPos_mode_Left = 2, $C_GUMe_xPos_mode_Right = 3, _
				 $C_GUMe_xPos_mode_def = $C_GUMe_xPos_mode_Center, _
				 $C_GUMe_xPosFix_def = 10


; Mem settings
	Global	$GUIMenuButton_iActiveWin, $GUIMenuButton_iActiveWin_old


; Other
	Global  $GUIMenuButton_iIsDrag, _
			$GUIMenuButton_MouseOver












