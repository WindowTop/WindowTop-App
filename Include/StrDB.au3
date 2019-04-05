#include-once
#include <Array.au3>


Global $_StrDB_a[1] = [0]


Func StrDB_Load(ByRef $sText)
	$_StrDB_a = StringSplit($sText,@CRLF,1)
EndFunc

Func StrDB_UnLoad()
	Global $_StrDB_a[1] = [0]
EndFunc


#Region StrDB_INI
Func StrDB_ini_GetSectionLine($Section,$Key = Default, $TargetValue = Default)


	Local $Section_Idx = _ArraySearch($_StrDB_a,'['&$Section&']',1,$_StrDB_a[0])
	If $Section_Idx = -1 Then Return SetError(1,0,-1)
	If $Key = Default And $TargetValue = Default Then Return $Section_Idx

	; Scan only in the range of the section
	Local $a = $Section_Idx+1
	If $a > $_StrDB_a[0] Then Return SetError(1,0,-1)
	Local $tmp
	Do
		If StringLeft($_StrDB_a[$a],1) = '[' And StringRight($_StrDB_a[$a],1) = ']' Then
			$Section_Idx = _ArraySearch($_StrDB_a,'['&$Section&']',$a+1,$_StrDB_a[0])
			If $Section_Idx = -1 Then
				Return SetError(1,0,-1)
			Else
				$a = $Section_Idx+1
				If $a > $_StrDB_a[0] Then Return SetError(1,0,-1)
			EndIf
		EndIf

		$tmp = StringSplit($_StrDB_a[$a],'=',1)
		If $tmp[0] >= 2 And StringStripWS($tmp[1],3) = $Key And _
		StringStripWS(StringTrimLeft($_StrDB_a[$a],StringLen($tmp[1])+1),3) = $TargetValue Then Return $Section_Idx

		$a += 1
	Until $a > $_StrDB_a[0]

	Return SetError(1,0,-1)

EndFunc

Func StrDB_Ini_Read($Section,$Key,$Default = Default,$Section_Idx = Default)

	If $Default = Default Then $Default = Null


	If $Section_Idx = Default Then
		$Section_Idx = _ArraySearch($_StrDB_a,'['&$Section&']',1,$_StrDB_a[0])
		If $Section_Idx = -1 Then Return $Default
	EndIf


	; Scan only in the range of the section

	Local $a = $Section_Idx
	If StringLeft($_StrDB_a[$Section_Idx],1) = '[' And StringRight($_StrDB_a[$Section_Idx],1) = ']' Then
		$a += 1
		If $a > $_StrDB_a[0] Then Return $Default
	EndIf

	Local $tmp
	Do
		If StringLeft($_StrDB_a[$a],1) = '[' And StringRight($_StrDB_a[$a],1) = ']' Then Return $Default
		$tmp = StringSplit($_StrDB_a[$a],'=',1)
		If $tmp[0] >= 2 And StringStripWS($tmp[1],3) = $Key Then Return StringStripWS(StringTrimLeft($_StrDB_a[$a],StringLen($tmp[1])+1),3)
		$a += 1
	Until $a > $_StrDB_a[0]
	Return $Default
EndFunc

Func StrDB_Ini_ReadSection($Section_Idx)
	Local $aOut[1][2]
	$aOut[0][0] = 0
	If $Section_Idx = -1 Then Return $aOut
	For $a = $Section_Idx+1 To $_StrDB_a[0]
		If StringLeft($_StrDB_a[$a],1) = '[' And StringRight($_StrDB_a[$a],1) = ']' Then ExitLoop
		$tmp = StringSplit($_StrDB_a[$a],'=',1)
		If $tmp[0] < 1 Then ContinueLoop
		$aOut[0][0] += 1
		ReDim $aOut[$aOut[0][0]+1][2]
		$aOut[$aOut[0][0]][0] = $tmp[1]
		$aOut[$aOut[0][0]][1] = StringTrimLeft($_StrDB_a[$a],StringLen($tmp[1])+1)
	Next
	Return $aOut
EndFunc

