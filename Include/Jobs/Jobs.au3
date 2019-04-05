#include-once
#include <WindowsConstants.au3>
#include <Array.au3>

Global $Jobs_hAppGUI, $Jobs_fActionDecider

; hGUI [.2.] Type [.1.] {.......}


Global Enum $Jobs_aRemoteApps_idx_hAppHwnd, $Jobs_aRemoteApps_idx_aAppInfo, $Jobs_aRemoteApps_idxmax
Global $Jobs_aRemoteApps[1][$Jobs_aRemoteApps_idxmax]

Global Enum $Jobs_aRemoteAppData_idx_iJobID, $Jobs_aRemoteAppData_idx_fFunc, $Jobs_aRemoteAppData_idxmax

Global $Jobs_Local_GetReturn_bIsNew ,$Jobs_Local_GetReturn_sData



Func Jobs_Init($hAppGUI = Default, $fActionDecider = Default)


	#cs
		with this function we create to ourself gui that will be for the communication
		and in case we are the server, we link our "Action Decider" function.
		this function will get the commands from a caller and basis of "Action ID" it will
		do the action it need to do...
		this function will also get the unique ID of this action that may be NULL
		and get the "Action Data" for the action to do, and get the GUI of the caller
		that it needs to know in order to know who is the caller and where to send the answer.


		If $fActionDecider is set, $fActionDecider must be like this:
		MyActionDecider($hCallerGUI, $iActionID, $sActionData, $iJobID)

		$hCallerGUI = who is the caller ?
		$iActionID = the action to do
		$sActionData = the data for the action to do
		$iJobID = The unique ID in the caller side (The caller will know to what function to call(with the server answer) with this unique ID)

	#ce


	; Set our GUI for communication
		If $hAppGUI <> Default Then
			$Jobs_hAppGUI = $hAppGUI
		Else
			$Jobs_hAppGUI = GUICreate(Null)
		EndIf

	; Set our Action Decider function in case we need to (in case we are/also are server)
		If $fActionDecider <> Default Then $Jobs_fActionDecider = $fActionDecider

	; Register WM_ massage
		GUIRegisterMsg($WM_COPYDATA, Jobs_WM_COPYDATA)

EndFunc


