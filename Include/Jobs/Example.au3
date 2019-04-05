#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>


#include 'Jobs.au3'
#AutoIt3Wrapper_UseX64=y


HotKeySet('{ESC}',Exit1)
Func Exit1()
	Exit
EndFunc




;~ ConsoleWrite(WinActivate(HWnd(0x0000000000130846)) &' (L: '&@ScriptLineNumber&')'&@CRLF)

;~ Exit

$hGUI = GUICreate("Test", 239, 241)
WinSetOnTop($hGUI,Null,1)
GUICtrlCreateLabel("Remote hwnd:", 22, 43, 73, 17)
$RemoteHwnd_Input = GUICtrlCreateInput("", 105, 40, 107, 21)
GUICtrlCreateLabel("This hwnd:", 22, 20, 56, 17)
$ThisHwnd_Input = GUICtrlCreateInput($hGUI, 105, 17, 107, 21)
GUICtrlCreateLabel("Remote call:", 18, 87, 63, 17)
$Function1_Button = GUICtrlCreateButton("Function1", 17, 118, 95, 29)
$Function2_Button = GUICtrlCreateButton("Function2", 126, 118, 95, 29)
$Function3_Button = GUICtrlCreateButton("Function3", 19, 158, 95, 29)
$Function4_Button = GUICtrlCreateButton("Function4", 126, 159, 95, 29)
GUISetState(@SW_SHOW)


Jobs_Init($hGUI,ActionDecider)


Global $sRemoteHwnd, $hRemoteHwnd

While 1


	$tmp = GUICtrlRead($RemoteHwnd_Input)
	If $tmp <> $sRemoteHwnd Then
		$sRemoteHwnd = $tmp
		$hRemoteHwnd = HWnd($sRemoteHwnd)
	EndIf


	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit

		Case $Function1_Button
			$tmp = Jobs_CallAction($hRemoteHwnd, 1, 'Data for action 1')
			ConsoleWrite($tmp &' (L: '&@ScriptLineNumber&')'&@CRLF)

		Case $Function2_Button

		Case $Function3_Button

		Case $Function4_Button

	EndSwitch
WEnd




Func ActionDecider($hCallerApp, $iActionID, $sActionData, $iJobID)

	Switch $iActionID

		Case 1
			MsgBox(0,'Action',1)

			Jobs_SendJobDone($hCallerApp, $iJobID, 'abcdefg')

		Case 2
			MsgBox(0,'Action',2)

		Case 3
			MsgBox(0,'Action',3)
	EndSwitch

EndFunc


