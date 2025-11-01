package main

import "core:fmt"
import "core:sync"


@(private="file")
LOGGER_MUTEX: ^sync.Mutex

@(init, private="file")
InitLoggerMutex :: proc() {
    LOGGER_MUTEX = new(sync.Mutex)
}

@(fini, private="file")
DestroyLoggerMutex :: proc() {
    free(LOGGER_MUTEX)
}

LogLevel :: enum {
    DEBUG,
    INFO,
    WARN,
    ERROR,
    CRITICAL,
}

Log :: proc(level: LogLevel, component: string, fmt_str: string, args: ..any) {
    sync.lock(LOGGER_MUTEX)
    defer { 
        free_all()
        sync.unlock(LOGGER_MUTEX)
    }
    text := fmt.tprintf(fmt_str, args)
    full_text := fmt.tprintf("[%s]: <%s> ~ %s", component, level, text)

    switch level {
        case .DEBUG:
            when ODIN_DEBUG {
                fmt.print(full_text)
            }
        case .INFO:
            fmt.print("\x1b[34m", full_text, "\x1b[0m", sep = "")
        case .WARN:
            fmt.print("\x1b[33m", full_text, "\x1b[0m", sep = "")

        case .ERROR:
            fmt.eprint("\x1b[31m", full_text, "\x1b[0m", sep = "")
        
        case .CRITICAL:
            fmt.eprint("\x1b[31m", full_text, "\x1b[0m", sep = "")
            panic("CRITICAL ERROR LOGGED")
    }
}