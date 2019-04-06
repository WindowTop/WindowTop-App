
Func Settings_Load()

	#Region HotKeys
		SoftHotKeys_LoadKey_FromIni($TClickThroughAnyOpcWin_aSKey,'CThrTransWins')
		SoftHotKeys_LoadKey_FromIni($SetWindowTop_aSKey,'Top','0x5A,1')
		SoftHotKeys_LoadKey_FromIni($SetWindowOpc_aSKey,'Opacity','0x41,1')
		SoftHotKeys_LoadKey_FromIni($TShrink_aSKey,'Shrink','0x51,1')


		SoftHotKeys_RegisterKey($TClickThroughAnyOpcWin_aSKey)
		SoftHotKeys_RegisterKey($SetWindowTop_aSKey)
		SoftHotKeys_RegisterKey($SetWindowOpc_aSKey)
		SoftHotKeys_RegisterKey($TShrink_aSKey)
	#EndRegion

	#Region Menu arro toolbar
		$bDisableMenuToolbar = Number(GetSet('Main','DisableMenuToolbar',Null))
	#EndRegion

	#Region ToolBar

		$GUMe_WinOptions_iMaxItems = Number(GetSet('ToolBar','MaxItems',5))
		If $GUMe_WinOptions_iMaxItems < 1 Or $GUMe_WinOptions_iMaxItems > 5 Then $GUMe_WinOptions_iMaxItems = 5

		$GUMe_WinOptions_bkcolor = GetSet('ToolBar','BkColor',Null)
		If Not $GUMe_WinOptions_bkcolor Then $GUMe_WinOptions_bkcolor = $C_GUMe_WinOptions_def_bkcolor

		$GUMe_WinOptions_bDynamicBkColor = Number(GetSet('ToolBar','DynamicBkColor',1))




	#EndRegion

	#Region Arrow

		$GUMe_xPos_mode = Number(GetSet('Arrow','PosMode',$C_GUMe_xPos_mode_def))
		$GUMe_xPosFix = Number(GetSet('Arrow','PosOffset',$C_GUMe_xPosFix_def))



	#EndRegion


	#Region Pro Features
		; REMOVED
	#EndRegion



	#Region Other
		$bShowClickTWarning = Number(GetSet('Other','ShowCTWarning',1))



	#EndRegion


EndFunc



Func Settings_Save()
	#Region Pro Features
		; REMOVED
	#EndRegion


EndFunc




