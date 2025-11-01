package Engine

import "base:runtime"
import "vendor:raylib"
import "core:bufio"
import "core:log"

@(private)
ENGINE_LOGGER: log.Logger

@(init)
InitLogger :: proc() {
    ENGINE_LOGGER = log.create_console_logger(.Debug, {.Level, .Date, .Time, .Short_File_Path, .Line, .Procedure})
}

@fini
DestroyLogger :: proc() {
    log.destroy_console_logger(ENGINE_LOGGER)
}

@(export)
Log :: proc(level: log.Level, args: ..any, sep := " ", location := #caller_location) {
    context.logger = ENGINE_LOGGER
    log.log(level, args, sep, location)
}

Logf :: proc(level: log.Level, fmt_str: string, args: ..any, location := #caller_location) {
    context.logger = ENGINE_LOGGER
    log.logf(level, fmt_str, args, location)
}
