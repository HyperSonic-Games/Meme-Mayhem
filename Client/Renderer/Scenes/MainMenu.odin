package Scenes

import "../../../Magma/2D/EventSys"
import "../../../Magma/2D/Renderer"
import "../../../Magma/2D/UI"
import "../../../Magma/Util"
import "../../../Magma/Types"

MainMenuResult :: enum {
    CONNECT,
    CREDITS,
    QUIT,
}


MainMenu :: proc(ui_ctx: ^UI.UIContext, renderer_ctx: ^Renderer.RenderContext, keyboard: ^EventSys.Keyboard, mouse: ^EventSys.Mouse, window_state: ^EventSys.WindowState, fonts: ^Util.FontStorage) -> MainMenuResult {

    text, w, h := Renderer.RenderTextToTexture(
                renderer_ctx,
                "TEST",
                fonts->Get("OPEN_SANS_BOLD", .BOLD, 30),
                {255, 255, 255, 255},
                200,
                false
            )
    if text == nil {
        Util.Log(.ERROR, "MEME_MAYHEM_CLIENT", "MAIN_MENU", "Could not load font")
        return .QUIT
    }
    for window_state.should_quit == false {
        EventSys.ResetWindowFlags(window_state)

        dt := Renderer.GetDeltaTime()
        Renderer.FPSLimiter(60)
    
        EventSys.HandleEvents(mouse, keyboard, window_state)

        Renderer.ClearScreen(renderer_ctx, {0, 0, 0, 255})

        pressed := UI.TextButton(
            ui_ctx,
            text,
            {0,0},
            {200, 200},
            {90,90,90,255},
            {95,95,95,255}
        )

        if pressed {
            return .QUIT
        }

        Renderer.Update(renderer_ctx)

        Renderer.PresentScreen(renderer_ctx)

    }

    return .QUIT
}