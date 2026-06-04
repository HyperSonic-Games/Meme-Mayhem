/*
HyperSonic Games Non-Commercial Source License (HSG-NCSL)
Copyright (c) 2025 HyperSonic-Games

This license governs the use, modification, and distribution of Meme Mayhem
and any derivative works (“Mods”). By using or contributing to this software,
you agree to the following terms.

Permissions:
  - You may use, copy, modify, and distribute the Software for non-commercial purposes only.
  - You may create Mods or derivative works, subject to the conditions below.
  - All copies or substantial portions of the Software must include this license
    and the original copyright notice.

Modifications & Contributions:
  - Mods or derivative works must be released under terms that allow free use,
    modification, and redistribution.
  - Mods must clearly indicate they are based on Meme Mayhem.
  - Mods must not imply official endorsement or affiliation with HyperSonic-Games.
  - All contributions must include proper attribution to HyperSonic-Games,
    specifying the mod’s relationship to the original project.
  - When a contribution, fix, or improvement is incorporated into the official
    project, credit must appear in the following format:

      // Contribution by: [MODDER NAME]
      // Description: Brief description of the fix or improvement
      code

Commercial Restriction:
  - The Software and all Mods may NOT be used for any Commercial Purpose.
  - “Commercial Purpose” includes, but is not limited to:
      - Selling the Software or Mods
      - Charging access, subscription, or usage fees
      - Paywalls or gated downloads
      - Bundling with paid products or services
      - Any direct or indirect monetization that restricts free access
  - Free distribution and voluntary donations without access restrictions are allowed.

Responsibilities & Disclaimers:
  - HyperSonic-Games provides the Software “as is” without warranty of any kind.
  - HyperSonic-Games is not responsible for Mods, including safety, functionality,
    or correctness.
  - Contributors are responsible for their own modifications and distributions.
  - HyperSonic-Games may, at their discretion, review and incorporate contributions,
    but is not required to include any Mod or modification in full or in part.

Objective:
  This license is intended to encourage open collaboration and modding while
  ensuring that all improvements remain freely accessible, properly attributed,
  and not commercially exploited.

Warranty:
  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER
  LIABILITY ARISING FROM THE USE OF THE SOFTWARE OR MODIFICATIONS.
*/
package main

import "../Magma/Types"
import "../Magma/Util"
import "../Magma/2D/Renderer"
import "../Magma/2D/UI"
import "../Magma/2D/EventSys"

import "Renderer/Scenes"

main :: proc() {
    ctx := Renderer.Init("MEME_MAYHEM", "Meme Mayhem", 800, 500, .SOFTWARE)

    keyboard: EventSys.Keyboard
    mouse: EventSys.Mouse
    window: EventSys.WindowState
    ui := UI.CreateUIContext(&ctx, &mouse)
    fonts := Util.FontStorageCreate()
    ok := fonts->Add("OPEN_SANS_BOLD", .BOLD, "Assets/Fonts/Open_Sans/OpenSans-Bold.ttf", 28)
    ok = fonts->Add("OPEN_SANS_BOLD", .BOLD, "Assets/Fonts/Open_Sans/OpenSans-Bold.ttf", 48)

    if !ok {
        Util.Log(.ERROR_NO_ABORT, "MEME_MAYHEM_CLIENT", "MAIN", "Could not load font")
    }
    ret := Scenes.MainMenu(ui, &ctx, &keyboard, &mouse, &window, fonts)

    if ret == .QUIT {
        Util.Log(.WARN, "MEME_MAYHEM_CLIENT", "MAIN", "QUITING APP")
    }
    else {
        Util.Log(.INFO, "MEME_MAYHEM_CLIENT", "MAIN", "Exiting with code %s from MainMenu", ret)
    }
}