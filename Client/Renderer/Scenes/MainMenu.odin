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


MainMenu :: proc(
    ui_ctx: ^UI.UIContext,
    renderer_ctx: ^Renderer.RenderContext,
    keyboard: ^EventSys.Keyboard,
    mouse: ^EventSys.Mouse,
    window_state: ^EventSys.WindowState,
    fonts: ^Util.FontStorage,
) -> MainMenuResult {

    title_tex, title_w, title_h := Renderer.RenderTextToTexture(
        renderer_ctx,
        "MAIN MENU",
        fonts->Get("OPEN_SANS_BOLD", .BOLD, 48),
        {255, 255, 255, 255},
        600,
        false,
    )

    if title_tex == nil {
        Util.Log(.ERROR, "MEME_MAYHEM_CLIENT", "MAIN_MENU", "Could not load font")
        return .QUIT
    }

    connect_tex, _, _ := Renderer.RenderTextToTexture(
        renderer_ctx,
        "CONNECT",
        fonts->Get("OPEN_SANS_BOLD", .BOLD, 28),
        {255, 255, 255, 255},
        400,
        false,
    )

    credits_tex, _, _ := Renderer.RenderTextToTexture(
        renderer_ctx,
        "CREDITS",
        fonts->Get("OPEN_SANS_BOLD", .BOLD, 28),
        {255, 255, 255, 255},
        400,
        false,
    )

    quit_tex, _, _ := Renderer.RenderTextToTexture(
        renderer_ctx,
        "QUIT",
        fonts->Get("OPEN_SANS_BOLD", .BOLD, 28),
        {255, 255, 255, 255},
        400,
        true,
    )

    for window_state.should_quit == false {
        EventSys.ResetWindowFlags(window_state)

        Renderer.FPSLimiter(60)
        EventSys.HandleEvents(mouse, keyboard, window_state)

        Renderer.ClearScreen(renderer_ctx, {15, 15, 20, 255})

        window_size := Renderer.GetWindowSize(renderer_ctx)

        // ---- Layout ----
        center_x := window_size[0] / 2
        start_y := window_size[1] / 3

        button_w: f32 = 260
        button_h: f32 = 60
        spacing: f32 = 20

        // Title
        Renderer.DrawTexture(
            renderer_ctx,
            title_tex,
            {f32(center_x - i32(title_w) / 2), f32(start_y - 140)},
            0.0
        )

        // CONNECT
        connect_pressed := UI.TextButton(
            ui_ctx,
            connect_tex,
            {f32(center_x - i32(button_w) / 2), f32(start_y)},
            {button_w, button_h},
            {70, 70, 70, 255},
            {95, 95, 95, 255},
        )

        if connect_pressed {
            return .CONNECT
        }

        // ---- CREDITS ----
        credits_pressed := UI.TextButton(
            ui_ctx,
            credits_tex,
            {f32(center_x - i32(button_w) / 2), f32(start_y) + (button_h + spacing)},
            {button_w, button_h},
            {70, 70, 70, 255},
            {95, 95, 95, 255},
        )

        if credits_pressed {
            return .CREDITS
        }

        // ---- QUIT ----
        quit_pressed := UI.TextButton(
            ui_ctx,
            quit_tex,
            {f32(center_x - i32(button_w) / 2), f32(start_y) + 2 * (button_h + spacing)},
            {button_w, button_h},
            {90, 60, 60, 255},
            {120, 80, 80, 255},
        )

        if quit_pressed {
            return .QUIT
        }

        Renderer.Update(renderer_ctx)
        Renderer.PresentScreen(renderer_ctx)
    }

    return .QUIT
}