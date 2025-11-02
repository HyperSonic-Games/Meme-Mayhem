package Engine

import "core:text/regex/virtual_machine"
import "core:strings"
import "core:fmt"
import "core:sync"
import "vendor:sdl2"

LogLevel :: enum {
    DEBUG,
    INFO,
    WARN,
    ERROR,
    CRITICAL,
}

LOG_MUTEX: ^sync.Mutex

@(init, private="file")
init_logger :: proc() {
    LOG_MUTEX := new(sync.Mutex)
}

@(private="file")
GetColor :: proc(level: LogLevel) -> string {
    color: string
    switch level {
        case .DEBUG:    color = "\x1b[36m"
        case .INFO:     color = "\x1b[32m"
        case .WARN:     color = "\x1b[33m"
        case .ERROR:    color = "\x1b[31m"
        case .CRITICAL: color = "\x1b[41m\x1b[97m"
    }
    return color
}

@(private="file")
GetSDLFlags :: proc(level: LogLevel) -> sdl2.MessageBoxFlags {
    flags: sdl2.MessageBoxFlags
    switch level {
        case .ERROR, .CRITICAL: flags = sdl2.MESSAGEBOX_ERROR
        case .WARN:             flags = sdl2.MESSAGEBOX_WARNING
        case .INFO:             flags = sdl2.MESSAGEBOX_INFORMATION
        case .DEBUG:            flags = sdl2.MESSAGEBOX_INFORMATION
    }
    return flags
}

@(private="file")
Log :: proc(component: string, level: LogLevel, msg: string, args: ..any) {
    // Skip debug logs in release
    when !ODIN_DEBUG {
        if level == .DEBUG {
            return
        }
    }

    sync.lock(LOG_MUTEX)
    defer sync.unlock(LOG_MUTEX)

    // Console output
    color := GetColor(level)
    fmt.printf("%s[%s]: <%s> ~ \x1b[0m", color, component, level)
    fmt.printfln(msg, ..args)

    // SDL2 message boxes only in release builds
    when !ODIN_DEBUG {
        if level >= .WARN {
            text := fmt.tprintf(msg, ..args)
            text_cstring := strings.clone_to_cstring(text, context.temp_allocator)
            title := fmt.tprintf("[%s]: <%s>", component, level)
            title_cstring := strings.clone_to_cstring(title, context.temp_allocator)
            sdl2.ShowSimpleMessageBox(GetSDLFlags(level), title_cstring, text_cstring, nil)
            free_all(context.temp_allocator)
        }
    }

    // Panic on critical always
    if level == .CRITICAL {
        // Dont care about freeing memory as it's only a few bytes and the OS will clean up
        fmt.panicf("[%s]: <CRITICAL> ~ %s", component, fmt.tprintf(msg, ..args))
    }
}

// Convenience wrappers
Debug    :: proc(component: string, msg: string, args: ..any) { Log(component, .DEBUG, msg, ..args) }
Info     :: proc(component: string, msg: string, args: ..any) { Log(component, .INFO, msg, ..args) }
Warn     :: proc(component: string, msg: string, args: ..any) { Log(component, .WARN, msg, ..args) }
Error    :: proc(component: string, msg: string, args: ..any) { Log(component, .ERROR, msg, ..args) }
Critical :: proc(component: string, msg: string, args: ..any) { Log(component, .CRITICAL, msg, ..args) }
