#include-once
#include <GDIPlus.au3>
#include "..\Include_Third_Party\resources2.au3"




Func GUIImageButton_Create($hGUI_hGraphics,$Image,$x_pos,$y_pos,$x_size = Default,$y_size = Default)
	Local $aOutput[3],$hImage,$hData = -1

	If StringInStr($Image,'\') > 0 Then
		$hImage = _GDIPlus_BitmapCreateFromFile($Image)
		If @error Then Return SetError(1,0,$aOutput)
	Else
		Local $tmp = ResourceGetAsBitmap2($Image)
		;$hImage = _ResourceGetAsBitmap($Image,10,$__g_hGDIPDll)
		If @error Then Return SetError(2,0,$aOutput)
		$hImage = $tmp[0]
		$hData = $tmp[1]
	EndIf

	If $x_size = Default Or $y_size = Default Then
		$x_size = _GDIPlus_ImageGetWidth($hImage)
		$y_size = _GDIPlus_ImageGetHeight($hImage)
	EndIf
	$aOutput[0] = GUICtrlCreateLabel('',$x_pos,$y_pos,$x_size,$y_size)
	GUICtrlSetCursor(-1,0)
	_GDIPlus_GraphicsDrawImage($hGUI_hGraphics, $hImage,$x_pos,$y_pos)
	_GDIPlus_BitmapDispose($hImage)
	If $hData <> -1 Then _MemGlobalFree($hData)
	Local $aPos[4] = [$x_pos,$y_pos,$x_size,$y_size]
	$aOutput[1] = $aPos


	Return $aOutput
EndFunc


Func GUIImageButton_SetSquareFrame($hGUI,$hGUI_hGraphics, ByRef $aButton, $iLineWidth = 1, $LineColor_rgba = 0xFF000000)
	If Not IsArray($aButton) Then Return SetError(@ScriptLineNumber)
	Local $aPos = $aButton[1]
	If Not IsArray($aPos) Then Return SetError(@ScriptLineNumber)
	If $aButton[2] And $iLineWidth < $aButton[2] Then GUIImageButton_RemoveSquareFrame($hGUI,$aButton)
	Local $iFixPos = Int($iLineWidth/2), $iFixPos2 = $iFixPos*2
	GDIPCreateSquareFrame($hGUI_hGraphics,$aPos[0]-$iFixPos,$aPos[1]-$iFixPos,$aPos[2]+$iFixPos2,$aPos[3]+$iFixPos2,$iLineWidth,$LineColor_rgba)
	$aButton[2] = $iLineWidth
EndFunc



Func GUIImageButton_SetNewImage($hGUI_hGraphics,$aButton,$Image)
	Local $hImage,$hData = -1

	If StringInStr($Image,'\') > 0 Then
		$hImage = _GDIPlus_BitmapCreateFromFile($Image)
		If @error Then Return SetError(1)
	Else
		Local $tmp = ResourceGetAsBitmap2($Image)
		;$hImage = _ResourceGetAsBitmap($Image,10,$__g_hGDIPDll)
		If @error Then Return SetError(2)
		$hImage = $tmp[0]
		$hData = $tmp[1]
	EndIf

	Local $aPos = $aButton[1]

	If Mod($aButton[2],2) Then
		$aPos[0] += 1
		$aPos[1] += 1
		$aPos[2] -= 1
		$aPos[3] -= 1
	EndIf

	_GDIPlus_GraphicsDrawImageRect ($hGUI_hGraphics,$hImage,$aPos[0],$aPos[1],$aPos[2],$aPos[3])
	;_GDIPlus_GraphicsDrawImage($hGUI_hGraphics, $hImage,$aPos[0],$aPos[1])
	_GDIPlus_BitmapDispose($hImage)
	If $hData <> -1 Then _MemGlobalFree($hData)
EndFunc


Func GUIImageButton_RemoveSquareFrame($hGUI, ByRef $aButton)
	If Not $aButton[2] Then Return
	Local $aPos = $aButton[1]
	If Not IsArray($aPos) Then Return SetError(1)
	If Not Mod($aButton[2] ,2) Then
		GDIPRemoveArea($hGUI,$aPos[0]-$aButton[2],$aPos[1]-$aButton[2],$aPos[2]+($aButton[2]*2),$aButton[2])
	Else
		GDIPRemoveArea($hGUI,$aPos[0]-$aButton[2],$aPos[1]-$aButton[2]+1,$aPos[2]+($aButton[2]*2),$aButton[2])
	EndIf
	GDIPRemoveArea($hGUI,$aPos[0]+$aPos[2],$aPos[1],$aButton[2],$aPos[3]+$aButton[2])
	GDIPRemoveArea($hGUI,$aPos[0]-$aButton[2],$aPos[1]+$aPos[3],$aPos[2]+$aButton[2],$aButton[2])
	If Not Mod($aButton[2] ,2) Then
		GDIPRemoveArea($hGUI,$aPos[0]-$aButton[2],$aPos[1],$aButton[2],$aPos[3])
	Else
		GDIPRemoveArea($hGUI,$aPos[0]-$aButton[2],$aPos[1],$aButton[2]+1,$aPos[3])
	EndIf
	$aButton[2] = 0
EndFunc


Func GUIImageButton_Delete($hGUI, ByRef $aButton)
	GUIImageButton_CleanGraphics($hGUI,$aButton,1)
	$test = GUICtrlDelete($aButton[0])
	;ConsoleWrite($test & @CRLF)
	$aButton = 0
EndFunc


Func GUIImageButton_CleanGraphics($hGUI, ByRef $aButton,$CleanFrame = 1)
    Local $aPos = $aButton[1]
	If Not IsArray($aPos) Then Return SetError(1)
	If Mod($aButton[2],2) Then
		$aPos[0] += 1
		$aPos[1] += 1
		$aPos[2] -= 1
		$aPos[3] -= 1
	EndIf
	If $CleanFrame And $aButton[2] Then
		$aPos[0] -= $aButton[2]
		$aPos[1] -= $aButton[2]
		$aButton[2] *= 2
		$aPos[2] += $aButton[2]
		$aPos[3] += $aButton[2]
		$aButton[2] = 0
	EndIf
	GDIPRemoveArea($hGUI,$aPos[0],$aPos[1],$aPos[2],$aPos[3])
EndFunc



; internal use only
Func ResourceGetAsBitmap2($ResName,$DLL = -1)
	Local $Output[2],$ResData, $nSize, $pData, $pStream, $pBitmap
	$ResData = _ResourceGet($ResName, 10, 0, $DLL)
	If @error Then Return SetError(1, 0, 0)
	$nSize = @extended
	$Output[1] = _MemGlobalAlloc($nSize,2)
	$pData = _MemGlobalLock($Output[1])
	_MemMoveMemory($ResData,$pData,$nSize)
	_MemGlobalUnlock($Output[1])
	$pStream = DllCall( "ole32.dll","int","CreateStreamOnHGlobal", "ptr",$Output[1], "int",1, "ptr*",0)
	$pStream = $pStream[3]
	$pBitmap = DllCall($__g_hGDIPDll,"int","GdipCreateBitmapFromStream", "ptr",$pStream, "ptr*",0)
	$Output[0] = $pBitmap[2]
	;$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($pBitmap)
	If @error Then SetError(3, 0, 0)
;~ 	_GDIPlus_BitmapDispose($pBitmap)
	_WinAPI_DeleteObject($pStream)
	Return $Output

EndFunc

; internal use only
Func GDIPRemoveArea($hGUI,$x_pos,$y_pos,$x_size,$y_size)
	Local $tRect = DllStructCreate($tagRECT)
    DllStructSetData($tRect, 'Left', $x_pos)
    DllStructSetData($tRect, 'Top', $y_pos)
    DllStructSetData($tRect, 'Right', $x_pos+$x_size)
    DllStructSetData($tRect, 'Bottom', $y_pos+$y_size)
	If Not _WinAPI_InvalidateRect($hGUI, $tRect, True) Then _
	Return SetError(1)
EndFunc



; internal use only
Func GDIPCreateSquareFrame($hGraphic,$x_pos,$y_pos,$x_size,$y_size,$iLineWidth = 1,$hex_rgba_color = 0xFF000000)
	Local $hPen = _GDIPlus_PenCreate($hex_rgba_color, $iLineWidth)
    _GDIPlus_GraphicsDrawRect($hGraphic, $x_pos,$y_pos,$x_size,$y_size,$hPen)
	_GDIPlus_PenDispose($hPen)
EndFunc