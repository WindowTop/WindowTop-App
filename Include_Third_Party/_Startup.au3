#include-once

; #AutoIt3Wrapper_Au3Check_Parameters=-d -w 1 -w 2 -w 3 -w- 4 -w 5 -w 6 -w 7
; #INDEX# =======================================================================================================================
; Title .........: _Startup
; AutoIt Version : v3.3.10.0 or higher
; Language ......: English
; Description ...: Create startup entries in the startup folder or registry. The registry entries can be Run all the time (Run registry entry) or only once (RunOnce registry entry.)
; Note ..........:
; Author(s) .....: guinness
; Remarks .......: Special thanks to KaFu for EnumRegKeys2Array() which I used as inspiration for enumerating the Registry Keys.
; ===============================================================================================================================

; #INCLUDES# ====================================================================================================================
#include <StringConstants.au3>

; #GLOBAL VARIABLES# ============================================================================================================
Global Enum $STARTUP_RUN = 0, $STARTUP_RUNONCE, $STARTUP_RUNONCEEX

; #CURRENT# =====================================================================================================================
; _StartupFolder_Exists: Checks if an entry exits in the 'All Users/Current Users' startup folder.
; _StartupFolder_Install: Creates an entry in the 'All Users/Current Users' startup folder.
; _StartupFolder_Uninstall: Deletes an entry in the 'All Users/Current Users' startup folder.
; _StartupRegistry_Exists: Checks if an entry exits in the 'All Users/Current Users' registry.
; _StartupRegistry_Install: Creates an entry in the 'All Users/Current Users' registry.
; _StartupRegistry_Uninstall: Deletes the entry in the 'All Users/Current Users' registry.
; ===============================================================================================================================

