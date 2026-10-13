/* 
HyperSonic Games Non-Commercial Source License (HSG-NCSL) 
Copyright (c) 2025 HyperSonic Games

This license governs the use, modification, and distribution of Meme Mayhem and any derivative works (“Mods”). By using, modifying, or distributing this software, you agree to the following terms.

Permissions:
- You may use, copy, modify, and distribute the Software for non-commercial purposes only.
- You may create Mods or derivative works, subject to the conditions below.
- All copies or substantial portions of the Software must include this license and the original copyright notice.

Modifications & Contributions:
- Mods or derivative works must be released under terms that allow free use, modification, and redistribution.
- Mods must clearly indicate they are based on Meme Mayhem and must not imply official endorsement or affiliation with HyperSonic Games.
- By making a Mod or contribution publicly available, you grant HyperSonic Games a perpetual, irrevocable, royalty-free license to use and integrate your changes into the official project.
- When a contribution, fix, or improvement is incorporated into the official project, credit will appear in the source code as:
  // Contribution by: [MODDER NAME]
  // Description: Brief description of the fix or improvement code

Commercial Restriction:
- The Software and all Mods may NOT be used for any Commercial Purpose.
- “Commercial Purpose” includes, but is not limited to: selling, charging subscription/usage fees, paywalls, gated downloads, bundling with paid products, or any direct/indirect monetization that restricts free access.
- Optional, voluntary donations (e.g., tips, Patreon) are allowed, provided they do not restrict, delay, time-gate, or block access to the Software, Mods, or updates.

Responsibilities & Disclaimers:
- HyperSonic Games provides the Software “as is” without warranty of any kind and is not responsible for the safety, functionality, or correctness of community Mods.
- HyperSonic Games may, at their sole discretion, review and incorporate contributions, but has no obligation to do so.
- Any violation of the Commercial Restrictions or Mod Requirements automatically terminates your rights under this license.

Objective: This license is intended to encourage open collaboration and modding while ensuring that all improvements remain freely accessible, properly attributed, and not commercially exploited.

Warranty: 
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES, OR OTHER LIABILITY ARISING FROM THE USE OF THE SOFTWARE, MODIFICATIONS, OR THEIR DISTRIBUTION.
*/
package main

import "core:mem"
import "core:fmt"
import "../Magma/Types"
import "../Magma/Util"
import "../Magma/2D/Renderer"
import "../Magma/2D/UI"
import "../Magma/2D/EventSys"
import "Scenes"


/*
NOTE(A-Boring-Square): if needed change backend here
this is useful for debuging, performance and/or porting to other platforms
we chose OpenGL as a backend by default for broad compat and more speed then just software rendering
*/
GRAPHICS_BACKEND: Renderer.GraphicsBackend : .OPEN_GL

windowed_mode :: ODIN_DEBUG


/*
NOTE(A-Boring-Square)
I should realy stop forgeting to add scenes to this enum
*/
SceneRegistry :: enum {
    None,
    MainMenu,
    Settings,
    Game
}

main :: proc() {
    when ODIN_DEBUG {
        track: mem.Tracking_Allocator
        mem.tracking_allocator_init(&track, context.allocator)
        
        defer mem.tracking_allocator_destroy(&track)
        context.allocator = mem.tracking_allocator(&track)
    }

    Util.Log(
        .VERBOSE,
        "MEME_MAYHEM_CLIENT",
        "MAIN",
        "Starting Setup..."
    )

    NextScene: SceneRegistry = .None

    err: mem.Allocator_Error

    keyboard_events: ^EventSys.Keyboard

    keyboard_events, err = new(EventSys.Keyboard)
    if err != .None {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "MAIN",
            "Could not allocate memory for keyboard_events"
        )
    }

    mouse_events: ^EventSys.Mouse

    mouse_events, err = new(EventSys.Mouse)
    if err != .None {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "MAIN",
            "Could not allocate memory for mouse_events"
        )
    }

    window_state: ^EventSys.WindowState

    scene_manager: ^Scenes.SceneManager
    scene_manager = Scenes.InitSceneManager()

    window_state, err = new(EventSys.WindowState)
    if err != .None {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "MAIN",
            "Could not allocate memory for window_state"
        )
    }



    ui_ctx: ^UI.UIContext

    renderer_ctx: Renderer.RenderContext

    Util.Log(
        .VERBOSE,
        "MEME_MAYHEM_CLIENT",
        "MAIN",
        "Setup complete loading client data.."
    )

    renderer_ctx = Renderer.Init(
        "MEME_MAYHEM",
        "Meme Mayhem ALPHA",
        800,
        400,
        GRAPHICS_BACKEND,
        false // set to true for when something realy bad happens and we can not figure out why
    )

    ui_ctx = UI.CreateUIContext(&renderer_ctx, mouse_events)

    Renderer.SetFullscreen(
        renderer_ctx,
        !windowed_mode
    )
    
    // Load the initial scene once.
    NextScene = .MainMenu
    Scenes.LoadScene(scene_manager, "MAIN_MENU")
    
    // Main loop
    for !window_state.should_quit {
        Renderer.FPSLimiter(60)
        delta_time := Renderer.GetDeltaTime()

        Renderer.ClearScreen(&renderer_ctx, Types.Color{0, 0, 0, 255})
        
        Scenes.UpdateScene(
            scene_manager,
            &renderer_ctx,
            ui_ctx,
            keyboard_events,
            window_state,
            delta_time,
        )

        Renderer.Update(&renderer_ctx)
        Renderer.PresentScreen(&renderer_ctx)
        
        switch Scenes.GetCurrentlyLoadedScene(scene_manager) {
            case "MAIN_MENU":
                state := transmute(^Scenes.MainMenuState)(Scenes.GetSceneData(scene_manager))
                
                switch state.button_status {
                    case .NONE:
                        break
                    
                    case .PLAY:
                        NextScene = .Game
                    
                    case .SETTINGS:
                        NextScene = .Settings
                    
                    case .QUIT:
                        window_state.should_quit = true
                }
            
            case "SETTINGS":
                // Handle settings state here.
                break
            
            case "GAMEPLAY":
                // Handle gameplay state here.
                break
        }
        
        if NextScene != .None {
            switch NextScene {
                case .MainMenu:
                    Scenes.LoadScene(scene_manager, "MAIN_MENU")
            
                case .Settings:
                    Scenes.LoadScene(scene_manager, "SETTINGS")
                
                case .Game:
                    Scenes.LoadScene(scene_manager, "GAME")
                
                case .None:
                    break
            }
            
            NextScene = .None
        }
    }

    Util.Log(
        .VERBOSE,
        "MEME_MAYHEM_CLIENT",
        "MAIN",
        "Cleaning up..."
    )

    Renderer.Shutdown(renderer_ctx)
    UI.DestroyUIContext(ui_ctx)

    free(keyboard_events)
    free(mouse_events)
    free(window_state)
    Scenes.ShutdownSceneManager(scene_manager)

    free_all(context.temp_allocator)

    when ODIN_DEBUG {
        if len(track.allocation_map) > 0 {
            fmt.eprintf("=== %v Memory Leaks ===\n", len(track.allocation_map))
            
            for _, entry in track.allocation_map {
                fmt.eprintf("- %v bytes leaked @ %v\n", entry.size, entry.location)
            }
        }

        if len(track.bad_free_array) > 0 {
            fmt.eprintf("=== %v Bad Frees ===\n", len(track.bad_free_array))
            
            for entry in track.bad_free_array {
                fmt.eprintf("- Bad free @ %v\n", entry.location)
            }
        }
    }
}