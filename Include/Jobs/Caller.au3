#include 'Jobs.au3'




#Region Actions
	Global Const $C_Actions_Action1 = 1, $C_Actions_Action2 = 2, $C_Actions_Action3 = 3
#EndRegion



HotKeySet('{ESC}',Exit1)
Func Exit1()
	Exit
EndFunc

HotKeySet('{1}',Debug1)
Func Debug1()
	_ArrayDisplay($Jobs_aRemoteApps)
EndFunc



Jobs_Init()


Global $hServerGUI = HWnd(0x006D06E2)



Jobs_CallAction($hServerGUI, $C_Actions_Action1,'xyz',Default)
Jobs_CallAction($hServerGUI, $C_Actions_Action1,'xyz2',Default)

Exit









;~ $test = Jobs_CallAction($hServerGUI, $C_Actions_Action1)
;~ ConsoleWrite($test &' (L: '&@ScriptLineNumber&')'&@CRLF)


;~ _ArrayDisplay($Jobs_aRemoteApps)

$test1 = Jobs_CallAction($hServerGUI, $C_Actions_Action1,Null,Null)
ConsoleWrite('Calling action 2' &' (L: '&@ScriptLineNumber&')'&@CRLF)
$test2 = Jobs_CallAction($hServerGUI, $C_Actions_Action2,1)
;~ ConsoleWrite($test1 &' (L: '&@ScriptLineNumber&')'&@CRLF)
ConsoleWrite($test2 &' (L: '&@ScriptLineNumber&')'&@CRLF)

;~ _ArrayDisplay($Jobs_aRemoteApps)
;~ _ArrayDisplay($Jobs_aRemoteApps[1][$Jobs_aRemoteApps_idx_aAppInfo])




While Sleep(100)
WEnd

Func TestGetReturn($sData)
	ConsoleWrite('TestGetReturn: '&$sData &' (L: '&@ScriptLineNumber&')'&@CRLF)

EndFunc