; #INTERNAL_USE_ONLY#============================================================================================================
; See below.
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _StartupFolder_Exists
; Description ...: Checks if an entry exits in the 'All Users/Current Users' startup folder.
; Syntax ........: _StartupFolder_Exists([$sName = @ScriptName[, $bAllUsers = False]])
; Parameters ....: $sName               - [optional] Name of the program. Default is @ScriptName.
;                  $bAllUsers           - [optional] Add to Current Users (False) or All Users (True) Default is False.
; Return values .: Success - True
;                  Failure - False
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _StartupFolder_Exists($sName = @ScriptName, $bAllUsers = False)
    Local $sFilePath = Default
    __Startup_Format($sName, $sFilePath)
    Return FileExists(__StartupFolder_Location($bAllUsers) & '\' & $sName & '.lnk')
EndFunc   ;==>_StartupFolder_Exists

; #FUNCTION# ====================================================================================================================
; Name ..........: _StartupFolder_Install
; Description ...: Creates an entry in the 'All Users/Current Users' startup folder.
; Syntax ........: _StartupFolder_Install([$sName = @ScriptName[, $sFilePath = @ScriptFullPath[, $sCommandline = ''[,
;                  $bAllUsers = False]]]])
; Parameters ....: $sName               - [optional] Name of the program. Default is @ScriptName.
;                  $sFilePath           - [optional] Location of the program executable. Default is @ScriptFullPath.
;                  $sCommandline        - [optional] Commandline arguments to be passed to the application. Default is ''.
;                  $bAllUsers           - [optional] Add to Current Users (False) or All Users (True) Default is False.
; Return values .: Success - True
;                  Failure - False & sets @error to non-zero
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _StartupFolder_Install($sName = @ScriptName, $sFilePath = @ScriptFullPath, $sCommandline = '', $bAllUsers = False)
    Return __StartupFolder_Uninstall(True, $sName, $sFilePath, $sCommandline, $bAllUsers)
EndFunc   ;==>_StartupFolder_Install

; #FUNCTION# ====================================================================================================================
; Name ..........: _StartupFolder_Uninstall
; Description ...: Deletes an entry in the 'All Users/Current Users' startup folder.
; Syntax ........: _StartupFolder_Uninstall([$sName = @ScriptName[, $sFilePath = @ScriptFullPath[, $bAllUsers = False]]])
; Parameters ....: $sName               - [optional] Name of the program. Default is @ScriptName.
;                  $sFilePath           - [optional] Location of the program executable. Default is @ScriptFullPath.
;                  $bAllUsers           - [optional] Was it added to Current Users (False) or All Users (True) Default is False.
; Return values .: Success - True
;                  Failure - False & sets @error to non-zero
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _StartupFolder_Uninstall($sName = @ScriptName, $sFilePath = @ScriptFullPath, $bAllUsers = False)
    Return __StartupFolder_Uninstall(False, $sName, $sFilePath, Default, $bAllUsers)
EndFunc   ;==>_StartupFolder_Uninstall

; #FUNCTION# ====================================================================================================================
; Name ..........: _StartupRegistry_Exists
; Description ...:Checks if an entry exits in the 'All Users/Current Users' registry.
; Syntax ........: _StartupRegistry_Exists([$sName = @ScriptName[, $bAllUsers = False[, $iRunOnce = $STARTUP_RUN]]])
; Parameters ....: $sName               - [optional] Name of the program. Default is @ScriptName.
;                  $bAllUsers           - [optional] Add to Current Users (False) or All Users (True) Default is False.
;                  $iRunOnce            - [optional] Always run at system startup $STARTUP_RUN (0), run only once before explorer is started $STARTUP_RUNONCE (1)
;                                         or run only once after explorer is started $STARTUP_RUNONCEEX (2). Default is $STARTUP_RUN (0).
; Return values .: Success - True
;                  Failure - False
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _StartupRegistry_Exists($sName = @ScriptName, $bAllUsers = False, $iRunOnce = $STARTUP_RUN)
    Local $sFilePath = Default
    __Startup_Format($sName, $sFilePath)
    RegRead(__StartupRegistry_Location($bAllUsers, $iRunOnce) & '\', $sName)
    Return @error = 0
EndFunc   ;==>_StartupRegistry_Exists

; #FUNCTION# ====================================================================================================================
; Name ..........: _StartupRegistry_Install
; Description ...: Creates an entry in the 'All Users/Current Users' registry.
; Syntax ........: _StartupRegistry_Install([$sName = @ScriptName[, $sFilePath = @ScriptFullPath[, $sCommandline = ''[,
;                  $bAllUsers = False[, $iRunOnce = $STARTUP_RUN]]]]])
; Parameters ....: $sName               - [optional] Name of the program. Default is @ScriptName.
;                  $sFilePath           - [optional] Location of the program executable. Default is @ScriptFullPath.
;                  $sCommandline        - [optional] Commandline arguments to be passed to the application. Default is ''.
;                  $bAllUsers           - [optional] Add to Current Users (False) or All Users (True) Default is False.
;                  $iRunOnce            - [optional] Always run at system startup $STARTUP_RUN (0), run only once before explorer is started $STARTUP_RUNONCE (1)
;                                         or run only once after explorer is started $STARTUP_RUNONCEEX (2). Default is $STARTUP_RUN (0).
; Return values .: Success - True
;                  Failure - False & sets @error to non-zero
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _StartupRegistry_Install($sName = @ScriptName, $sFilePath = @ScriptFullPath, $sCommandline = '', $bAllUsers = False, $iRunOnce = $STARTUP_RUN)
    Return __StartupRegistry_Uninstall(True, $sName, $sFilePath, $sCommandline, $bAllUsers, $iRunOnce)
EndFunc   ;==>_StartupRegistry_Install

; #FUNCTION# ====================================================================================================================
; Name ..........: _StartupRegistry_Uninstall
; Description ...: Deletes the entry in the 'All Users/Current Users' registry.
; Syntax ........: _StartupRegistry_Uninstall([$sName = @ScriptName[, $sFilePath = @ScriptFullPath[, $bAllUsers = False[,
;                  $iRunOnce = Default]]]])
; Parameters ....: $sName               - [optional] Name of the program. Default is @ScriptName.
;                  $sFilePath           - [optional] Location of the program executable. Default is @ScriptFullPath.
;                  $bAllUsers           - [optional] Was it added to the current users (0) or all users (1). Default is 0.
;                  $iRunOnce            - [optional] Was it run at system startup $STARTUP_RUN (0), run only once before explorer is started $STARTUP_RUNONCE (1)
;                                         or run only once after explorer is started $STARTUP_RUNONCEEX (2). Default is $STARTUP_RUN (0).
; Return values .: Success - True
;                  Failure - False & sets @error to non-zero
; Author ........: guinness
; Example .......: Yes
; ===============================================================================================================================
Func _StartupRegistry_Uninstall($sName = @ScriptName, $sFilePath = @ScriptFullPath, $bAllUsers = False, $iRunOnce = $STARTUP_RUN)
    Return __StartupRegistry_Uninstall(False, $sName, $sFilePath, Default, $bAllUsers, $iRunOnce)
EndFunc   ;==>_StartupRegistry_Uninstall

; #INTERNAL_USE_ONLY#============================================================================================================
Func __Startup_Format(ByRef $sName, ByRef $sFilePath)
    If $sFilePath = Default Then
        $sFilePath = @ScriptFullPath
    EndIf
    If $sName = Default Then
        $sName = @ScriptName
    EndIf
    $sName = StringRegExpReplace($sName, '\.[^.\\/]*$', '') ; Remove extension.
    Return Not (StringStripWS($sName, $STR_STRIPALL) == '') And FileExists($sFilePath)
EndFunc   ;==>__Startup_Format

Func __StartupFolder_Location($bAllUsers)
    Return $bAllUsers ? @StartupCommonDir : @StartupDir
EndFunc   ;==>__StartupFolder_Location

Func __StartupFolder_Uninstall($bIsInstall, $sName, $sFilePath, $sCommandline, $bAllUsers)
    If Not __Startup_Format($sName, $sFilePath) Then
        Return SetError(1, 0, False) ; $STARTUP_ERROR_EXISTS
    EndIf
    If $bAllUsers = Default Then
        $bAllUsers = False
    EndIf
    If $sCommandline = Default Then
        $sCommandline = ''
    EndIf

    Local Const $sStartup = __StartupFolder_Location($bAllUsers)
    Local Const $hSearch = FileFindFirstFile($sStartup & '\' & '*.lnk')
    Local $vReturn = 0
    If $hSearch > -1 Then
        Local Const $iStringLen = StringLen($sName)
        Local $aFileGetShortcut = 0, _
                $sFileName = ''
        While 1
            $sFileName = FileFindNextFile($hSearch)
            If @error Then
                ExitLoop
            EndIf
            If StringLeft($sFileName, $iStringLen) = $sName Then
                $aFileGetShortcut = FileGetShortcut($sStartup & '\' & $sFileName)
                If @error Then
                    ContinueLoop
                EndIf
                If $aFileGetShortcut[0] = $sFilePath Then
                    $vReturn += FileDelete($sStartup & '\' & $sFileName)
                EndIf
            EndIf
        WEnd
        FileClose($hSearch)
    ElseIf Not $bIsInstall Then
        Return SetError(2, 0, False) ; $STARTUP_ERROR_EMPTY
    EndIf

    If $bIsInstall Then
        $vReturn = FileCreateShortcut($sFilePath, $sStartup & '\' & $sName & '.lnk',@ScriptDir, $sCommandline) > 0 ; < MOD ; ,$sStartup, $sCommandline) > 0
    Else
        $vReturn = $vReturn > 0
    EndIf

    Return $vReturn
EndFunc   ;==>__StartupFolder_Uninstall

Func __StartupRegistry_Location($bAllUsers, $iRunOnce)
    If $iRunOnce = Default Then
        $iRunOnce = $STARTUP_RUN
    EndIf
    Local $sRunOnce = ''
    Switch $iRunOnce
        Case $STARTUP_RUNONCE
            $sRunOnce = 'Once'
        Case $STARTUP_RUNONCEEX
            $sRunOnce = 'OnceEx'
        Case Else
            $sRunOnce = ''
    EndSwitch

    Return ($bAllUsers ? 'HKEY_LOCAL_MACHINE' : 'HKEY_CURRENT_USER') & _
            ((@OSArch = 'X64') ? '64' : '') & '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' & $sRunOnce
EndFunc   ;==>__StartupRegistry_Location

Func __StartupRegistry_Uninstall($bIsInstall, $sName, $sFilePath, $sCommandline, $bAllUsers, $iRunOnce)
    If Not __Startup_Format($sName, $sFilePath) Then
        Return SetError(1, 0, False) ; $STARTUP_ERROR_EXISTS
    EndIf
    If $bAllUsers = Default Then
        $bAllUsers = False
    EndIf
    If $sCommandline = Default Then
        $sCommandline = ''
    EndIf

    Local Const $sRegistryKey = __StartupRegistry_Location($bAllUsers, $iRunOnce)
    Local $iInstance = 1, _
            $sRegistryName = '', _
            $vReturn = 0
    While 1
        $sRegistryName = RegEnumVal($sRegistryKey & '\', $iInstance)
        If @error Then
            ExitLoop
        EndIf

        If ($sRegistryName = $sName) And StringInStr(RegRead($sRegistryKey & '\', $sRegistryName), $sFilePath, $STR_NOCASESENSEBASIC) Then
            $vReturn += RegDelete($sRegistryKey & '\', $sName)
        EndIf
        $iInstance += 1
    WEnd

    If $bIsInstall Then
        $vReturn = RegWrite($sRegistryKey & '\', $sName, 'REG_SZ', $sFilePath & ' ' & $sCommandline) > 0
    Else
        $vReturn = $vReturn > 0
    EndIf

    Return $vReturn
EndFunc   ;==>__StartupRegistry_Uninstall