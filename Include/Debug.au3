

Func aWins_Show()
	;Return
	Local Static $hGUI,$sText,$Edit,$tmp1
	Local Const $x_size = 708,$y_size = 170
	If Not $hGUI Then
		$hGUI = GUICreate("Form1", $x_size, $y_size, @DesktopWidth-$x_size-20, @DesktopHeight-$y_size-50)
		$Edit = GUICtrlCreateEdit("", 8, 8, 689, 153)
		GUICtrlSetData(-1, "Edit1")
		WinSetOnTop($hGUI,'',1)
		WinSetTrans($hGUI,'',Int(0.8*255))
		GUISetState(@SW_SHOW)

	EndIf

	$tmp1 = _ArrayToString($aWins, " | ",-1,-1, @CRLF,-1,-1)
	If $tmp1 = $sText Then Return
	$sText = $tmp1
	GUICtrlSetData($Edit,$sText)
EndFunc

Func aWins_Show_old($ShoTitle = 0)
	If Not $ShoTitle Then
		ToolTip(_ArrayToString($aWins, " | ",-1,-1, @CRLF,-1,-1))
	Else
		Local $aTmp = $aWins
		For $a = 1 To $aTmp[0][0]
			$aTmp[$a][0] = StringStripWS(WinGetTitle($aTmp[$a][0]),4)
		Next
		;ToolTip(_ArrayToString($aTmp, " | ",-1,-1, @CRLF,-1,-1))
		_ArrayDisplay($aTmp)
	EndIf
EndFunc



;~ HotKeySet('{F1}',Test11)
Func Test11()
	_ArrayDisplay($aWins)
EndFunc



Func ErrorCheck($sText, $iLine = @ScriptLineNumber)
	Local $sDebugFile = @DesktopDir&'\WindowTop_debug.txt'
	Local Static $bFileCreateed = False
	If Not $bFileCreateed Then
		If FileExists($sDebugFile) Then FileDelete($sDebugFile)
		$bFileCreateed = True
	EndIf
	$tmp = $sText&' , line '&$iLine
	FileWriteLine($sDebugFile,$tmp)
	ConsoleWrite($tmp&@CRLF)
EndFunc


