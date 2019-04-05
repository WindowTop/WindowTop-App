#include-once
#include <String.au3>

Func GetFileNumeFromPath($sPath)
	Local $sFileName = StringSplit($sPath, '\', 1)
	Return $sFileName[$sFileName[0]]
EndFunc   ;==>GetFileNumeFromPath

Func WinGetTransLevel($hWin)
	Local $iTransColor,$iTransLevel
	_WinAPI_GetLayeredWindowAttributes ($hWin, $iTransColor,$iTransLevel)
	If $iTransLevel = -1 Then Return 100
	Return Int(($iTransLevel/255)*100)
EndFunc



Func MouseIsHoveredWnd($hWnd,$tPoint = -1)
	If $tPoint = -1 Then
		$tPoint = _WinAPI_GetMousePos()
	EndIf
	Return _WinAPI_GetAncestor(_WinAPI_WindowFromPoint($tPoint), $GA_ROOT) = $hWnd
EndFunc



func _Process2Win($pid)
    if isstring($pid) then $pid = processexists($pid)
    if $pid = 0 then return -1
    $list = WinList()
    for $i = 1 to $list[0][0]
        if $list[$i][0] <> "" AND BitAnd(WinGetState($list[$i][1]),2) then
            $wpid = WinGetProcess($list[$i][0])
            if $wpid = $pid then return $list[$i][1]
        EndIf
    next
    return -1
endfunc


Func Array2DSearch($aArray, $String, $Dimension, $StartIndex = 1, $EndIndex = 0,$iStep = 1)
	If Not $EndIndex And $iStep = 1 Then $EndIndex = UBound($aArray) - 1
	;If $StartIndex >= 0 And $StartIndex <= $EndIndex Then
		For $a = $StartIndex To $EndIndex Step $iStep
			If $aArray[$a][$Dimension] = $String Then Return $a
		Next
	;EndIf
	Return -1
EndFunc   ;==>Array2DSearch
Func Array2DReplaceIndexs(ByRef $aArray, $iTargetIX,$iFromIX,$iStart = 0,$iEnd = -1)
	If $iEnd = -1 Then $iEnd = UBound($aArray,2)
	Local $tmp_target_copy,$tmp_from_copy
	For $a = $iStart To $iEnd
		$tmp_target_copy = $aArray[$iTargetIX][$a]
		$aArray[$iTargetIX][$a] = $aArray[$iFromIX][$a]
		$aArray[$iFromIX][$a] = $tmp_target_copy
	Next
EndFunc
Func Is1DArrayNew($aNewArray,$aOldArray,$iStartCheck,$iEndCheck)
	For $a = $iStartCheck To $iEndCheck
		If $aNewArray[$a] <> $aOldArray[$a] Then Return 1
	Next
EndFunc


Func DirForseExists(ByRef $sDirPath)
	If Not FileExists($sDirPath) Then DirCreate($sDirPath)
EndFunc   ;==>DirForseExists


Func ProcessGetChilds($iParentPID)
    Local Const $wbemFlagReturnImmediately = 0x10, $wbemFlagForwardOnly = 0x20
    Local Const $sQuery = 'SELECT * FROM Win32_Process Where ParentProcessId = ' & $iParentPID & ' AND Handle <> ' & $iParentPID
    Local $aOut[1] = [0]
	Local $objWMIService = ObjGet('winmgmts:\\localhost\root\CIMV2')
    If IsObj($objWMIService) Then
        Local $colItems = $objWMIService.ExecQuery($sQuery,'WQL',$wbemFlagReturnImmediately+$wbemFlagForwardOnly)
        If IsObj($colItems) then
            For $objItem In $colItems
				$aOut[0] += 1
				ReDim $aOut[$aOut[0]+1]
				$aOut[$aOut[0]] = $objItem.Handle
            Next
        EndIf
    EndIf
    Return $aOut
EndFunc

Func XMLTags_GetList(ByRef $sXmlData, $sTagName)
	Return _StringBetween($sXmlData,'<'&$sTagName&'>','</'&$sTagName&'>')
EndFunc

Func Color_GetInvertedBlackOrWhite($Color,$WhiteColor = 0xffffff)
	Local $r = 255-_ColorGetRed($Color), $g = 255-_ColorGetGreen($Color), $b = 255-_ColorGetBlue($Color)

	Local $average = ($r+$g+$b)/3
	If $average > 127.5 Then
		Return $WhiteColor
	Else
		Return 0x000000
	EndIf
EndFunc

Func ToolTipTimeOut($sText,$iTimeOut = 1500)
	ToolTip($sText)
	AdlibRegister(ToolTipTimeOut_in1,$iTimeOut)
EndFunc

Func ToolTipTimeOut_in1()
	ToolTip(Null)
EndFunc


Func CreateBaseGUI($x_pos,$y_pos,$x_size,$y_size,$iParentGUI = 0,$iBkColor = 0,$bFrame = 1)
	Local $hGUI = GUICreate('',$x_size, $y_size,$x_pos,$y_pos,$WS_POPUP,-1,$iParentGUI)

	If Not $iBkColor Then $iBkColor = 0xF0F4F9;$C_GUMe_WinOptions_def_bkcolor

	GUISetBkColor($iBkColor)
	If $bFrame Then
		GUICtrlCreateGraphic(0,0,0,0,1)

		If $iBkColor Then GUICtrlSetGraphic(-1,$GUI_GR_COLOR,Color_GetInvertedBlackOrWhite($iBkColor,0xa09e9d))

		GUICtrlSetGraphic(-1, $GUI_GR_RECT,0,0,$x_size,$y_size)

	EndIf
	Return $hGUI
EndFunc


Func GetAppliedDPI()
  Local $AppliedDPI = RegRead("HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics", "AppliedDPI")
  If @error Then Return 1
  Return Round(($AppliedDPI*1.041666666666667)/100,2)
EndFunc




Func CountDeclareVar($iStart = Default)
	Local Static $iCount = 0
	If $iStart <> Default Then
		$iCount = $iStart
		Return
	EndIf

	$iCount += 1
	Return $iCount-1
EndFunc


Func IsWindowOnCurrentVirtualDesktop($hWnd)
	If @OSVersion <> 'WIN_10' Then Return True
    $CLSID = "{aa509086-5ca9-4c25-8f95-589d3c07b48a}"
    $IID = "{a5cd92ff-29be-454c-8d04-d82879fb3f1b}"
    $TAG = "IsWindowOnCurrentVirtualDesktop hresult(hwnd;ptr*);"
    $IVirtualDesktopManager = ObjCreateInterface($CLSID, $IID, $TAG)
    $Result = False
    $IVirtualDesktopManager.IsWindowOnCurrentVirtualDesktop($hWnd, $Result)
    $IVirtualDesktopManager = 0
    Return $Result
EndFunc
