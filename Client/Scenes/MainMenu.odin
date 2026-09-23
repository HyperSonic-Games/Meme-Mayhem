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


ButtonStatus :: enum {
    PLAY,
    SETTINGS,
    QUIT
}

MainMenuState :: struct {
    button_status: ButtonStatus,
    
}


@(private="file")
init :: proc(self: ^Scene) -> bool {
    return true
}