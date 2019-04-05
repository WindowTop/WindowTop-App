#pragma once
#include <stdio.h>
#include <iostream>

FILE *g_ic_file_cout_stream; FILE *g_ic_file_cin_stream;

// Success: true , Failure: false
bool InitConsole()
{
	if (!AllocConsole()) { return false; }
	if (freopen_s(&g_ic_file_cout_stream, "CONOUT$", "w", stdout) != 0) { return false; } // For std::cout 
	if (freopen_s(&g_ic_file_cin_stream, "CONIN$", "w+", stdin) != 0) { return false; } // For std::cin
	return true;
}

