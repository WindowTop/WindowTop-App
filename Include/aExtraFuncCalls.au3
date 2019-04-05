

Func aExtraFuncCalls_AddFunc($Func)
	_ArrayAdd($aExtraFuncCalls,$Func)
	$aExtraFuncCalls[0] += 1
EndFunc


Func aExtraFuncCalls_RemoveFunc($Func)
	For $a = 1 To $aExtraFuncCalls[0]
		If $aExtraFuncCalls[$a] <> $Func Then ContinueLoop
		_ArrayDelete($aExtraFuncCalls,$a)
		$aExtraFuncCalls[0] -= 1
		ExitLoop
	Next
EndFunc


Func aExtraFuncCalls_CallFuncs()
	If Not $aExtraFuncCalls[0] Then Return
	Local $a = 1
	Do
		If Not $aExtraFuncCalls[$a]() Then
			$a += 1
		Else
			_ArrayDelete($aExtraFuncCalls,$a)
			$aExtraFuncCalls[0] -= 1
		EndIf
	Until $a > $aExtraFuncCalls[0]

EndFunc