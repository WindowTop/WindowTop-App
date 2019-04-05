
Global $MousePos_aPos[2],$MousePos_aPos_old[2] = [-1,-1],$MousePos_tPoint; $MousePos_IsNew

Func MousePos_Update()

	Local $tmp = _WinAPI_GetMousePos()
	If @error Then
		If $MousePos_tPoint <> -1 Then $MousePos_tPoint = -1
		;ErrorCheck('MousePos_Update -> error')
		Return SetError(1)
	EndIf
	$MousePos_tPoint = $tmp
	$MousePos_aPos[0] = DllStructGetData($MousePos_tPoint, "X")
	$MousePos_aPos[1] = DllStructGetData($MousePos_tPoint, "Y")

;~ 	If $MousePos_aPos[0] <> $MousePos_aPos_old[0] Or $MousePos_aPos[1] <> $MousePos_aPos_old[1] Then
;~ 		$MousePos_IsNew = 1
;~ 	Else
;~ 		$MousePos_IsNew = 0
;~ 	EndIf

EndFunc