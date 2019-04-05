Global $Software_MSG[5]
Global $g_mw_timer;,$g_mw_g_aWinsCopy


Global Const $C_idx_Msg_CtrlID = 0
Global Const $C_idx_Msg_GUI = 1

Global $bIsExiting = False

#Region נבדוק אם התוכנה מותקנת או לא ונצהיר משתנה שאומר את התשובה
	Global $bIsInstalled
	If StringInStr(@ScriptDir,@ProgramFilesDir) Then $bIsInstalled = True
	;$bIsInstalled = True ; <----------------------------------- DEBUG
#EndRegion


#Region  החלק שנוגע לקובץ הגדרות התוכנה והתיקייה שבה ההגדרות ודברים זמניים מורדים

	Global $C_IniFileName = 'WindowTop.Settings'

	Global $ProgramDataDir

	If $bIsInstalled Then
		$ProgramDataDir = @AppDataDir&'\WindowTop'
		DirCreate($ProgramDataDir)

	Else
		$ProgramDataDir = @ScriptDir
	EndIf

	;$ProgramDataDir = @ScriptDir ; <----------------------------------- DEBUG
	$ini = $ProgramDataDir&'\'&$C_IniFileName

#EndRegion






Global Const $ProgramPcessName = 'WindowTop.exe'
Global Const $ProgramVersion_Text = 'v3.0.6'
Global Const $C_DownloadPage = 'http://windowtop.info/stable-versions/'



Global Const $gcmb_showtimetrigger = 280 ; אחרי כמה זמן בדיוק מרגע שחץ העכבר נמצא על סימן החץ, יפתח תפריט האפשרויות על החלון

Global Const $g_mw_timer_max_timerdiff_slow = 500,$g_mw_timer_max_timerdiff_fast = 125,$g_mw_timer_max_timerdiff_reset = 250
Global Const $g_adlib_maintainWins_register_timer_fast = 10,$g_adlib_maintainWins_register_timer_slow = 100
Global $g_mw_max_timerdiff = $g_mw_timer_max_timerdiff_slow,$g_mw_timerdiff_change_timer,$g_adlib_maintainWins_register_timer; = $g_adlib_maintainWins_register_timer_fast
Global $g_mw_hMag_update_timer,$g_mw_hMag_update_timerdiff
Global $g_mw_IsNewWinPos, $g_mw_IsNewWinPos_timer
Global $g_mw_tmp_msg
Global $g_mw_hMag_aFilterWins = -1
Global Const $g_mw_hMag_update_refreshrate = 40



#Region Opacity Free Defaults
	Global Const $C_def_OpacityLevel = 75
#EndRegion







Global $g_DummyTopGui


Global $bDisableMenuToolbar

Global $user32_dll

;~ Global Const $C_Tray_TClickThroughForAllTransWins_text = 'Enable/Disable "Click Through" mode for all transparent windows'


; HotKeys

Global $ToggleClickThrough_OpacityWins_bActive = False


Global $bRunFeatureInThislProcess = False, $bIsExternalProcess = False

Global $C_GuiShrink_xySize = 80*GetAppliedDPI() ; The size of the shrinked window






Global $bShowClickTWarning









