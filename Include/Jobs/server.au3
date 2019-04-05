
#include <GUIConstantsEx.au3>

#include 'Jobs.au3'


HotKeySet('{ESC}',Exit1)
Func Exit1()
	Exit
EndFunc



#Region Actions
	Global Const $C_Actions_Action1 = 1, $C_Actions_Action2 = 2, $C_Actions_Action3 = 3

	Func Actions_Decider($hCallerGUI, $iActionID, $sActionData, $iJobID)

		Switch $iActionID
			Case $C_Actions_Action1
				$tmp = Random(1,100,1)
				MsgBox(0,'server','action 1 - return: '&$tmp)
				ConsoleWrite($iJobID &' (L: '&@ScriptLineNumber&')'&@CRLF)
				Jobs_SendJobDone($hCallerGUI, $iJobID, $tmp)
			Case $C_Actions_Action2
				$tmp = Random(1,100,1)
				MsgBox(0,'server','action 2: '&$tmp&' + '&$sActionData&' = '&$tmp+$sActionData)
				Jobs_SendJobDone($hCallerGUI, $iJobID, $tmp+$sActionData)
			Case $C_Actions_Action3
				$tmp = Random(1,100,1)
				ToolTip('server: action 3 - return: '&$tmp)
				Jobs_SendJobDone($hCallerGUI, $iJobID, $tmp)

		EndSwitch

		; Jobs_SendJobDone($hCallerApp, $iJobID, $sActionReturn)
	EndFunc

#EndRegion




; Register the action decider
	Jobs_Init(Default, Actions_Decider)

	ClipPut($Jobs_hAppGUI)

	While 1
		Sleep(100)
	WEnd


; Create the server GUI
	$tmp = GUICreate('Server',200,100)
	WinSetOnTop($tmp,Null,1)
	GUICtrlCreateInput($Jobs_hAppGUI,0,0)

	GUISetState(@SW_SHOW)

	Do
	Until GUIGetMsg() = $GUI_EVENT_CLOSE




