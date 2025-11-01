package main

import "core:fmt"
import "core:time"
import "core:sync"

@(private="file")
LOGGER_MUTEX: sync.Mutex

@(init, private="file")
InitLoggerMutex :: proc() {
    
}