Func StrDB_Ini_Write($Section, $Key, $Value, $Section_Idx = Default)
	; Get the section index
	If $Section Then
		If $Section_Idx = Default Then $Section_Idx = _ArraySearch($_StrDB_a,'['&$Section&']',1,$_StrDB_a[0])
	Else
		$Section_Idx = 0
	EndIf

	; Add the value to the string
	If $Section_Idx = -1 Then ; we didn't found the section
		$Section_Idx = StrDB_InternalUse_PrepareForAddLines(2)
		$_StrDB_a[$Section_Idx] = '['&$Section&']'
		$_StrDB_a[$Section_Idx+1] = $Key&'='&$Value
	Else					  ; we found the section

		;look for the key in the section
		Local $Key_idx = -1
		For $a = $Section_Idx+1 To $_StrDB_a[0]
			If StringLeft($_StrDB_a[$a],1) = '[' And StringRight($_StrDB_a[$a],1) = ']' Then ExitLoop
			$tmp = StringSplit($_StrDB_a[$a],'=',1)
			If $tmp[0] < 1 Then ContinueLoop
			If $tmp[1] <> $Key Then ContinueLoop
			$Key_idx = $a
			ExitLoop
		Next

		If $Key_idx = -1 Then
			$Key_idx = $Section_Idx+1




			If $Key_idx > $_StrDB_a[0] Then
				$_StrDB_a[0] += 1
				ReDim $_StrDB_a[$_StrDB_a[0]+1]

			Else
				If $_StrDB_a[$Key_idx] And $_StrDB_a[$Key_idx] <> '0' Then
					;_ArrayDisplay($_StrDB_a,$Key_idx)
					$_StrDB_a[0] += 1
					_ArrayInsert($_StrDB_a,$Key_idx)
					;_ArrayDisplay($_StrDB_a,$Key_idx)
				EndIf
			EndIf
		EndIf
		$_StrDB_a[$Key_idx] = $Key&'='&$Value
	EndIf


	Return $Section_Idx


EndFunc

Func StrDB_Ini_WriteSection($Section)
	$Section_Idx = _ArraySearch($_StrDB_a,'['&$Section&']',1,$_StrDB_a[0])
	If $Section_Idx <> -1 Then Return $Section_Idx
	$Section_Idx = StrDB_InternalUse_PrepareForAddLines(1)
	$_StrDB_a[$Section_Idx] = '['&$Section&']'
	Return $Section_Idx
EndFunc
#EndRegion


#Region StrDB_Array

Func StrDB_Array_GetIndex($sArrayName)
	Return _ArraySearch($_StrDB_a,'[['&$sArrayName&']]',1,$_StrDB_a[0])
EndFunc


Func StrDB_Array_Read($iArray_Idx)
	Local $aOutput[1] = [0]

	If $iArray_Idx = -1 Then Return SetError(1,0,$aOutput)

	For $a = $iArray_Idx+1 To $_StrDB_a[0]
		$_StrDB_a[$a] = StringStripWS($_StrDB_a[$a],3)
		If $_StrDB_a[$a] = '[[]]' Then ExitLoop
		$aOutput[0] += 1
		ReDim $aOutput[$aOutput[0]+1]
		$aOutput[$aOutput[0]] = $_StrDB_a[$a]
	Next

	Return $aOutput
EndFunc

Func StrDB_Array_Delete($iArray_Idx)
	If $iArray_Idx = -1 Then Return SetError(1)
	If $iArray_Idx > $_StrDB_a[0] Then Return SetError(2)

	Local $a = $iArray_Idx, $tmp
	Do
		$tmp = $_StrDB_a[$a]
		_ArrayDelete($_StrDB_a,$a)
		$_StrDB_a[0] -= 1
	Until $a = $_StrDB_a[0]+1 Or $tmp = '[[]]'


EndFunc

Func StrDB_Array_SetEmpty($iArray_Idx)
	If $iArray_Idx = -1 Then Return SetError(1)
	Local $a = $iArray_Idx+1
	If $a > $_StrDB_a[0] Or $_StrDB_a[$a] = '[[]]' Then Return
	Do
		_ArrayDelete($_StrDB_a,$a)
		$_StrDB_a[0] -= 1
	Until $a = $_StrDB_a[0]+1 Or $_StrDB_a[$a] = '[[]]'
EndFunc

