
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

const char g_rootwin_szClassName[] = "my_window_root_name";

WNDCLASSEX g_rootwin_wc;


bool initialize_rootwin(HINSTANCE *hInstance) {

	//Step 1: Registering the Window Class
	g_rootwin_wc.cbSize = sizeof(WNDCLASSEX);
	g_rootwin_wc.style = 0;
	g_rootwin_wc.lpfnWndProc = WndProc;
	g_rootwin_wc.cbClsExtra = 0;
	g_rootwin_wc.cbWndExtra = 0;
	g_rootwin_wc.hInstance = *hInstance;
	g_rootwin_wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	g_rootwin_wc.hCursor = LoadCursor(NULL, IDC_ARROW);
	g_rootwin_wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	g_rootwin_wc.lpszMenuName = NULL;
	g_rootwin_wc.lpszClassName = g_rootwin_szClassName;
	g_rootwin_wc.hIconSm = LoadIcon(NULL, IDI_APPLICATION);

	if (!RegisterClassEx(&g_rootwin_wc)) { return false; }
	return true;
}