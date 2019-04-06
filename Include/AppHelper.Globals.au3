
Global $AppHelper_Soldier_iPid, $AppHelper_Soldier_hCommunicationGUI
Global $AppHelper_CPP_Soldier_iPid, $AppHelper_CPP_Soldier_hCommunicationGUI
Global $AppHelper_Commander_iPid, $AppHelper_Commander_hCommunicationGUI

Global Enum $C_AppHelper_Soldier_Action_SetDarkMode, $C_AppHelper_Soldier_Action_Shrink, _
			$C_AppHelper_Soldier_Action_WinDeleted, _
			$C_AppHelper_Soldier_Action_MinimizeAllShrinkedWinsToTaskbar, _
			$C_AppHelper_Soldier_Action_UnShrinkAllWindows, _
			$C_AppHelper_Soldier_Action_ExitEvent



Global Const $C_AppHelper_Commander_Action_GetSoldierInfo = 1, _
			$C_AppHelper_Commander_Action_ShrinkModeIsDisabled = 2, _
			$C_AppHelper_Commander_Action_GetCppSoldierInfo = 3

Global $AppHelper_iWin2Delete