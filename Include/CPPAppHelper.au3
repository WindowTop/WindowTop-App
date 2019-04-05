

Func CPPAppHelper_Initialize()
	If ProcessExists($CPPAppHelper_iPid) Then Return

	Run(@ScriptDir&'\C++\rtwl.vcxproj\x64\Release\main.exe '&,@ScriptDir)





EndFunc