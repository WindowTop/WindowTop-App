
; GUI
	Global  $GUMe_WinOptions_hgui = -1, _
			$GUMe_WinOptions_hgui_hgraphic, _
			$GUMe_WiOpt_OpacityGUI, _
			$GUMe_WiOpt_Opacity_SliderCtrl, _
			$GUMe_WiOpt_AeroGUI


; X and Y sizes
	Global $GUMe_WinOptions_x_size = 240
	Global Const $GUMe_WinOptions_y_size = 42



; Timers
	Global Const $C_GUMe_WinOptions_exit_timeout = 380

; Settings
	Global Const $C_GUMe_WinOptions_def_bkcolor = 0xF0F4F9

	Global $GUMe_WinOptions_iMaxItems
	Global $GUMe_WinOptions_bDynamicBkColor = True
	Global $GUMe_WinOptions_bkcolor
	Global $GUMe_WinOptions_OnHover_LineColor = 0xFF00A300
	Global $GUMe_WinOptions_Normal_LineColor = 0xFF000000
	Global $GUMe_WinOptions_Active_LineColor = 0xFF00A300

	Global Const $C_GUMe_WinOptions_OnHover_LineWidth = 1
	Global Const $C_GUMe_WinOptions_Normal_LineWidth = 1
	Global Const $C_GUMe_WinOptions_Active_LineWidth = 3
	Global $GUMe_WinOptions_HoveringTriggerTime = 275

	Global Const $C_NextBack_xSize = 17,$C_NextBack_xSpace = 2,$C_NextBack_xEnd = 21, _
	$C_NextBack_iFontSize = 14, $i0DifSpace = 5, $C_ButtonMenu_Button_xSize = 33, _
	$C_ButtonMenu_Button_xDiffSpace = 11, $C_ButtonMenu_Button_ySize = 28

	Global $GUMe_WiOpt_bDisableExitWhenOutMouse = False


; Buttons
	; IDs
		Global Const $GUMe_WinOptions_bl_id_top = 1, _
					 $GUMe_WinOptions_bl_id_opacity = 2, _
					 $GUMe_WinOptions_bl_id_shrink = 3, _
					 $GUMe_WinOptions_bl_id_dark = 4, _
					 $GUMe_WinOptions_bl_id_aero = 5

		Global $GUMe_WinOptions_aButtonsIds[6] = [5,$GUMe_WinOptions_bl_id_aero,$GUMe_WinOptions_bl_id_opacity,$GUMe_WinOptions_bl_id_top,$GUMe_WinOptions_bl_id_shrink,$GUMe_WinOptions_bl_id_dark]


	; Images

		Global  $GUMe_WinOptions_bl_img_top, _
				$GUMe_WinOptions_bl_img_opacity, _
				$GUMe_WinOptions_bl_img_dark, _
				$GUMe_WinOptions_bl_img_shrink, _
				$GUMe_WinOptions_bl_img_clickthrough, _
				$GUMe_WinOptions_bl_img_aero

				If @Compiled Then
					$GUMe_WinOptions_bl_img_top = 'img_set_top'
					$GUMe_WinOptions_bl_img_opacity = 'img_set_opacity'
					$GUMe_WinOptions_bl_img_dark = 'img_set_dark'
					$GUMe_WinOptions_bl_img_shrink = 'img_set_shrink'
					$GUMe_WinOptions_bl_img_aero = 'img_set_aero'




				Else
					$GUMe_WinOptions_bl_img_top = @ScriptDir&'\Resources\Images\WinBar\Buttons\Type A\set_top.png'
					$GUMe_WinOptions_bl_img_opacity = @ScriptDir&'\Resources\Images\WinBar\Buttons\Type A\set_opacity.png'
					$GUMe_WinOptions_bl_img_dark = @ScriptDir&'\Resources\Images\WinBar\Buttons\Type A\set_dark.png'
					$GUMe_WinOptions_bl_img_shrink = @ScriptDir&'\Resources\Images\WinBar\Buttons\Type A\set_shrink.png'
					$GUMe_WinOptions_bl_img_aero = @ScriptDir&'\Resources\Images\WinBar\Buttons\Type A\set_aero.png'
				EndIf




; No neame
	Global Const $C_GUMe_WinOptions_aButtons_idx_CtrlId = 0
	Global Const $C_GUMe_WinOptions_aButtons_idx_hCtrl = 1
	Global Const $C_GUMe_WinOptions_aButtons_idx_button_object = 2 ; <<--  is the $aButton for GUIImageButton_SetSquareFrame , GUIImageButton_SetNewImage, GUIImageButton_SetNewImage and more...
	Global Const $C_GUMe_WinOptions_aButtons_idx_IsActive = 3
	Global Const $GUMe_WinOptions_aButtons_max = 4



	Global  $GUMe_WinOptions_aCursorInfo_now[5] = [-1,-1,0,-1,-1], _
			$GUMe_WinOptions_aCursorInfo_new, _
			$GUMe_WinOptions_iHoveringCtrlIndex, _
			$GUMe_WinOptions_iLastActiveCtrlIndex = -1, _
			$GUMe_WinOptions_ButtonMenu_page_aButtons



	Global $ButtonMenu_Button_y_pos = Round(($GUMe_WinOptions_y_size-$C_ButtonMenu_Button_ySize)/2)




	Global $GUMeBu_WinOptions_ActiveBkColor











