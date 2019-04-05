Func CreateXPointsGeometryObject($aXPointIDs,$iXSpace,$iXLineSize,$iXLineMinSpace = 1)


	#cs

	; Geometry instructions for normal pages
		[0][0] = X poses
		[0][1] = Max perpage

	; Geometry instructions for the last page
		[1][0] = X poses
		[1][1] = Max perpage

	; pages with buttons id
	#ce

	Local $aOutput[3][2]
	Local $iMaxPerPage = Int($iXSpace/($iXLineSize+$iXLineMinSpace)) ; how meny per page = 5
	Local $iMaxPags = $aXPointIDs[0]/$iMaxPerPage
	Local $iMaxPags_int = Int($iMaxPags)
	If $iMaxPags >= 1 Then
		$aOutput[0][0] = CreateXPointsGeometryObject_BuildXPoses($iMaxPerPage,$iXLineSize,$iXSpace)
		$aOutput[0][1] = $iMaxPerPage
	EndIf
	If $iMaxPags <> $iMaxPags_int Then
		; במקרה הזה יש צורך ליצור הוראות בנייה לדף נוסף עם נקודות איקס שונות.
		Local $iMax2
		If $iMaxPags < 1 Then
			$iMax2 = $iMaxPags
		Else
			$iMax2 = $iMaxPags-$iMaxPags_int
		EndIf
		$iMax2 *= $iMaxPerPage
		$iMax2 = Round($iMax2)
		$aOutput[1][0] = CreateXPointsGeometryObject_BuildXPoses($iMax2,$iXLineSize,$iXSpace)
		$aOutput[1][1] = $iMax2
	EndIf

	Local $iMaxPags_Ceiling = Ceiling($iMaxPags)
	Local $aIDs[$iMaxPags_Ceiling+1] = [$iMaxPags_Ceiling]
	Local $iIndex = 1, $tmp
	For $a = 1 To $iMaxPags_Ceiling
		$tmp = $aXPointIDs[0]-$iIndex+1
		If $tmp >= $iMaxPerPage Then
			Local $aTemp[$iMaxPerPage+1] = [$iMaxPerPage]
		Else
			Local $aTemp[$tmp+1] = [$tmp]
		EndIf
		For $a2 = 1 To $aTemp[0]
			$aTemp[$a2] = $aXPointIDs[$iIndex]
			$iIndex += 1
		Next
		$aIDs[$a] = $aTemp
	Next
	$aOutput[2][0] = $aIDs
	$aOutput[2][1] = $iMaxPags_Ceiling


	Return $aOutput
EndFunc ; aObject
Func CreateXPointsGeometryObject_BuildXPoses($iItems,$iItemSize,$iSpace)
	Local $aOutput[$iItems+1] = [$iItems]
	Local $iItemSpace = Int(($iSpace/$iItems)-$iItemSize)
	Local $iX = Round($iItemSpace/2)
	For $a = 1 To $iItems
		$aOutput[$a] = $iX
		$iX += $iItemSize+$iItemSpace
	Next
	Return $aOutput
EndFunc
Func CreateXPointsGeometryObject_GetXPointsPosInstructions($aObject,$iPage = 1,$iOutputRows = 2)
	Local $aPages = $aObject[2][0]
	If $iPage > $aPages[0] Then $iPage = $aPages[0]
	Local $aButtonsID = $aPages[$iPage]
	Local $aButtonsPos
	For $a = 0 To 1
		If $aButtonsID[0] = $aObject[$a][1] Then
			$aButtonsPos = $aObject[$a][0]
			ExitLoop
		EndIf
	Next
	If Not IsArray($aButtonsPos) Then Return SetError(@ScriptLineNumber)
	Local $aOutput[$aButtonsID[0]+1][$iOutputRows] = [[$aButtonsID[0]]]
	For $a = 1 To $aOutput[0][0]
		$aOutput[$a][0] = $aButtonsID[$a]
		$aOutput[$a][1] = $aButtonsPos[$a]
	Next
	Return $aOutput
EndFunc