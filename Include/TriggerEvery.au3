


Func TriggerEvery_RegisterCallNextFunc()

	If $TriggerEvery_Index >= UBound($TriggerEvery_Funcs) Then
		If Not $TriggerEvery_Index Then Return
		AdlibRegister(TriggerEvery_CallNextFunc,43200000)
		$TriggerEvery_Index = -1
		Return
	Else
		AdlibRegister(TriggerEvery_CallNextFunc,60000)
	EndIf

EndFunc


Func TriggerEvery_CallNextFunc()
	AdlibUnRegister(TriggerEvery_CallNextFunc)

	$TriggerEvery_Index += 1
	If $TriggerEvery_Index >= UBound($TriggerEvery_Funcs) Then
		TriggerEvery_RegisterCallNextFunc()
		Return
	EndIf
	$TriggerEvery_Funcs[$TriggerEvery_Index](True)
EndFunc

Func TriggerEvery_RemoveCurrentFunc()
	_ArrayDelete($TriggerEvery_Funcs,$TriggerEvery_Index)
	$TriggerEvery_Index -= 1
EndFunc


