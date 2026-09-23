/* 
HyperSonic Games Non-Commercial Source License (HSG-NCSL) 
Copyright (c) 2026 HyperSonic Games

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
package Scenes

import "base:runtime"
import "core:container/xar"

import "../../Magma/2D/Renderer"
import "../../Magma/2D/UI"
import "../../Magma/Util"

Scene :: struct {
    name: string,

    init: proc(self: ^Scene) -> bool,
    update: proc(
        self: ^Scene,
        render_ctx: ^Renderer.RenderContext,
        ui_ctx: ^UI.UIContext,
        delta_time: f32
    ),
    cleanup: proc(self: ^Scene),

    state: rawptr // NOTE: managed by the Scene
}


SceneManager :: struct {
    scene_buffer: xar.Array(Scene, 6),
    current_scene: ^Scene,
    scene_count: u16,
}

InitSceneManager :: proc(allocator := context.allocator) -> ^SceneManager {
    scene_manager, err := new(SceneManager, allocator)
    if err != .None {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_INIT",
            "Failed to allocate the scene manager"
        )
        return nil
    }

    xar.array_init(&scene_manager.scene_buffer, allocator)

    return scene_manager
}

ShutdownSceneManager :: proc(scene_manager: ^SceneManager) {
    if scene_manager == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_SHUTDOWN",
            "Expected scene_manager but got nil",
        )
    }

    if scene_manager.current_scene != nil {
        if scene_manager.current_scene.cleanup == nil {
            Util.Log(
                .ERROR,
                "MEME_MAYHEM_CLIENT",
                "SCENE_MANAGER_SHUTDOWN",
                "No cleanup function is registered for the Scene: %s",
                scene_manager.current_scene.name,
            )
        }

        scene_manager.current_scene->cleanup()
        scene_manager.current_scene = nil
    }

    xar.destroy(&scene_manager.scene_buffer)

    scene_manager.scene_count = 0
}

AddScene :: proc(scene_manager: ^SceneManager, scene_setup: proc() -> Scene) {
    scene := scene_setup()
    if scene == {} {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_ADD_SCENE",
            "Can not add a Scene that does not exist"
        )
    }

    _, err := xar.append(&scene_manager.scene_buffer, scene)

    if err != .None {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_ADD_SCENE",
            "Could not append the Scene to the Scene Manager's Scene Buffer"
        )
    }

    scene_manager.scene_count += 1
}

@(private="file")
FindScene :: proc(scene_manager: ^SceneManager, name: string) -> ^Scene {
    for i: u16 = 0; i < scene_manager.scene_count; i += 1 {
        scene: ^Scene = xar.get_ptr(&scene_manager.scene_buffer, i)
        if scene.name == name {
            return scene
        }
    }

    Util.Log(
        .ERROR,
        "MEME_MAYHEM_CLIENT",
        "SCENE_MANAGER_FIND_SCENE",
        "Could not find Scene for search query: %s",
        name
    )

    return nil // Not ever reached but needed to satisfy the compiler :p
}

LoadScene :: proc(scene_manager: ^SceneManager, name: string) {
    if scene_manager == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_LOAD_SCENE",
            "Expected scene_manager but got nil",
        )
    }

    scene := FindScene(scene_manager, name)

    if scene == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_LOAD_SCENE",
            "Could not find Scene: %s",
            name,
        )
    }

    if scene_manager.current_scene != nil {
        if scene_manager.current_scene.cleanup == nil {
            Util.Log(
                .ERROR,
                "MEME_MAYHEM_CLIENT",
                "SCENE_MANAGER_LOAD_SCENE",
                "No Cleanup function is registered for the currently loaded Scene: %s",
                scene_manager.current_scene.name,
            )
        }

        scene_manager.current_scene->cleanup()
        scene_manager.current_scene = nil
    }

    if scene.init == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_LOAD_SCENE",
            "No Init function is registered for the Scene: %s",
            name,
        )
    }

    ok: bool = scene->init()

    if !ok {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_LOAD_SCENE",
            "Failed to initialize Scene: %s",
            name,
        )
    }

    scene_manager.current_scene = scene
}

UpdateScene :: proc(
    scene_manager: ^SceneManager,
    render_ctx: ^Renderer.RenderContext,
    ui_ctx: ^UI.UIContext,
    delta_time: f32
) {
    if scene_manager.current_scene.update == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_UPDATE_SCENE",
            "No Update function is registered for the Scene: %s",
            scene_manager.current_scene.name
        )
    }

    if render_ctx == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_UPDATE_SCENE",
            "Expected a render_ctx but got nil"
        )
    }
    
    if ui_ctx == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_UPDATE_SCENE",
            "Expected ui_ctx but got nil"
        )
    }

    scene_manager.current_scene->update(render_ctx, ui_ctx, delta_time)

}

RemoveScene :: proc(scene_manager: ^SceneManager) {
    if scene_manager == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_REMOVE_SCENE",
            "Expected scene_manager but got nil",
        )
    }

    if scene_manager.current_scene == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_REMOVE_SCENE",
            "Can not remove Scene because there is no current Scene",
        )
    }

    if scene_manager.current_scene.cleanup == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_REMOVE_SCENE",
            "No cleanup function is registered for the Scene: %s",
            scene_manager.current_scene.name,
        )
    }

    scene_manager.current_scene->cleanup()
}

GetCountOfRegisteredScenes :: proc(scene_manager: ^SceneManager) -> u16 {
    return scene_manager.scene_count
}

GetSceneData :: proc(scene_manager: ^SceneManager) -> rawptr {
    if scene_manager == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_GET_SCENE_DATA",
            "Expected scene_manager but got nil",
        )
    }

    if scene_manager.current_scene == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_GET_SCENE_DATA",
            "No Scene is currently loaded",
        )
    }

    if scene_manager.current_scene.state == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_GET_SCENE_DATA",
            "The current Scene has no state",
        )
    }

    return scene_manager.current_scene.state
}

GetCurrentlyLoadedScene :: proc(scene_manager: ^SceneManager) -> string {
    if scene_manager == nil {
        Util.Log(
            .ERROR,
            "MEME_MAYHEM_CLIENT",
            "SCENE_MANAGER_GET_CURRENTLY_LOADED_SCENE",
            "Expected scene_manager but got nil",
        )
    }

    if scene_manager.current_scene == nil {
        return ""
    }

    return scene_manager.current_scene.name
}