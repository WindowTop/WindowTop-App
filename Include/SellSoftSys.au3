#include-once
#include 'Key.au3'
#include <MsgBoxConstants.au3>



Func SellSoftSys_Run()

; Check if the software is activated. if so then return here
	If Key_Validate(GetSet('Main','LicenseKey',Null)) Then
		$SellSoftSys_bIsActivated = True
		Return
	EndIf



; The software is not activated


; Get the register time
	$SellSoftSys_TrialRegisterTime = GetSet('Main','TrialRegisterTime','')
	If $SellSoftSys_TrialRegisterTime Then
		$SellSoftSys_iTrialModeDaysDiff = _DateDiff ('d', $SellSoftSys_TrialRegisterTime, _NowCalc())
		If @error Or $SellSoftSys_iTrialModeDaysDiff < 0 Then $SellSoftSys_TrialRegisterTime = Null
	EndIf

	If Not $SellSoftSys_TrialRegisterTime Then

		If Number(GetSet('Main','SuggestProVer_'&$ProgramVersion_Text,1)) Then
			SellSoftSys_SuggestProGUI(True,'Would you like to use the Pro version?',True)
			Do

				$Software_MSG = GUIGetMsg(1)
				aExtraFuncCalls_CallFuncs()
			Until SellSoftSys_SuggestProGUI() Or Not $SellSoftSys_hSuggestProGUI

			;aExtraFuncCalls_AddFunc(SellSoftSys_SuggestProGUI)
		EndIf

	Else
		If $SellSoftSys_iTrialModeDaysDiff <= $C_SellSoftSys_iTrialModeMaxDays Then
			SellSoftSys_Set30DaysMode()
		Else

			; TODO - suggest to buy the software now

			If Number(GetSet('Main','Show30DEndedMsg',1)) Then
				SellSoftSys_30DaysEndedMsg(True, True)
				Do
					$Software_MSG = GUIGetMsg(1)
					aExtraFuncCalls_CallFuncs()
				Until SellSoftSys_30DaysEndedMsg()
			EndIf

		EndIf
	EndIf

EndFunc