Func StrDB_Array_Create($sArrayName)
	Local $iArray_Idx = _ArraySearch($_StrDB_a,'[['&$sArrayName&']]',1,$_StrDB_a[0])
	If $iArray_Idx <> -1 Then
		StrDB_Array_SetEmpty($iArray_Idx)
		Return $iArray_Idx
	EndIf
	$iArray_Idx = StrDB_InternalUse_PrepareForAddLines(2)
	$_StrDB_a[$iArray_Idx] = '[['&$sArrayName&']]'
	$_StrDB_a[$iArray_Idx+1] = '[[]]'
	Return $iArray_Idx
EndFunc

Func StrDB_Array_WriteArray($iArray_Idx, ByRef $aArray, $iStart = 1, $iEnd = Default)
	If $iArray_Idx = -1 Then Return SetError(1)
	StrDB_Array_SetEmpty($iArray_Idx)
	If $iEnd = Default Then $iEnd = UBound($aArray)-1
	Local $iWriteIndex = $iArray_Idx+1
	If $iWriteIndex > $_StrDB_a[0] Then
		For $a = $iStart To $iEnd
			$_StrDB_a[0] += 1
			ReDim $_StrDB_a[$_StrDB_a[0]+1]

			$_StrDB_a[$_StrDB_a[0]] = $aArray[$a]
		Next
	Else
		For $a = $iEnd To $iStart Step -1
			$_StrDB_a[0] += 1
			_ArrayInsert($_StrDB_a,$iWriteIndex,$aArray[$a],0,@CRLF) ; i need to add @CRLF to fix bug in _ArrayInsert
			;ConsoleWrite($aArray[$a] &' (L: '&@ScriptLineNumber&')'&@CRLF)
		Next
	EndIf

EndFunc

Func StrDB_Array_Add($iArray_Idx,$sValue,$iAdd_idx = Default)

	If $iArray_Idx = -1 Then Return SetError(1)

	If $iAdd_idx = Default Then

		For $a = $iArray_Idx+1 To $_StrDB_a[0]
			$_StrDB_a[$a] = StringStripWS($_StrDB_a[$a],3)
			If Not $_StrDB_a[$a] Then ContinueLoop
			If $_StrDB_a[$a] <> '[[]]' Then ContinueLoop
			$iAdd_idx = $a
			_ArrayInsert($_StrDB_a,$a)
			$_StrDB_a[0] += 1
			ExitLoop
		Next
		If $iAdd_idx = Default Then
			$_StrDB_a[0] += 1
			ReDim $_StrDB_a[$_StrDB_a[0]+1]
			$iAdd_idx = $_StrDB_a[0]
		EndIf



	Else
		$iAdd_idx = $iArray_Idx+$iAdd_idx
		_ArrayInsert($_StrDB_a,$iAdd_idx)
		$_StrDB_a[0] += 1
	EndIf

	$_StrDB_a[$iAdd_idx] = $sValue

	Return $iAdd_idx-$iArray_Idx



EndFunc




#EndRegion




#Region InternalUse

Func StrDB_InternalUse_PrepareForAddLines($iNeededLines)

	Local $iEmptyLine = -1
	For $a = $_StrDB_a[0] To 1 Step -1
		$_StrDB_a[$a] = StringStripWS($_StrDB_a[$a],3)
		If $_StrDB_a[$a] Then ExitLoop
		$iEmptyLine = $a
	Next

	If $iEmptyLine = -1 Then
		$iEmptyLine = $_StrDB_a[0]+1
		$_StrDB_a[0] += $iNeededLines
		ReDim $_StrDB_a[$_StrDB_a[0]+1]
	Else
		Local $iEmptyLineCount = $_StrDB_a[0]-$iEmptyLine+1
		If $iEmptyLineCount < $iNeededLines Then
			$_StrDB_a[0] += $iNeededLines-$iEmptyLineCount
			ReDim $_StrDB_a[$_StrDB_a[0]+1]
		EndIf
	EndIf

	Return $iEmptyLine


EndFunc

#EndRegion



Func StrDB_GetFullString($sDelimiter = @CRLF)
	Local $sOut = ''
	For $a = 1 To $_StrDB_a[0]
		$sOut &= $_StrDB_a[$a]
		If $a < $_StrDB_a[0] Then $sOut &= $sDelimiter
	Next
	Return $sOut
EndFunc