Func Jobs_CallAction($hRemoteGUI, $iActionID, $sActionData = Null, $fReturnFunc = Default, $iMaxTime = 5000)



	; If the GUI of the remote app (for communication) is not exist then return here
		If Not $hRemoteGUI Or Not WinExists($hRemoteGUI) Then Return SetError(1)

	; Set default vars
		If $fReturnFunc = Default Then $fReturnFunc = Jobs_GetReturn


	#cs
		The function send commad in this format:
		hGUI [.2.] Type [.1.] iActionID [.2.] sActionData [.2.] iJobID

		hGUI = the GUI of the caller
		Type = the type of the call - RET / REQ . In this case it will always be REQ that is request to preform action
		iActionID = The action to preform on the server side. The action identified by it's ID. every action have it own ID
		sActionData = Data for the action in string variable
		iJobID = it is like process PID - the ID of the action...
	#ce

	; Prepare the command to send to the server
		Local $sCommand = $Jobs_hAppGUI&'[.2.]REQ[.1.]'&$iActionID&'[.2.]'&$sActionData&'[.2.]'


		#cs
			In case we call to function on the caller side that will get the return from the server,
			we need to declare a "PID" (that is unique ID) for this call... Remember this call by a unique ID and assign to this ID
			the function we call when the server return an answer. the server will also know this unique ID. when the server will
			return it's answer, it will be linked to this unique ID. it will come with this unique ID.
			Then the client that got the data from the server, will look for this unique ID and call to the function that
			linked to this ID, with the server answer. the function that will be called will get the answer from the server.
		#ce


		Local $iAppIdx

		; If we need to call to function that get the return from the server, we start to build our unique ID
			If IsFunc($fReturnFunc) Then

				$iAppIdx = _ArraySearch($Jobs_aRemoteApps,$hRemoteGUI,1,0,0,0,1,$Jobs_aRemoteApps_idx_hAppHwnd)
				If $iAppIdx < 1 Then

					$Jobs_aRemoteApps[0][0] += 1
					ReDim $Jobs_aRemoteApps[$Jobs_aRemoteApps[0][0]+1][$Jobs_aRemoteApps_idxmax]
					$Jobs_aRemoteApps[$Jobs_aRemoteApps[0][0]][$Jobs_aRemoteApps_idx_hAppHwnd] = $hRemoteGUI
					Local $tmp[2][$Jobs_aRemoteAppData_idxmax]
					$tmp[0][0] = 1
					$tmp[1][$Jobs_aRemoteAppData_idx_iJobID] = 1
					$tmp[1][$Jobs_aRemoteAppData_idx_fFunc] = $fReturnFunc
					$Jobs_aRemoteApps[$Jobs_aRemoteApps[0][0]][$Jobs_aRemoteApps_idx_aAppInfo] = $tmp
					$sCommand &= '1'

				Else
					Local $tmp = $Jobs_aRemoteApps[$iAppIdx][$Jobs_aRemoteApps_idx_aAppInfo]
					Local $iJobID = 1
					While _ArraySearch($tmp,$iJobID,1,0,0,0,1,$Jobs_aRemoteAppData_idx_iJobID) > 0
						$iJobID += 1
					WEnd
					$tmp[0][0] += 1
					ReDim $tmp[$tmp[0][0]+1][$Jobs_aRemoteAppData_idxmax]
					$tmp[$tmp[0][0]][$Jobs_aRemoteAppData_idx_iJobID] = $iJobID
					$tmp[$tmp[0][0]][$Jobs_aRemoteAppData_idx_fFunc] = $fReturnFunc
					$Jobs_aRemoteApps[$Jobs_aRemoteApps[0][0]][$Jobs_aRemoteApps_idx_aAppInfo] = $tmp
					$sCommand &= $iJobID
				EndIf





			EndIf

	; Send the command to the server
		Jobs_SendData($hRemoteGUI,$sCommand)

	; If we need to wait for return HERE then we wait until we got the return
		If IsFunc($fReturnFunc) And $fReturnFunc = Jobs_GetReturn Then
			Local $iTimer = TimerInit(), $iTimer2 = $iTimer

			While 1
				Sleep(10)


				; Check every 1 sec if the process is exists. if not then return here
					If TimerDiff($iTimer) > 1000 Then
						If Not WinExists($hRemoteGUI) Then
							_ArrayDelete($Jobs_aRemoteApps,$iAppIdx)
							$Jobs_aRemoteApps[0][0] -= 1

							Return SetError(1)
						EndIf
						$iTimer = TimerInit()
					EndIf

				; Stop waiting in case we got the answer from the server
					If $Jobs_Local_GetReturn_bIsNew Then ExitLoop

				; If we set time limit then return if it reach
					If $iMaxTime And TimerDiff($iTimer2) >= $iMaxTime Then Return SetError(2)

			WEnd
			$Jobs_Local_GetReturn_bIsNew = False
			$tmp = $Jobs_Local_GetReturn_sData
			$Jobs_Local_GetReturn_sData = Null
			Return $tmp
		EndIf



EndFunc   ;==>Jobs_Remote_CallAction


Func Jobs_SendJobDone($hCallerApp, $iJobID, $sActionReturn = Null)
	#cs
		this function is for telling to the caller that we finish the job/action
		we return to the caller ($hCallerApp) our answer/return ($sActionReturn).
		we also need to tell to the caller to what unique ID our action is linked to
		so the caller will know to what function to call on it's side. that function will
		get the data ($sActionReturn)
	#ce
	If Not $iJobID Then Return

	Local $sCommand = $Jobs_hAppGUI&'[.2.]RET[.1.]'&$iJobID&'[.2.]'&$sActionReturn
	Jobs_SendData($hCallerApp,$sCommand)
EndFunc