Func SellSoftSys_SuggestProGUI($bStart = False, $sTitle = Null, $bShowNotShowAgain = False)

	Local Static $StartTrial_Button, $ActivateNow_Button, $Close_Button, $NotShowAgain_Checkbox

	If $bStart Then


		If $SellSoftSys_hSuggestProGUI Then
			WinActivate($SellSoftSys_hSuggestProGUI)
			Return
		EndIf


		TrayItemSetState($Tray_WTP_ActivationState,$TRAY_DISABLE)
		TrayItemSetState($Tray_ActivationState,$TRAY_DISABLE)

		Local $iXsize = Round(@DesktopWidth*0.8), $iYsize = Round(@DesktopHeight*0.8), $iYbuttonPos, _
		$iYoffset

		If $bShowNotShowAgain Then
			$iYoffset = 37

		Else
			$iYbuttonPos = $iYsize-46
			$NotShowAgain_Checkbox = -1
			$iYoffset = 5
		EndIf



		$iYbuttonPos = $iYsize-46-$iYoffset

		$SellSoftSys_hSuggestProGUI = GUICreate($sTitle, $iXsize, $iYsize)

		If Not $SellSoftSys_bIsTrailMode Then
			$tmp = 'Start '&$C_SellSoftSys_iTrialModeMaxDays&' days trial'
		Else
			$tmp = $C_SellSoftSys_iTrialModeMaxDays-$SellSoftSys_iTrialModeDaysDiff&' days left'
		EndIf

		$StartTrial_Button = GUICtrlCreateButton($tmp, 183, $iYbuttonPos, 149, 40)
		GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
		If $SellSoftSys_TrialRegisterTime Then GUICtrlSetState(-1,$GUI_DISABLE)


		$ActivateNow_Button = GUICtrlCreateButton("Activate / Buy now", 18, $iYbuttonPos, 149, 40)
		GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
		$Close_Button = GUICtrlCreateButton("Close", $iXsize-322, $iYbuttonPos, 305, 40)
		If $bShowNotShowAgain Then
			$NotShowAgain_Checkbox = GUICtrlCreateCheckbox("Do not show this window again", 22, $iYsize-$iYoffset, 644, 23)
			GUICtrlSetFont(-1, 14, 400, 0, "Tahoma")
			GUICtrlSetState(-1,$GUI_CHECKED)
		EndIf
		GUISetState(@SW_SHOW)



		$oIE = _IECreateEmbedded()
		GUICtrlCreateObj($oIE, 1, 1, $iXsize-1, $iYsize-61-$iYoffset)


		_IENavigate($oIE,'http://windowtop.info/sells/SuggestProVer/page.html',0)
		;ConsoleWrite(@error &' (L: '&@ScriptLineNumber&')'&@CRLF)

		#cs
		_IENavigate($oIE,'about:blank')
		$oBody = _IETagNameGetCollection($oIE, "body", 0)

		;_IEDocInsertHTML($oBody, FileRead('D:\My Developments\Programs\WindowTop\WindowTop\Resources\SuggestProVer.html'), "afterbegin")
		_IEDocInsertHTML($oBody, _ResourceGetAsString('SuggestProVerText'), "afterbegin")
		#ce

		Return
	EndIf





	If $Software_MSG[1] <> $SellSoftSys_hSuggestProGUI Then Return


	Switch $Software_MSG[0]
		Case $ActivateNow_Button

			If Not $SellSoftSys_hActivateGUI Then
				SellSoftSys_ActivateGUI(True)
				aExtraFuncCalls_AddFunc(SellSoftSys_ActivateGUI)
			Else
				WinActivate($SellSoftSys_hActivateGUI)
			EndIf



		Case $StartTrial_Button
			If Not $SellSoftSys_bIsActivated Then
				$SellSoftSys_TrialRegisterTime = _NowCalc()
				IniWrite($ini,'Main','TrialRegisterTime',$SellSoftSys_TrialRegisterTime)
				SellSoftSys_Set30DaysMode()

				Tray_WindowTopPro_ActivationState_SetText()
				Tray_ActivationState_SetText()

				Tray_AllProFeaturesSetState($TRAY_CHECKED)
				If $bIsInstalled Then

					Settings_LoadProFeaturesSettings()
					ProFe_DisableEnableAll(1)

					Local $iWait = 15

					$tmp = 'Thank you for activating WindowTop Pro (30 days trial)!'&@CRLF&@CRLF&'The following features are activated:'&@CRLF&'* Dark Mode Pro'&@CRLF
					If @OSVersion = 'WIN_10' Then $tmp &= '* Smart Aero'&@CRLF

					$tmp &= @CRLF

					If @OSVersion <> 'WIN_10' Then
						$tmp &= 'NOTE: The feature "Smart Aero" is temporarily available for Windows 10 only.'&@CRLF& _
															'This feature is disabled. Please wait for later versions'&@CRLF
						$iWait = 180
					EndIf

					$tmp &= 'Enjoy!'

				MsgBox(64,'WindowTop is Activated for 30 Days!',$tmp,$iWait)


				Else
					MsgBox(64,'30 Days trial started','Thank you for using WindowTop Pro.'&@CRLF&@CRLF& _
					'NOTE:'&@CRLF&@CRLF&'The following features WILL NOT WORK unless you will install the software:'& _
					@CRLF&'* Smart Aero (Windows 10 only)'&@CRLF&'* Dark Mode Pro'&@CRLF&@CRLF&'Please install the software if you want to use these features.'&@CRLF&@CRLF&'Enjoy!')
				EndIf

			EndIf
			ContinueCase

		Case $GUI_EVENT_CLOSE, $Close_Button

			If $NotShowAgain_Checkbox <> -1 And GUICtrlRead($NotShowAgain_Checkbox) = $GUI_CHECKED Then IniWrite($ini,'Main','SuggestProVer_'&$ProgramVersion_Text,0)

			GUIDelete($SellSoftSys_hSuggestProGUI)
			$SellSoftSys_hSuggestProGUI = Null


			TrayItemSetState($Tray_WTP_ActivationState,$TRAY_ENABLE)
			TrayItemSetState($Tray_ActivationState,$TRAY_ENABLE)
			Return True
	EndSwitch





EndFunc

