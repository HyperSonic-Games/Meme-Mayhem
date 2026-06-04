package main

import "../Magma/Types"
import "../Magma/Util"
import "../Magma/2D/Renderer"
import "../Magma/2D/UI"
import "../Magma/2D/EventSys"

import "Renderer/Scenes"

main :: proc() {
    ctx := Renderer.Init("MEME_MAYHEM", "Meme Mayhem", 800, 500, .DIRECTX3D11)

    keyboard: EventSys.Keyboard
    mouse: EventSys.Mouse
    window: EventSys.WindowState
    ui := UI.CreateUIContext(&ctx, &mouse)
    fonts := Util.FontStorageCreate()
    ok := fonts->Add("OPEN_SANS_BOLD", .BOLD, "../Assets/Fonts/Open_Sans/OpenSans-Bold.ttf", 30)

    if !ok {
        Util.Log(.ERROR_NO_ABORT, "MEME_MAYHEM_CLIENT", "MAIN", "Could not load font")
    }
    ret := Scenes.MainMenu(ui, &ctx, &keyboard, &mouse, &window, fonts)

    if ret == .QUIT {
        Util.Log(.WARN, "MEME_MAYHEM_CLIENT", "MAIN", "QUITING APP")
    }
}