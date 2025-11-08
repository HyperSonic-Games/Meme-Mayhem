#+build windows
package Engine

import "core:sys/windows"


// NVIDIA + AMD: request discrete GPU on laptops
@(export, rodata)
NvOptimusEnablement: u32 = 1

@(export, rodata)
AmdPowerXpressRequestHighPerformance: u32 = 1

// Initialize Windows-specific behavior for raylib games
@init
FixWindowsGameEnvironment :: proc() {
    // UTF-8 + ANSI color support (for console debug output)
    windows.SetConsoleOutputCP(.UTF8)
    windows.SetConsoleCP(.UTF8)

    handle := windows.GetStdHandle(windows.STD_OUTPUT_HANDLE)
    mode: u32
    mode |= windows.ENABLE_VIRTUAL_TERMINAL_PROCESSING
    windows.SetConsoleMode(handle, mode)

    // Enable per-monitor DPI awareness (important for fullscreen & scaling)
    windows.SetProcessDpiAwarenessContext(
        windows.DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2,
    )

    // Improve timer resolution for smoother frame pacing
    windows.timeBeginPeriod(1)

    // Set the current main thread to have a high proirity
    curr_thread := windows.GetCurrentThread()
    windows.SetThreadPriority(curr_thread, windows.THREAD_PRIORITY_ABOVE_NORMAL)
}

// Optional: restore defaults on shutdown
FixWindowsCleanup :: proc() {
    windows.timeEndPeriod(1)

}
