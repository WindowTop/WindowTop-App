#include <ScreenCapture.au3>
#include-once

; #FUNCTION# ;===============================================================================
;
; Name...........: _PixelGetColor_CreateDC
; Description ...: Creates a DC for use with the other _PixelGetColor functions.
; Syntax.........: _PixelGetColor_CreateDC()
; Parameters ....: None.
; Return values .: Success - Returns the handle to a compatible DC.
;                  Failure - Returns 0 and Sets @error according to @error from the DllCall.
; Author ........: Jos van Egmond
; Modified.......:
; Remarks .......:
; Related .......: _PixelGetColor_CaptureRegion, _PixelGetcolor_GetPixel, _PixelGetColor_GetPixelRaw, _PixelGetColor_ReleaseRegion, _PixelGet_Color_ReleaseDC
; Example .......; No
;
; ;==========================================================================================
Func _PixelGetColor_CreateDC($hDll = "gdi32.dll")
	$iPixelGetColor_MemoryContext = DllCall($hDll, "int", "CreateCompatibleDC", "int", 0)
	If @error Then Return SetError(@error,0,0)
	Return $iPixelGetColor_MemoryContext[0]
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _PixelGetColor_CaptureRegion
; Description ...: Captures the user defined region and reads it to a memory DC.
; Syntax.........: _PixelGetColor_CaptureRegion($iPixelGetColor_MemoryContext, $iLeft = 0, $iTop = 0, $iRight = -1, $iBottom = -1, $fCursor = False)
; Parameters ....: $iPixelGetColor_MemoryContext	- The DC as returned by _PixelGetColor_CreateDC
;					$iLeft		- Left side of the screen for use with the region
;					$iTop		- Top side of the screen for use with the region
;					$iRight		- Right side of the screen for use with the region
;					$iBottom	- Bottom side of the screen for use with the region
;					$iCursor 	- If this is true, then the cursor is also read into memory
; Return values .: Success - Returns the handle to a region.
;                  Failure -
; Author ........: Jos van Egmond
; Modified.......:
; Remarks .......:
; Related .......: _PixelGet_Color_CreateDC, _PixelGetcolor_GetPixel, _PixelGetColor_GetPixelRaw, _PixelGetColor_ReleaseRegion, _PixelGet_Color_ReleaseDC
; Example .......; No
;
; ;==========================================================================================
Func _PixelGetColor_CaptureRegion($iPixelGetColor_MemoryContext, $iLeft = 0, $iTop = 0, $iRight = -1, $iBottom = -1, $fCursor = False, $hDll = "gdi32.dll")
	$HBITMAP = _ScreenCapture_Capture("", $iLeft, $iTop, $iRight, $iBottom, $fCursor)
	DllCall($hDll, "hwnd", "SelectObject", "int", $iPixelGetColor_MemoryContext, "hwnd", $HBITMAP)
	Return $HBITMAP
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _PixelGetColor_GetPixel
; Description ...: Gets a pixel color from the DC in decimal BGR and converts it to RGB in 6 digit hexadecimal.
; Syntax.........: _PixelGetColor_GetPixel($iPixelGetColor_MemoryContext,$iX,$iY)
; Parameters ....: $iPixelGetColor_MemoryContext	- The DC as returned by _PixelGetColor_CreateDC
;					$iX		- The X coordinate in the captured region
;					$iY		- The Y coordinate in the captured regoin
; Return values .: Success - Returns the 6 digit hex BGR color.
;                  Failure - Returns -1 and Sets @error to 1.
; Author ........: Jos van Egmond
; Modified.......: gil900 - for return as number (not hex code)
; Remarks .......:
; Related .......: _PixelGetColor_CreateDC, _PixelGetColor_CaptureRegion, _PixelGetColor_GetPixelRaw, _PixelGetColor_ReleaseRegion, _PixelGet_Color_ReleaseDC
; Example .......; Yes
;
; ;==========================================================================================
Func _PixelGetColor_GetPixel($iPixelGetColor_MemoryContext,$iX,$iY, $hDll = "gdi32.dll")
	$iColor = DllCall($hDll,"int","GetPixel","int",$iPixelGetColor_MemoryContext,"int",$iX,"int",$iY)
	If $iColor[0] = -1 then Return SetError(1,0,-1)
	Return $iColor[0]
	;$sColor = Hex($iColor[0],6)
	;Return StringRight($sColor,2) & StringMid($sColor,3,2) & StringLeft($sColor,2)
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _PixelGetColor_GetPixelRaw
; Description ...: Gets a pixel color from the DC in decimal BGR.
; Syntax.........: _PixelGetColor_GetPixelRaw($iPixelGetColor_MemoryContext,$iX,$iY)
; Parameters ....: $iPixelGetColor_MemoryContext	- The DC as returned by _PixelGetColor_CreateDC
;					$iX		- The X coordinate in the captured region
;					$iY		- The Y coordinate in the captured regoin
; Return values .: Success - Returns the color in decimal BGR.
;                  Failure - Returns -1 and Sets @error to 1.
; Author ........: Jos van Egmond
; Modified.......:
; Remarks .......:
; Related .......: _PixelGetColor_CreateDC, _PixelGetColor_CaptureRegion, _PixelGetColor_GetPixel, _PixelGetColor_ReleaseRegion, _PixelGet_Color_ReleaseDC
; Example .......; No
;
; ;==========================================================================================
Func _PixelGetColor_GetPixelRaw($iPixelGetColor_MemoryContext,$iX,$iY, $hDll = "gdi32.dll")
	$iColor = DllCall($hDll,"int","GetPixel","int",$iPixelGetColor_MemoryContext,"int",$iX,"int",$iY)
	Return $iColor[0]
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _PixelGetColor_ReleaseRegion
; Description ...: Releases a region previously created by calling _PixelGetColor_CaptureRegion
; Syntax.........: _PixelGetColor_ReleaseRegion($HBITMAP)
; Parameters ....: $HBITMAP - Previously returned by _PixelGetColor_CaptureRegion
; Return values .: None.
; Author ........: Jos van Egmond
; Modified.......:
; Remarks .......:
; Related .......: _PixelGetColor_CreateDC, _PixelGetColor_CaptureRegion, _PixelGetcolor_GetPixel, _PixelGetColor_GetPixelRaw, _PixelGet_Color_ReleaseDC
; Example .......; No
;
; ;==========================================================================================
Func _PixelGetColor_ReleaseRegion($HBITMAP)
	_WinAPI_DeleteObject($HBITMAP)
EndFunc

; #FUNCTION# ;===============================================================================
;
; Name...........: _PixelGetColor_ReleaseDC
; Description ...: Releases a region previously created by calling _PixelGetColor_CreateDC
; Syntax.........: _PixelGetColor_ReleaseDC($iPixelGetColor_MemoryContext)
; Parameters ....: $iPixelGetColor_MemoryContext - Previously returned by _PixelGetColor_CreateDC
; Return values .: None.
; Author ........: Jos van Egmond
; Modified.......:
; Remarks .......:
; Related .......: _PixelGetColor_CreateDC, _PixelGetColor_CaptureRegion, _PixelGetcolor_GetPixel, _PixelGetColor_GetPixelRaw, _PixelGetColor_ReleaseRegion
; Example .......; No
;
; ;==========================================================================================
Func _PixelGetColor_ReleaseDC($iPixelGetColor_MemoryContext, $hDll = "gdi32.dll")
	DllCall($hDll, "int", "DeleteDC", "hwnd", $iPixelGetColor_MemoryContext)
EndFunc