// includes.functions
#include <windows.h>

// includes.functions.for_debuging
#include "InitConsole.h"

// includes.functions.declarations
#include "functions.declarations.h"

// includes.global_vars.declarations
#include "global_vars.declarations.h"

// includes.initialize.root_win
#include "initialize.root_win.h" // Open this heeder and modify it if you need

// includes.codes.macros
#include "codes.macros.h"




// namespaces.normal


// namespaces.for_debuging (**for debugging)
using namespace std; // for using cin & cout 




int MainCode{

	if (!initialize_rootwin(&hInstance)) return 0; // Initiialize root window for creating win32 guis later

	InitConsole(); // Initiialize console (**for debugging)



				   // Create window example
	HWND hMainWin = CreateWindowEx(WS_EX_CLIENTEDGE,g_rootwin_szClassName,"The title of my window",WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, CW_USEDEFAULT, 240, 120,NULL, NULL, hInstance, NULL);
	if (!hMainWin) { cout << "Error: Window Creation Failed!"; return 0; }
	ShowWindow(hMainWin, nCmdShow);




	MSG Msg;

	// Example.Massage_loop_2: Loop run always while listening to messages
	while (1)
	{
		if (PeekMessage(&Msg, NULL, 0, 0, PM_REMOVE))
		{
			cout << Msg.message << endl;
			switch (Msg.message)
			{
			case WM_QUIT:
				return 0;
			default:
				break;
			}
		}
		TranslateMessage(&Msg); DispatchMessage(&Msg);
	}

	return Msg.wParam;
}




// Step 4: the Window Procedure
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
	case WM_CLOSE:
		DestroyWindow(hwnd);
		break;
	case WM_DESTROY:
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hwnd, msg, wParam, lParam);
	}
	return 0;
}