Func Jobs_SendData($hRemoteGUI,$Command)
	#cs
		this function is for sending that to the remote app that can be "caller" or "server"
	#ce
	Local $res, $stCOPYDATASTRUCT, $pCommand

	$pCommand = DllStructCreate("char[" & StringLen($Command) + 1 & "]")
	DllStructSetData($pCommand, 1, $Command)

	;COPYDATASTRUCT {ULONG_PTR dwData; DWORD cbData; PVOID lpData;}
	$stCOPYDATASTRUCT = DllStructCreate("ptr;dword;ptr")
	DllStructSetData($stCOPYDATASTRUCT, 1, 0)
	DllStructSetData($stCOPYDATASTRUCT, 2, StringLen($Command) + 1)
	DllStructSetData($stCOPYDATASTRUCT, 3, DllStructGetPtr($pCommand))
	$res = DllCall("user32.dll", "int", "SendMessage", "hwnd", $hRemoteGUI, "int", $WM_COPYDATA, "int", 0, "ptr", DllStructGetPtr($stCOPYDATASTRUCT))
	$pCommand = 0
	$stCOPYDATASTRUCT = 0
EndFunc   ;==>Jobs_Remote_SendData





Func Jobs_GetReturn($sData)
	$Jobs_Local_GetReturn_bIsNew = True
	$Jobs_Local_GetReturn_sData = $sData

EndFunc


Global Enum $Jo_WM_CO_Ad_CaAc_idx_hCallerGUI, $Jo_WM_CO_Ad_CaAc_idx_iActionID, $Jo_WM_CO_Ad_CaAc_idx_sActionData, $Jo_WM_CO_Ad_CaAc_idx_iJobID, $Jo_WM_CO_Ad_CaAc_idxmax
Global $Jo_WM_CO_Ad_CaAc_aData[1][$Jo_WM_CO_Ad_CaAc_idxmax]
Func Jobs_WM_COPYDATA($hWnd, $Msg, $wParam, $lParam)

	; hGUI [.2.] Type [.1.] {.......}

	Local $stCOPYDATASTRUCT = DllStructCreate("ptr;dword;ptr", $lParam)
	Local $iLen = DllStructGetData($stCOPYDATASTRUCT, 2)
	Local $pCommand = DllStructGetData($stCOPYDATASTRUCT, 3)
	Local $sCommand = DllStructCreate("char[" & $iLen & "]", $pCommand)
	$sData = DllStructGetData($sCommand, 1)


	;ConsoleWrite($sData &' (L: '&@ScriptLineNumber&')'&@CRLF)
	; hGUI [.2.] Type [.1.] iActionID [.2.] sActionData [.2.] iJobID

	Local $aSplit1 = StringSplit($sData,'[.1.]',1)
	If $aSplit1[0] <> 2 Then Return SetError(1)
	Local $aSplit2 = StringSplit($aSplit1[1],'[.2.]',1)
	If $aSplit2[0] <> 2 Then Return SetError(1)

	If StringLeft($aSplit2[1],2) <> '0x' Then $aSplit2[1] = '0x'&$aSplit2[1]
	Local $hRemoteGUI = HWnd($aSplit2[1]), $iType = $aSplit2[2]
	;ConsoleWrite($hRemoteGUI &' (L: '&@ScriptLineNumber&')'&@CRLF)


	Switch $iType
		Case 'REQ'
			If Not IsFunc($Jobs_fActionDecider) Then Return

			$aSplit2 = StringSplit($aSplit1[2],'[.2.]',1)
			If $aSplit2[0] <> 3 Then Return SetError(1)
			Local $iActionID = Number($aSplit2[1]), $sActionData = $aSplit2[2], $iJobID = Number($aSplit2[3])

;~ 			$Jobs_fActionDecider($hRemoteGUI,$iActionID,$sActionData,$iJobID)

			$Jo_WM_CO_Ad_CaAc_aData[0][0] += 1
			ReDim $Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]+1][$Jo_WM_CO_Ad_CaAc_idxmax]

			$Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]][$Jo_WM_CO_Ad_CaAc_idx_hCallerGUI] = $hRemoteGUI
			$Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]][$Jo_WM_CO_Ad_CaAc_idx_iActionID] = $iActionID
			$Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]][$Jo_WM_CO_Ad_CaAc_idx_sActionData] = $sActionData
			$Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]][$Jo_WM_CO_Ad_CaAc_idx_iJobID] = $iJobID

			AdlibRegister(Jobs_WM_COPYDATA_Adlib_CallActionDecider,0)

		Case 'RET'