Func SellSoftSys_ActivateGUI($bStart = False)


	Local Static $PurchaseActivation_Button, $ActivationCode_Input, $ActivateNow_Button

	If $bStart Then

		If $SellSoftSys_hSuggestProGUI Then WinSetState($SellSoftSys_hSuggestProGUI,Null,@SW_DISABLE)

		$SellSoftSys_hActivateGUI = GUICreate("Activate WindowTop", 492, 117,-1,-1,-1,-1,$SellSoftSys_hSuggestProGUI)
		$PurchaseActivation_Button = GUICtrlCreateButton("Purchase activation code", 15, 65, 461, 37)
		GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
		GUICtrlCreateLabel("Activation code:", 13, 11, 268, 17)
		GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
		$ActivationCode_Input = GUICtrlCreateInput(Null, 21, 32, 346, 21)
		$ActivateNow_Button = GUICtrlCreateButton("Activate now", 378, 31, 99, 25)
		GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
		GUISetState(@SW_SHOW)
		Return
	EndIf


	If $Software_MSG[1] <> $SellSoftSys_hActivateGUI Then Return


	Switch $Software_MSG[0]

		Case $PurchaseActivation_Button

			ShellExecute('http://windowtop.info/product/windowtop-activation-key/')
			;SellSoftSys_BeforeYouBuy(True,$SellSoftSys_hActivateGUI)

		Case $ActivateNow_Button


		; Read the key from the input
			$tmp = GUICtrlRead($ActivationCode_Input)
		; Validate the Key
			If Not Key_Validate($tmp) Then
				MsgBox(48,'ERROR','The key is not valid',5,$SellSoftSys_hActivateGUI)
				Return
			EndIf

		; The key is valid so...

		; Write the key in the settings
			IniWrite($ini,'Main','LicenseKey',$tmp)


		; Activate WindowTop
			If $SellSoftSys_bIsTrailMode Then
				$SellSoftSys_bIsTrailMode = False
				AdlibUnRegister(SellSoftSys_Adlib_CheckActivationState)
			EndIf


			$SellSoftSys_bIsActivated = True
			Tray_WindowTopPro_ActivationState_SetText()
			Tray_ActivationState_SetText()

			Tray_AllProFeaturesSetState($TRAY_CHECKED)

			If $bIsInstalled Then
				Settings_LoadProFeaturesSettings()
				ProFe_DisableEnableAll(1)
				Local $iWait = 15

				$tmp = 'Thank you for activating WindowTop Pro!'&@CRLF&@CRLF&'The following features are activated:'&@CRLF&'* Dark Mode Pro'&@CRLF
				If @OSVersion = 'WIN_10' Then $tmp &= '* Smart Aero'&@CRLF

				$tmp &= @CRLF

				If @OSVersion <> 'WIN_10' Then
					$tmp &= 'NOTE: The feature "Smart Aero" is temporarily available for Windows 10 only.'&@CRLF& _
														'This feature is disabled. Please wait for later versions'&@CRLF
					$iWait = 180
				EndIf

				$tmp &= 'Enjoy!'

				MsgBox(64,'WindowTop is Activated!',$tmp,$iWait)
			Else
				MsgBox(64,'WindowTop is Activated!','Thank you for activating WindowTop Pro!'&@CRLF&@CRLF& _
					'NOTE:'&@CRLF&@CRLF&'The following features WILL NOT WORK unless you will install the software:'& _
					@CRLF&'Smart Aero (Windows 10 only)'&'* Dark Mode Pro'&@CRLF&@CRLF&'Please install the software if you want to use these features.'&@CRLF&@CRLF&'Enjoy!')
			EndIf

			If $SellSoftSys_hSuggestProGUI Then
				GUIDelete($SellSoftSys_hSuggestProGUI)
				$SellSoftSys_hSuggestProGUI = Null
				TrayItemSetState($Tray_WTP_ActivationState,$TRAY_ENABLE)
				TrayItemSetState($Tray_ActivationState,$TRAY_ENABLE)
				aExtraFuncCalls_RemoveFunc(SellSoftSys_SuggestProGUI)
			EndIf

			If $SellSoftSys_h30DaysEndedMsg Then
				GUIDelete($SellSoftSys_h30DaysEndedMsg)
				$SellSoftSys_h30DaysEndedMsg = Null
				aExtraFuncCalls_RemoveFunc(SellSoftSys_30DaysEndedMsg)
			EndIf

			ContinueCase

		Case $GUI_EVENT_CLOSE

			GUIDelete($SellSoftSys_hActivateGUI)
			$SellSoftSys_hActivateGUI = Null
			If $SellSoftSys_hSuggestProGUI Then
				WinSetState($SellSoftSys_hSuggestProGUI,Null,@SW_ENABLE)
				WinActivate($SellSoftSys_hSuggestProGUI)
			EndIf
			aExtraFuncCalls_RemoveFunc(SellSoftSys_ActivateGUI)
	EndSwitch




