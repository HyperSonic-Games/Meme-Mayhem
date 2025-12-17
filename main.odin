package main

import "Magma/2D/Renderer"
import "Magma/2D/EventSys"
import "Magma/2D/Physics"
import "Magma/2D/Audio"
import "Magma/Types"
import "Magma/Util"

main :: proc() {
    ctx := Renderer.Init("MEME_MAYHEM", "Meme Mayhem", 800, 500, .OPEN_GL, ODIN_DEBUG)
    keyboard := new(EventSys.Keyboard)
    mouse :=  new(EventSys.Mouse)
    win_state := new(EventSys.WindowState)
    running := true

    for running {
        EventSys.HandleEvents(mouse, keyboard, win_state)
        Renderer.FPSLimiter(120)
        Renderer.Update(&ctx)

        if win_state.should_quit {
            running = false
        }

        EventSys.ResetWindowFlags(win_state)
    }

    Renderer.Shutdown(ctx)

}