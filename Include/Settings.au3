
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
		If $bIsInstalled And ($SellSoftSys_bIsActivated Or $SellSoftSys_bIsTrailMode) Then

			$ProFe_bDarkMode = Number(GetSet('ProFeatures','DarkMode',0))
			If @OSVersion = 'WIN_10' Then $ProFe_bSmartAero = Number(GetSet('ProFeatures','SmartAero',0))

			Settings_LoadProFeaturesSettings()

		EndIf
	#EndRegion



	#Region Other
		$bShowClickTWarning = Number(GetSet('Other','ShowCTWarning',1))



	#EndRegion


EndFunc

Func Settings_LoadProFeaturesSettings()
		$ProFe_SmartAero_BackgroundBlur = Number(GetSet('ProFeatures','SmartAero_BackgroundBlur',$C_ProFe_def_SmartAero_BackgroundBlur))
		$ProFe_SmartAero_BkBrightness = Number(GetSet('ProFeatures','SmartAero_BkBrightness',$C_ProFe_def_SmartAero_BkBrightness))
		$ProFe_SmartAero_OnlyDesktop = Number(GetSet('ProFeatures','SmartAero_OnlyDesktop',$C_ProFe_def_SmartAero_OnlyDesktop))
		$ProFe_SmartAero_Background = Number(GetSet('ProFeatures','SmartAero_Background',$C_ProFe_def_SmartAero_Background))
		$ProFe_SmartAero_DarkBackground = Number(GetSet('ProFeatures','SmartAero_DarkBackground',$C_ProFe_def_SmartAero_DarkBackground))
		$ProFe_SmartAero_Images = Number(GetSet('ProFeatures','SmartAero_Images',$C_ProFe_def_SmartAero_Images))
		$ProFe_SmartAero_Texts = Number(GetSet('ProFeatures','SmartAero_Texts',$C_ProFe_def_SmartAero_Texts))


		$ProFe_SmartAero_BackgroundBlur_old = $ProFe_SmartAero_BackgroundBlur
		$ProFe_SmartAero_BkBrightness_old = $ProFe_SmartAero_BkBrightness
		$ProFe_SmartAero_OnlyDesktop_old = $ProFe_SmartAero_OnlyDesktop
		$ProFe_SmartAero_Background_old = $ProFe_SmartAero_Background
		$ProFe_SmartAero_DarkBackground_old = $ProFe_SmartAero_DarkBackground
		$ProFe_SmartAero_Images_old = $ProFe_SmartAero_Images
		$ProFe_SmartAero_Texts_old = $ProFe_SmartAero_Texts

EndFunc

Func Settings_Save()
	#Region Pro Features
		If $ProFe_bSmartAero Then
			If $ProFe_SmartAero_BackgroundBlur <> $ProFe_SmartAero_BackgroundBlur_old Then IniWrite($ini,'ProFeatures','SmartAero_BackgroundBlur',$ProFe_SmartAero_BackgroundBlur)
			If $ProFe_SmartAero_BkBrightness <> $ProFe_SmartAero_BkBrightness_old Then IniWrite($ini,'ProFeatures','SmartAero_BkBrightness',$ProFe_SmartAero_BkBrightness)
			If $ProFe_SmartAero_OnlyDesktop <> $ProFe_SmartAero_OnlyDesktop_old Then IniWrite($ini,'ProFeatures','SmartAero_OnlyDesktop',$ProFe_SmartAero_OnlyDesktop)
			If $ProFe_SmartAero_Background <> $ProFe_SmartAero_Background_old Then IniWrite($ini,'ProFeatures','SmartAero_Background',$ProFe_SmartAero_Background)
			If $ProFe_SmartAero_DarkBackground <> $ProFe_SmartAero_DarkBackground_old Then IniWrite($ini,'ProFeatures','SmartAero_DarkBackground',$ProFe_SmartAero_DarkBackground)
			If $ProFe_SmartAero_Images <> $ProFe_SmartAero_Images_old Then IniWrite($ini,'ProFeatures','SmartAero_Images',$ProFe_SmartAero_Images)
			If $ProFe_SmartAero_Texts <> $ProFe_SmartAero_Texts_old Then IniWrite($ini,'ProFeatures','SmartAero_Texts',$ProFe_SmartAero_Texts)
		EndIf
	#EndRegion


EndFunc




