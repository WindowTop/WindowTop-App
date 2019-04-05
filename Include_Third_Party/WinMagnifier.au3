#include-once
; =================================================================================================================
; <WinMagnifier.au3>
;
; Built-In Windows Magnification API (since Windows Vista)
;
; NOTE: TRY to run this at the same bit-mode your O/S is running in, as the GUI can be funky at times
; when run in an incompatible bit mode.  So for 64-bit O/S's, run this as x64 only!
;
; To-DO:
;  - ALL 'Get' Functions..? (Implemented Color FX ones..)
;  - 'MagSetInputTransform'? - Adjusts Touch and Pen Input transformation
;
; Misc Notes:
;  - Win7 GetMagnificationDesktopMagnification is equivalent of Win8 MagGetFullscreenTransform
;
;  - DWM Messages (@ http://msdn.microsoft.com/en-us/library/windows/desktop/ff729170%28v=vs.85%29.aspx)
;    are worth capturing when using Magnifier.
;    For Example, WM_DWMCOMPOSITIONCHANGED (0x031E) is sent when DWM is disabled/enabled
;    (with the exception of Win8 where DWM is always-on).
;    'MagnifierScreenInverter' demo has code for this.
;
; Unknown Functions:
;  Win7 (user32.dll): GetMagnificationLensCtxInformation, SetMagnificationLensCtxInformation
;
; UDF Functions:
;
;  Startup/Shutdown:
;    _MagnifierInit()
;    _MagnifierUnInit()
;
;  Full-Screen Magnifier/Effects:
;    _MagnifierFullScreenGetColorEffect()
;    _MagnifierFullScreenSetColorEffect()
;    _MagnifierFullScreenClearColorEffects()
;    _MagnifierFullScreenSetScale()
;
;  Magnifier GUI & Control Creation:
;    _MagnifierGUICreate()
;    _GuiCtrlCreateMagnify()
;
;  Magnifier Control:
;    _MagnifierIsInvertColorsStyle()
;    _MagnifierSetInvertColorsStyle()
;    _MagnifierShowSystemCursor()
;    _MagnifierSetWindowFilter()
;    _MagnifierSetSource()
;    _MagnifierSetScale()
;    _MagnifierGetColorEffect()
;    _MagnifierSetColorEffect()
;    _MagnifierClearColorEffects()
;
;  Misc. Functions:
;    _MagnifierColorEffectIsEqual()          ; Compares 2 Color Matrices for Equality, returns True/False
;
; Color FX Matrix Constants:
;    $COLOR_EFFECTS_IDENTITY_MATRIX    ; Default Color Scheme Matrix (can use to clear any Color FX)
;    $COLOR_EFFECTS_INVERSION_MATRIX   ; Inverted Color Scheme
;    $COLOR_EFFECTS_SEPIA_TONE_MATRIX  ; Sepia Tone
;    $COLOR_EFFECTS_GRAYSCALE_MATRIX   ; Grayscale (no Color Saturation)
;    $COLOR_EFFECTS_BW_MATRIX          ; Black & White
;
; Global State Variables:
;    $g_nWinMagnifyAPILevel   ; Set by _MagnifierInit(), API Level: 0 = pre-Vista, 1 = Vista, 7 = Win7, 8 = Win8+
;
;
; MSDN Links:
; - Magnification API: http://msdn.microsoft.com/en-us/library/windows/desktop/ms692162%28v=vs.85%29.aspx
; - Magnify Function Reference: http://msdn.microsoft.com/en-us/library/windows/desktop/ms692386%28v=vs.85%29.aspx
;
; See also:
;  <MagnifierExperiments.au3>    ; Example usage of this UDF
;  <MagnifierScreenInverter.au3> ; Simple Screen Color-Inversion Tray tool demo
;
; Author: Ascend4nt
; =================================================================================================================
;~ #AutoIt3Wrapper_UseX64=Y	; Use when necessary (in source file)
#include <WinAPI.au3>  ; GetProcAddress, Misc Window Create/Info functions


#Region COLOR_MATRIX_CONSTANTS
; ColorEffects from "ColorMatrix Guide - Rainmeter Tips & Tricks"
; @ http://docs.rainmeter.net/tips/colormatrix-guide

; Identity Matrix (normal effects)
Global Const $COLOR_EFFECTS_IDENTITY_MATRIX[5][5] = [ _
		[1.0,   0,   0,   0,   0], _
		[  0, 1.0,   0,   0,   0], _
		[  0,   0, 1.0,   0,   0], _
		[  0,   0,   0, 1.0,   0], _
		[  0,   0,   0,   0, 1.0] ]
; Inverted Colors
Global Const $COLOR_EFFECTS_INVERSION_MATRIX[5][5] = [ _
		[-1.0,   0,    0,   0,   0], _
		[  0, -1.0,    0,   0,   0], _
		[  0,    0, -1.0,   0,   0], _
		[  0,    0,    0, 1.0,   0], _
		[1.0,  1.0,  1.0,   0, 1.0] ]
; Sepia Tone
Global Const $COLOR_EFFECTS_SEPIA_TONE_MATRIX[5][5] = [ _
		[0.393, 0.349, 0.272,   0,   0], _
		[0.769, 0.686, 0.534,   0,   0], _
		[0.189, 0.168, 0.131,   0,   0], _
		[    0,     0,     0, 1.0,   0], _
		[    0,     0,     0,   0, 1.0] ]
; Grayscale
Global Const $COLOR_EFFECTS_GRAYSCALE_MATRIX[5][5] = [ _
		[0.33, 0.33, 0.33,   0,   0], _
		[0.59, 0.59, 0.59,   0,   0], _
		[0.11, 0.11, 0.11,   0,   0], _
		[   0,    0,    0, 1.0,   0], _
		[   0,    0,    0,   0, 1.0] ]
; Black & White Colors
Global Const $COLOR_EFFECTS_BW_MATRIX[5][5] = [ _
		[ 1.5,  1.5,  1.5,   0,   0], _
		[ 1.5,  1.5,  1.5,   0,   0], _
		[ 1.5,  1.5,  1.5,   0,   0], _
		[   0,    0,    0, 1.0,   0], _
		[-1.0, -1.0, -1.0,   0, 1.0] ]
#EndRegion COLOR_MATRIX_CONSTANTS


#Region GLOBAL_MAGNIFICAITON_VARS
Global $g_hMagnificationDLL = -1
; Magnifier Effects API Level detection (these generally reflect the O/S present too, but don't be too certain):
;  0 = pre-Vista, 1 = Vista, 7 = Win 7, 8 = Win8+ API's
Global $g_nWinMagnifyAPILevel = 0

; Full-screen Magnify FX feature detect (old method)
;~ Global $g_bWin8MagnifyAPIPresent = False, $g_bWin7MagnifyAPIPresent = False
#EndRegion GLOBAL_MAGNIFICAITON_VARS


#Region MAGNIFIER_STARTUP_SHUTDOWN
; =============================================================================
; Func _MagnifierInit()
;
; Author: Ascend4nt
; =============================================================================
Func _MagnifierInit()
	If $g_hMagnificationDLL <> -1 Then Return 1

	$g_hMagnificationDLL = DllOpen("Magnification.dll")
	If $g_hMagnificationDLL = -1 Then Return SetError(-1, 0, 0)

	Local $aRet = DllCall($g_hMagnificationDLL, "bool", "MagInitialize")
	If @error Or Not $aRet[0] Then
		Local $iErr = @error
		DllCall($g_hMagnificationDLL, "bool", "MagUninitialize")
		DllClose($g_hMagnificationDLL)
		$g_hMagnificationDLL = -1
		Return SetError(-1, $iErr, 0)
	EndIf

	; Check on Windows 7+ and 8+ Magnifier Full-screen API functions support
	If _WinAPI_GetProcAddress(_WinAPI_GetModuleHandle("Magnification.dll"), "MagSetFullscreenColorEffect") = 0 Then
		; Windows 8 API not present
		;$g_bWin8MagnifyAPIPresent = False
		If _WinAPI_GetProcAddress(_WinAPI_GetModuleHandle("user32.dll"), "SetMagnificationDesktopColorEffect") = 0 Then
			; Window 7 API not present (Vista-level O/S)
			;$g_bWin7MagnifyAPIPresent = False
			$g_nWinMagnifyAPILevel = 1
			;ConsoleWrite("Boo, simple Vista Magnify API Present!" & @LF)
		Else
			;$g_bWin7MagnifyAPIPresent = True
			$g_nWinMagnifyAPILevel = 7
			;ConsoleWrite("Windows 7 Magnify API Present!" & @LF)
		EndIf
	Else
		;ConsoleWrite("Windows 8 Magnify API Present!" & @LF)
		;$g_bWin7MagnifyAPIPresent = False
		;$g_bWin8MagnifyAPIPresent = True
		$g_nWinMagnifyAPILevel = 8
	EndIf

	;OnAutoItExitRegister("_MagnifierUnInit")
	Return 1
EndFunc


; =============================================================================
; Func _MagnifierUnInit()
;
; Author: Ascend4nt
; =============================================================================
Func _MagnifierUnInit()
	If $g_hMagnificationDLL = -1 Then Return SetError(1, 0, 0)

	Local $aRet = DllCall($g_hMagnificationDLL, "bool", "MagUninitialize")
	If @error Then Return SetError(2, @error, 0)

	DllClose($g_hMagnificationDLL)
	$g_hMagnificationDLL = -1

	OnAutoItExitUnRegister("_MagnifierUnInit")
	Return $aRet[0]
EndFunc

#EndRegion MAGNIFIER_STARTUP_SHUTDOWN


#Region MAGNIFIER_FULL_SCREEN_FX
; =============================================================================
; Func _MagnifierFullScreenGetColorEffect()
;
; Gets the current FullScreen Color Effect Matrix and returns it as a 5x5 Matrix array
;
; Return:
;  Success: $aColorFX[5][5] - Matrix corresponding to FullScreen ColorEffect Matrix
;  Failure: 0, @error set
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierFullScreenGetColorEffect()
	; Not initialized? Or not supported? (req's Win7+)
	If $g_hMagnificationDLL = -1 Or $g_nWinMagnifyAPILevel <= 1 Then Return SetError(1, 0, 0)
	Local $aRet, $stMagColorEffect = DllStructCreate("float [5];float [5];float [5];float [5];float [5];")

	; Win 7 API?
	If $g_nWinMagnifyAPILevel = 7 Then
		$aRet = DllCall("user32.dll", "bool", "GetMagnificationDesktopColorEffect", "ptr", DllStructGetPtr($stMagColorEffect))
	Else	; $g_nWinMagnifyAPILevel >= 8
		$aRet = DllCall($g_hMagnificationDLL, "bool", "MagGetFullscreenColorEffect", "ptr", DllStructGetPtr($stMagColorEffect))
	EndIf
	If @error Then Return SetError(2, @error, 0)
	If Not $aRet[0] Then Return SetError(3, 0, 0)

	; Return the Matrix as an array
	Dim $aRet[5][5]
	; Columns (top to bottom)
	For $i = 1 To 5
		; Rows (left-to-right)
		For $n = 1 to 5
			$aRet[$i-1][$n-1] = DllStructGetData($stMagColorEffect, $i, $n)
		Next
	Next
	Return $aRet
EndFunc

; =============================================================================
; Func _MagnifierFullScreenSetColorEffect(Const $aColorFX)
;
; Sets the FullScreen Color Effect base on the passed 5x5 Color Effect Matrix
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierFullScreenSetColorEffect(Const $aColorFX)
	; Not initialized? Or not supported? (req's Win7+)? Or array not valid?
	If $g_hMagnificationDLL = -1 Or $g_nWinMagnifyAPILevel <= 1 Or Not IsArray($aColorFX) Or UBound($aColorFX, 0) < 2 Then Return SetError(1, 0, 0)
;~ 	If UBound($aColorFX, 1) < 5 Or UBound($aColorFX, 2) < 5 Then Return SetError(1, 0, 0)

	Local $aRet, $stMagColorEffect = DllStructCreate("float [5];float [5];float [5];float [5];float [5];")

	; Columns (top to bottom)
	For $i = 1 To 5
		; Rows (left-to-right)
		For $n = 1 to 5
			DllStructSetData($stMagColorEffect, $i, $aColorFX[$i-1][$n-1], $n)
		Next
	Next

	; Win 7 API?
	If $g_nWinMagnifyAPILevel = 7 Then
		$aRet = DllCall("user32.dll", "bool", "SetMagnificationDesktopColorEffect", "ptr", DllStructGetPtr($stMagColorEffect))
	Else	; $g_nWinMagnifyAPILevel >= 8
		$aRet = DllCall($g_hMagnificationDLL, "bool", "MagSetFullscreenColorEffect", "ptr", DllStructGetPtr($stMagColorEffect))
	EndIf
	If @error Then Return SetError(2, @error, 0)

	Return $aRet[0]
EndFunc

; =============================================================================
; Func _MagnifierFullScreenClearColorEffects($bUseIdentityMatrix = True)
;
; Clears all Color Effects for Full-screen 'Magnification' Effects
;
; NOTE: Using FALSE for $bUseIdentityMatrix will NOT clear the Inverse effect made
;       upon Magnifier Control Creation (MS_INVERTCOLORS).. not sure how this applies to full sreen
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierFullScreenClearColorEffects($bUseIdentityMatrix = True)
	#forceref $bUseIdentityMatrix
#cs
	; The Easily Identifiable Identiy Matrix!:
	Local $aColorFX[5][5] = [ _
		[1, 0, 0, 0, 0], _
		[0, 1, 0, 0, 0], _
		[0, 0, 1, 0, 0], _
		[0, 0, 0, 1, 0], _
		[0, 0, 0, 0, 1] ]


	; Shorter version (rest of elements are empty/0 on initialization)
	For $i = 0 To 4
		$aColorFX[$i][$i] = 1.0
	Next
#ce
	Local $bRet = _MagnifierFullScreenSetColorEffect($COLOR_EFFECTS_IDENTITY_MATRIX)
	Return SetError(@error, @extended, $bRet)
EndFunc


; =============================================================================
; Func _MagnifierFullScreenSetScale($fMagFactor, $iXOffset = 0, $iYOffset = 0)
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierFullScreenSetScale($fMagFactor, $iXOffset = 0, $iYOffset = 0)
	; Not initialized? Or not supported? (req's Win7+)
	If $g_hMagnificationDLL = -1 Or $g_nWinMagnifyAPILevel <= 1 Then Return SetError(1, 0, 0)

	Local $aRet

;~ 	ConsoleWrite("_MagnifierFullScreenSetScale() with MagFactor of " & $fMagFactor & ", X-Offset: " & $iXOffset & ", Y-Offset: " & $iYOffset & @LF)

	; Win 7 API?
	If $g_nWinMagnifyAPILevel = 7 Then
		; NOTE: 1st parameter is DOUBLE on Win7 whereas the equivalent function on Win8 requires float
		$aRet = DllCall("user32.dll", "bool", "SetMagnificationDesktopMagnification", "double", $fMagFactor, "int", $iXOffset, "int", $iYOffset)
	Else	; $g_nWinMagnifyAPILevel >= 8
		$aRet = DllCall($g_hMagnificationDLL, "bool", "MagSetFullscreenTransform", "float", $fMagFactor, "int", $iXOffset, "int", $iYOffset)
	EndIf
	If @error Then Return SetError(2, @error, 0)

	Return $aRet[0]
EndFunc


#EndRegion MAGNIFIER_FULL_SCREEN_FX


#Region MAGNIFIER_GUI_AND_CONTROLS
; =============================================================================
; Func _MagnifierGUICreate($nWidth, $nHeight, $iX1, $iY1, $bInvertColors = False,
;                          $bShowCursor = False)
;
; Author: Ascend4nt
; =============================================================================
Func _MagnifierGUICreate($nWidth, $nHeight, $iX1, $iY1, $bInvertColors = False, $bShowCursor = False)

	If Not _MagnifierInit() Then Return SetError(@error, 0, 0)

	Local $hMagnifyGUI, $hMagnifyCtrl
	; -------------------------
	; - 2-step creation of Magnify GUI and Control: -

; MSDN Recommended Style:
	; Styles: Basic: WS_CLIPCHILDREN (0x02000000),
	;  Extended: WS_EX_TOPMOST (0x08) | WS_EX_LAYERED (0x080000) | WS_EX_TRANSPARENT (0x20) [click-through]
	;$hMagnifyGUI = GUICreate("", $nWidth, $nHeight, $iX1, $iY1, 0x02000000, BitOR(0x080000, 0x20, 0x08))

; Popup Borderless Window Style:
	;	Styles: Regular: WS_POPUP (0x80000000)
	;	   Extended: WS_EX_NOACTIVATE 0x08000000 $WS_EX_TOOLWINDOW (0x80) + $WS_EX_TOPMOST (0x08) + WS_EX_TRANSPARENT (0x20 [click-through])
	$hMagnifyGUI = GUICreate("", $nWidth, $nHeight, $iX1, $iY1, 0x80000000, BitOR(0x08000000, 0x080000, 0x80, 0x20))	; 0x08 [can set TopMost elsewhere]
	If @error Or $hMagnifyGUI = 0 Then Return SetError(1111, 0, 0)

	; Set Window to FULL Opacity (per MSDN recommendation).  LWA_ALPHA (0x02)
	_WinAPI_SetLayeredWindowAttributes($hMagnifyGUI, 0, 255, 0x02, 0)

	$hMagnifyCtrl = _GuiCtrlCreateMagnify($hMagnifyGUI, $nWidth, $nHeight, 0, 0, $bInvertColors, $bShowCursor)
	If @error Then Return SetError(@error, 0, 0)

	Local $aGUIPlusCtrl[2] = [$hMagnifyGUI, $hMagnifyCtrl]
	Return $aGUIPlusCtrl
EndFunc

; =============================================================================
; Func _GuiCtrlCreateMagnify($hWndParent, $nWidth, $nHeight, $iX1 = 0, $iY1 = 0,
;                            $bInvertColors = False, $bShowCursor = False)
;
; Author: Ascend4nt
; =============================================================================
Func _GuiCtrlCreateMagnify($hWndParent, $nWidth, $nHeight, $iX1 = 0, $iY1 = 0, $bInvertColors = False, $bShowCursor = False)
	If $g_hMagnificationDLL = -1 Then Return SetError(1, 0, 0)

; IMPORTANT! This class will NOT be Registered UNLESS the program has initialized the Magnification API ("MagInitialize")
;	Also, it shows up as a Classname as "MilMagnifierHwnd" when viewed by AutoIt Window Info
	Local Const $WC_MAGNIFIER = "Magnifier"

	Local $sClassName, $sWindowName, $nStyle

	If $g_hMagnificationDLL = -1 Or Not IsHWnd($hWndParent) Then Return SetError(1, 0, 0)

	;$stRect = _WinAPI_GetClientRect($hWndParent)
	;Local $aPos[4] = [DllStructGetData($stRect, 1), DllStructGetData($stRect, 2), DllStructGetData($stRect, 3), DllStructGetData($stRect, 4)]

	$sClassName = $WC_MAGNIFIER
	$sWindowName = "MagnifierWindow"

	; MS_SHOWMAGNIFIEDCURSOR (0x01), MS_CLIPAROUNDCURSOR (0x02), MS_INVERTCOLORS (0x04)  [
	; WS_CHILD (0x40000000) | MS_SHOWMAGNIFIEDCURSOR (0x01) | WS_VISIBLE (0x10000000)
	$nStyle = BitOR(0x40000000, 0x10000000)
	If $bShowCursor Then $nStyle += 0x01
	If $bInvertColors Then $nStyle += 0x04

	; Note: WILL Fail if "MagInitialize" was not called prior to this!!!:
	Local $hWnd = _WinAPI_CreateWindowEx(0, $sClassName, $sWindowName, $nStyle, $iX1, $iY1, $nWidth, $nHeight, $hWndParent)
	If $hWnd = 0 Then Return SetError(3,0,0)
	Return $hWnd
EndFunc


; =============================================================================
; Func _MagnifierIsInvertColorsStyle($hMagnifyCtrl)
;
; Simple function to check if the Magnify Control was created with the MS_INVERTCOLORS flag
; which produces inverted colors.
;
; Unfortunately, if a SetColorEffect has been called with any matrix, this flag will still be
; set in the Control (regardless of Colors state).
;
; A workaround would be to keep track of what Color Effects are done and clear the flag,
; or just create a Magnify Control without the MS_INVERTCOLORS flag and attempt to reproduce
; Inverted Colors using a SetColorEffect call (not sure how or if that's possible..?)
;
; Returns:
;  Success: True or False depending on if MS_INVERTCOLORS is set
;  Failure: 0 with @error set
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierIsInvertColorsStyle($hMagnifyCtrl)
	; GWL_STYLE = -16
	Local $nStyle = _WinAPI_GetWindowLong($hMagnifyCtrl, -16)
	If @error Then Return SetError(@error, 0, 0)

	; MS_INVERTCOLORS (0x04)
	Return (BitAND($nStyle, 0x04) = 0x04)
EndFunc


; =============================================================================
; Func _MagnifierSetInvertColorsStyle($hMagnifyCtrl, $bSetInvert = True)
;
; $bSetInvert = If True (default), Sets the Invert Color Style. If False, clears it
;
; Returns:
;  Success: non-zero, @error = 0
;  Failure: 0 with @error set
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierSetInvertColorsStyle($hMagnifyCtrl, $bSetInvert = True)
	; GWL_STYLE = -16
	Local $nRet, $nStyle = _WinAPI_GetWindowLong($hMagnifyCtrl, -16)
	If @error Then Return SetError(@error, 0, 0)

	; Set or Clear Invert Style [MS_INVERTCOLORS (0x04)]
	If $bSetInvert Then
		; Set already? Return success
		If BitAND($nStyle, 0x04) Then Return 1
		; Otherwise add it
		$nStyle = BitOR($nStyle, 0x04)
	Else
		; Clear? If so, return success
		If BitAND($nStyle, 0x04) = 0 Then Return 1
		; Otherwise, must change it
		$nStyle -= 0x04
	EndIf

	$nRet = _WinAPI_SetWindowLong($hMagnifyCtrl, -16, $nStyle)

	; Redraw/Refresh the Control!
	_WinAPI_InvalidateRect($hMagnifyCtrl, 0, True)
	Return $nRet
EndFunc

#EndRegion MAGNIFIER_GUI_AND_CONTROLS


; =============================================================================
; Func _MagnifierShowSystemCursor($bShowCursor = True)
;
; Windows 8+ ONLY!
; Shows or Hides System Cursor (see MSDN)
;
; Author: Ascend4nt
; =============================================================================
Func _MagnifierShowSystemCursor($bShowCursor = True)
	; Not initialized? Or not supported? (req's Win8+)
	If $g_hMagnificationDLL = -1 Or $g_nWinMagnifyAPILevel < 8 Then Return SetError(-1, 0, 0)
	Local $aRet = DllCall($g_hMagnificationDLL, "bool", "MagShowSystemCursor", "bool", $bShowCursor)
	If @error Then Return SetError(2, @error, 0)
	Return $aRet[0]
EndFunc


; =============================================================================
; Func _MagnifierSetWindowFilter($hMagnifyCtrl, $vWinList, $bIncludeList = False)
;
; Sets an Exclusion filter (or Inclusion on CERTAIN O/S's - see $bIncludeList below) for
; the Magnification Control. What this means is the Window(s) listed will be more or less 'invisible'
; to the Magnification control - only what's above and beneath the Window will show
;
; MSDN Note: "This function requires Windows Display Driver Model (WDDM)-capable video cards."
;
; $vWinList = Either a Window, or an Array of Windows to exclude (or Include on Vista - see $bIncludeList)
; $bIncludeList = False.  If True, MW_FILTERMODE_INCLUDE will be used on the API call. HOWEVER:
;						  MW_FILTERMODE_INCLUDE is NOT supported on Windows 7 or 8,
;                         so apparently this is Vista and Server-only?
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierSetWindowFilter($hMagnifyCtrl, $vWinList, $bIncludeList = False)
	If Not IsHWnd($hMagnifyCtrl) Or $g_hMagnificationDLL = -1 Then Return SetError(1, 0, 0)

	Local $aRet, $nCount, $nFilterMode, $stWindows

	If Not IsArray($vWinList) Then
		If Not IsHWnd($vWinList) Then Return SetError(1, 0, 0)
		$nCount = 1

		Local $vTmp = $vWinList
		Dim $vWinList[1] = [$vTmp]
	Else
		$nCount = UBound($vWinList)
	EndIf

	$stWindows = DllStructCreate("hwnd [" & $nCount & "];")
	For $i = 1 To $nCount
		DllStructSetData($stWindows, $i, $vWinList[$i - 1])
	Next

	; MW_FILTERMODE_EXCLUDE = 0, MW_FILTERMODE_INCLUDE = 1	[latter doesn't work on Win 7 & Win 8 (Vista & Server only?)]
	$nFilterMode = $bIncludeList ? 1 : 0

	$aRet = DllCall($g_hMagnificationDLL, "bool", "MagSetWindowFilterList", "hwnd", $hMagnifyCtrl, "dword", $nFilterMode, _
					"int", $nCount, "ptr", DllStructGetPtr($stWindows))

	If @error Then Return SetError(2, 0, 0)
	Return $aRet[0]
EndFunc


; =============================================================================
; Func _MagnifierSetSource($hMagnifyGUI, $iX1, $iY1, $iX2, $iY2)
;
; Sets the source (in screen coordinates) for the Magnifier Control
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierSetSource($hMagnifyCtrl, $iX1, $iY1, $iX2, $iY2)
	If $g_hMagnificationDLL = -1 Then Return SetError(1, 0, 0)

	Local Static $aRet, $stRect = DllStructCreate("long[4];")
	DllStructSetData($stRect, 1, $iX1, 1)
	DllStructSetData($stRect, 1, $iY1, 2)
	DllStructSetData($stRect, 1, $iX2, 3)	; X2
	DllStructSetData($stRect, 1, $iY2, 4)	; Y2

; Well here's a head scratcher - on x64, passing a RECT struct, or alternatively 2 "int64" parameters (splitting the Rect in two) causes a crash
; However - passing a POINTER to a RECT struct works. Of course, this in turn crashes when in x86 mode. So we have the below split call
; Note that this isn't documented ANYWHERE
	If @AutoItX64 Then
		$aRet = DllCall($g_hMagnificationDLL, "bool", "MagSetWindowSource", "hwnd", $hMagnifyCtrl, "ptr", DllStructGetPtr($stRect))
	Else
		$aRet = DllCall($g_hMagnificationDLL, "bool", "MagSetWindowSource", "hwnd", $hMagnifyCtrl, "struct", $stRect)
	EndIf

	If @error Then Return SetError(2, @error, 0)

	;ConsoleWrite("MagSetWindowSource return : " & $aRet[0] & " LastError:" & _WinAPI_GetLastErrorMessage() & @LF)

	; Redraw/Refresh the Control!
	;_WinAPI_InvalidateRect($hMagnifyCtrl, 0, True)
	;ToolTip(1)
	Return $aRet[0]
EndFunc


; =============================================================================
; Func _MagnifierSetScale($hMagnifyCtrl, $fMagFactor)
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierSetScale($hMagnifyCtrl, $fMagFactor)
	If $g_hMagnificationDLL = -1 Then Return SetError(1, 0, 0)
	Local $aRet, $stMagTransform = DllStructCreate("float [3];float [3];float [3];")

	; Magnification Matrix
	; x 0 0
	; 0 x 0
	; 0 0 1
	DllStructSetData($stMagTransform, 1, $fMagFactor, 1)
	DllStructSetData($stMagTransform, 2, $fMagFactor, 2)
	DllStructSetData($stMagTransform, 3, 1.0, 3)

	$aRet = DllCall($g_hMagnificationDLL, "bool", "MagSetWindowTransform", "hwnd", $hMagnifyCtrl, "ptr", DllStructGetPtr($stMagTransform))
	If @error Then Return SetError(2, @error, 0)

	; Redraw/Refresh the Control!
	_WinAPI_InvalidateRect($hMagnifyCtrl, 0, True)
	Return $aRet[0]
EndFunc

#Region MAGNIFY_COLOR_FX
; =============================================================================
; Func _MagnifierGetColorEffect($hMagnifyCtrl)
;
; Gets the current Color Effect Matrix and returns it as a 5x5 Matrix array
;
; Return:
;  Success: $aColorFX[5][5] - Matrix corresponding to ColorEffect Matrix
;  Failure: 0, @error set
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierGetColorEffect($hMagnifyCtrl)
	If $g_hMagnificationDLL = -1 Then Return SetError(1, 0, 0)
	Local $aRet, $stMagColorEffect = DllStructCreate("float [5];float [5];float [5];float [5];float [5];")
	$aRet = DllCall($g_hMagnificationDLL, "bool", "MagGetColorEffect", "hwnd", $hMagnifyCtrl, "ptr", DllStructGetPtr($stMagColorEffect))
	If @error Then Return SetError(2, @error, 0)
	If Not $aRet[0] Then Return SetError(3, 0, 0)

	; Return the Matrix as an array
	Dim $aRet[5][5]
	; Columns (top to bottom)
	For $i = 1 To 5
		; Rows (left-to-right)
		For $n = 1 to 5
			$aRet[$i-1][$n-1] = DllStructGetData($stMagColorEffect, $i, $n)
		Next
	Next
	Return $aRet
EndFunc

; =============================================================================
; Func _MagnifierSetColorEffect($hMagnifyCtrl, Const $aColorFX)
;
; Sets the Color Effect base on the passed 5x5 Color Effect Matrix
;
; Author: Ascend4nt
; =============================================================================
Func _MagnifierSetColorEffect($hMagnifyCtrl, Const $aColorFX)
	If $g_hMagnificationDLL = -1 Or Not IsArray($aColorFX) Or UBound($aColorFX, 0) < 2 Then Return SetError(1, 0, 0)
;~ 	If UBound($aColorFX, 1) < 5 Or UBound($aColorFX, 2) < 5 Then Return SetError(1, 0, 0)

	Local $aRet, $stMagColorEffect = DllStructCreate("float [5];float [5];float [5];float [5];float [5];")
	; Columns (top to bottom)
	For $i = 1 To 5
		; Rows (left-to-right)
		For $n = 1 to 5
			DllStructSetData($stMagColorEffect, $i, $aColorFX[$i-1][$n-1], $n)
		Next
	Next
	$aRet = DllCall($g_hMagnificationDLL, "bool", "MagSetColorEffect", "hwnd", $hMagnifyCtrl, "ptr", DllStructGetPtr($stMagColorEffect))
	If @error Then Return SetError(2, @error, 0)

	; Redraw/Refresh the Control!
	_WinAPI_InvalidateRect($hMagnifyCtrl, 0, True)

	Return $aRet[0]
EndFunc

; =============================================================================
; Func _MagnifierClearColorEffects($hMagnifyCtrl, $bUseIdentityMatrix = True)
;
; Clears all Color Effects for Magnifier Control
;
; NOTE: Using FALSE for $bUseIdentityMatrix will NOT clear the Inverse effect made
;       upon Magnifier Control Creation (MS_INVERTCOLORS)
;
; Author: Ascend4nt
; =============================================================================

Func _MagnifierClearColorEffects($hMagnifyCtrl, $bUseIdentityMatrix = True)
;~ 	If $g_hMagnificationDLL = -1 Then Return SetError(1, 0, 0)
#forceref $bUseIdentityMatrix

#cs
	Local $bRet, $aColorFX[5][5]

	; The Easily Identifiable Identiy Matrix!:
	Local $aColorFX[5][5] = [ _
		[1, 0, 0, 0, 0], _
		[0, 1, 0, 0, 0], _
		[0, 0, 1, 0, 0], _
		[0, 0, 0, 1, 0], _
		[0, 0, 0, 0, 1] ]

	; Shorter version (rest of elements are empty/0 on initialization)
	For $i = 0 To 4
		$aColorFX[$i][$i] = 1.0
	Next
#ce
	; If Not $bUseIdentityMatrix Then ; MagSetColorEffect($hMagnifyCtrl, NULL)

	Local $bRet = _MagnifierSetColorEffect($hMagnifyCtrl, $COLOR_EFFECTS_IDENTITY_MATRIX)
	Return SetError(@error, @extended, $bRet)
EndFunc

; =============================================================================
; Func _MagnifierColorEffectIsEqual(Const $aColorFX1, Const $aColorFX2)
;
; Compares 2 Color Effect Matrices to see if they are equal
; *Uses a maxRelativeDistance of .004. Seems to work well enough?
;  Could use Epsilon values or a more complex method..
;
; Author: Ascend4nt
; =============================================================================
Func _MagnifierColorEffectIsEqual(Const $aColorFX1, Const $aColorFX2)
	If Not IsArray($aColorFX1) Or Not IsArray($aColorFX2) Or UBound($aColorFX1, 0) <> 2 Or UBound($aColorFX1) <> UBound($aColorFX2) Then Return SetError(1, 0, 0)

	For $i = 0 To UBound($aColorFX1) - 1
		For $j = 0 To UBound($aColorFX1, 2) - 1
			If Abs($aColorFX2[$i][$j] - $aColorFX1[$i][$j]) > .004 Then Return False
		Next
	Next
	Return True
EndFunc
#EndRegion MAGNIFY_COLOR_FX