EndFunc







Func SellSoftSys_30DaysEndedMsg($bStart = False, $bShowAgainMsg = False)
	Local Static $UseFree_Button, $BuyOrRegister_Button, $NotShowAgain_Checkbox

	If $bStart Then

		Local $iYsize
		If Not $bShowAgainMsg Then
			$iYsize = 240
		Else
			$iYsize = 265
		EndIf

		$SellSoftSys_h30DaysEndedMsg = GUICreate('WindowTop - '&$C_SellSoftSys_iTrialModeMaxDays&"-day trial expired", 608, $iYsize)
		GUICtrlCreateLabel($C_SellSoftSys_iTrialModeMaxDays&"-day trial expired", -2, 8, 611, 33, $SS_CENTER)
		GUICtrlSetFont(-1, 18, 400, 4, "Tahoma")
		GUICtrlSetColor(-1, 0xFF0000)
		GUICtrlCreateLabel("The "&$C_SellSoftSys_iTrialModeMaxDays&"-day trial period is over. In order to get the best from WindowTop, you need to buy a license key to activate the software." & _
		@CRLF&@CRLF&'Or you can continue using WindowTop but without the Pro features and for non commercial environment only.', 16, 54, 580,120)
		GUICtrlSetFont(-1, 14, 400, 0, "Tahoma")

		$UseFree_Button = GUICtrlCreateButton("Use free version ", 408, 180, 155, 41)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
		$BuyOrRegister_Button = GUICtrlCreateButton("Buy / Register full version ", 45, 180, 195, 41)
		GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")

		If $bShowAgainMsg Then
			$NotShowAgain_Checkbox = GUICtrlCreateCheckbox("Do not show me this massage again", 25, 235, 353, 20)
			GUICtrlSetFont(-1, 12, 400, 0, "Tahoma")
		Else
			$NotShowAgain_Checkbox = -1
		EndIf

		GUISetState(@SW_SHOW)

		Return
	EndIf


	If Not $SellSoftSys_h30DaysEndedMsg Then Return True

	If $Software_MSG[1] <> $SellSoftSys_h30DaysEndedMsg Then Return


	Switch $Software_MSG[0]
		Case $BuyOrRegister_Button


			If Not $SellSoftSys_hActivateGUI Then
				SellSoftSys_ActivateGUI(True)
				aExtraFuncCalls_AddFunc(SellSoftSys_ActivateGUI)
			Else
				WinActivate($SellSoftSys_hActivateGUI)
			EndIf


		Case $UseFree_Button
			ContinueCase
		Case $GUI_EVENT_CLOSE
			If $NotShowAgain_Checkbox <> -1 And GUICtrlRead($NotShowAgain_Checkbox) = $GUI_CHECKED Then _
				IniWrite($ini,'Main','Show30DEndedMsg',0)
			GUIDelete($SellSoftSys_h30DaysEndedMsg)
			$SellSoftSys_h30DaysEndedMsg = Null
			Return True
	EndSwitch



EndFunc




Func SellSoftSys_Set30DaysMode()


	$SellSoftSys_bIsTrailMode = True
	$SellSoftSys_bIsActivated = True

	AdlibRegister(SellSoftSys_Adlib_CheckActivationState,3600000)
EndFunc

Func SellSoftSys_Remove30DaysMode()

	$SellSoftSys_bIsTrailMode = False
	$SellSoftSys_bIsActivated = False
	ProFe_DisableEnableAll(0)
	AdlibUnRegister(SellSoftSys_Adlib_CheckActivationState)


EndFunc

Func SellSoftSys_Adlib_CheckActivationState()

	$SellSoftSys_iTrialModeDaysDiff = _DateDiff ('d', $SellSoftSys_TrialRegisterTime, _NowCalc())



	If $SellSoftSys_iTrialModeDaysDiff > $C_SellSoftSys_iTrialModeMaxDays Then
		SellSoftSys_Remove30DaysMode()
		Tray_AllProFeaturesSetState($TRAY_DISABLE)

		SellSoftSys_30DaysEndedMsg(True, False)
		aExtraFuncCalls_AddFunc(SellSoftSys_30DaysEndedMsg)

	EndIf

	Tray_WindowTopPro_ActivationState_SetText()
	Tray_ActivationState_SetText()





EndFunc
