
Global $AppHelper_Soldier_iPid, $AppHelper_Soldier_hCommunicationGUI
Global $AppHelper_CPP_Soldier_iPid, $AppHelper_CPP_Soldier_hCommunicationGUI
Global $AppHelper_Commander_iPid, $AppHelper_Commander_hCommunicationGUI

Global Enum $C_AppHelper_Soldier_Action_SetDarkMode, $C_AppHelper_Soldier_Action_Shrink, _
			$C_AppHelper_Soldier_Action_WinDeleted, _
			$C_AppHelper_Soldier_Action_MinimizeAllShrinkedWinsToTaskbar, _
			$C_AppHelper_Soldier_Action_UnShrinkAllWindows, _
			$C_AppHelper_Soldier_Action_ExitEvent

Global Const $C_AppHelper_CPP_Soldier_Action_SetDarkMode = 1, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_Enable = 2, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_Disable = 3, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_SetBlurLevel = 4, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_SetBrightnessLevel = 5, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_SetShowOnlyDesktopMode = 6, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_SetBackgroundLevel = 7, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_EnableDisableDarkBk = 8, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_SetImagesLevel = 9, _
			 $C_AppHelper_CPP_Soldier_Action_SmartAero_SetTextsLevel = 10, _
			 $C_AppHelper_CPP_Soldier_Action_WinDeleted = 11




Global Const $C_AppHelper_Commander_Action_GetSoldierInfo = 1, _
			$C_AppHelper_Commander_Action_ShrinkModeIsDisabled = 2, _
			$C_AppHelper_Commander_Action_GetCppSoldierInfo = 3

Global $AppHelper_iWin2Delete