;~ 			$sCommand = $hCallerApp&'[.2.]RET[.1.]'&$iJobID&'[.2.]'&$sActionReturn&
			$aSplit2 = StringSplit($aSplit1[2],'[.2.]',1)


			If $aSplit2[0] <> 2 Then Return SetError(1)
			Local $iJobID = Number($aSplit2[1]), $sReturn = $aSplit2[2]


			Local $iAppIdx = _ArraySearch($Jobs_aRemoteApps,$hRemoteGUI,1,0,0,0,1,$Jobs_aRemoteApps_idx_hAppHwnd)
			If $iAppIdx < 1 Then Return SetError(1)



			$tmp = $Jobs_aRemoteApps[$iAppIdx][$Jobs_aRemoteApps_idx_aAppInfo]
			Local $iJobIdx = _ArraySearch($tmp,$iJobID,1,0,0,0,1,$Jobs_aRemoteAppData_idx_iJobID)
			If $iJobIdx < 1 Then Return SetError(1)

			$tmp[$iJobIdx][$Jobs_aRemoteAppData_idx_fFunc]($sReturn)

			_ArrayDelete($tmp,$iJobIdx)
			$tmp[0][0] -= 1

			If $tmp[0][0] Then
				$Jobs_aRemoteApps[$iAppIdx][$Jobs_aRemoteApps_idx_aAppInfo] = $tmp
			Else
				_ArrayDelete($Jobs_aRemoteApps,$iAppIdx)
				$Jobs_aRemoteApps[0][0] -= 1
			EndIf


		Case Else
			Return SetError(2)
	EndSwitch




	Return 0
EndFunc   ;==>MY_WM_COPYDATA


Func Jobs_WM_COPYDATA_Adlib_CallActionDecider()


	For $a = 1 To $Jo_WM_CO_Ad_CaAc_aData[0][0]
		$Jobs_fActionDecider	($Jo_WM_CO_Ad_CaAc_aData[$a][$Jo_WM_CO_Ad_CaAc_idx_hCallerGUI], _
								$Jo_WM_CO_Ad_CaAc_aData[$a][$Jo_WM_CO_Ad_CaAc_idx_iActionID], _
								$Jo_WM_CO_Ad_CaAc_aData[$a][$Jo_WM_CO_Ad_CaAc_idx_sActionData], _
								$Jo_WM_CO_Ad_CaAc_aData[$a][$Jo_WM_CO_Ad_CaAc_idx_iJobID])
	Next

	$Jo_WM_CO_Ad_CaAc_aData[0][0] = 0
	ReDim $Jo_WM_CO_Ad_CaAc_aData[1][$Jo_WM_CO_Ad_CaAc_idxmax]



;~ 			$Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]][$Jo_WM_CO_Ad_CaAc_hCallerGUI] = $hRemoteGUI
;~ 			$Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]][$Jo_WM_CO_Ad_CaAc_iActionID] = $iActionID
;~ 			$Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]][$Jo_WM_CO_Ad_CaAc_sActionData] = $sActionData
;~ 			$Jo_WM_CO_Ad_CaAc_aData[$Jo_WM_CO_Ad_CaAc_aData[0][0]][$Jo_WM_CO_Ad_CaAc_iJobID] = $iJobID


;~ 	$Jobs_fActionDecider($Jo_WM_CO_Ad_CaAc_hCallerGUI,$Jo_WM_CO_Ad_CaAc_iActionID,$Jo_WM_CO_Ad_CaAc_sActionData,$Jo_WM_CO_Ad_CaAc_iJobID)
;~ 	$Jo_WM_CO_Ad_CaAc_hCallerGUI = Null
;~ 	$Jo_WM_CO_Ad_CaAc_iActionID = Null
;~ 	$Jo_WM_CO_Ad_CaAc_sActionData = Null
;~ 	$Jo_WM_CO_Ad_CaAc_iJobID = Null

	AdlibUnRegister(Jobs_WM_COPYDATA_Adlib_CallActionDecider)

EndFunc