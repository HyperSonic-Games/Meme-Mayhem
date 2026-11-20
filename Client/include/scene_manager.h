/*
HyperSonic Games Non-Commercial Source License (HSG-NCSL)
Copyright (c) 2026 HyperSonic-Games

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the “Software”), to use, copy, modify, and distribute the Software, subject to the terms below.

1. Permissions
You may:
* Use the Software for any non-commercial purpose.
* Copy and redistribute the Software in source or binary form.
* Modify the Software and create derivative works (“Mods”).

2. Non-Commercial Restriction
The Software and all derivative works (“Mods”) may not be used for any Commercial Purpose. “Commercial Purpose”
means any use intended to generate revenue or monetary compensation, directly or indirectly, including but not limited to:
* Selling the Software or Mods.
* Charging access, subscription, or usage fees.
* Placing the Software or Mods behind paywalls or gated access.
* Bundling with paid products or services.
* Monetizing distribution or access in any form.

Exceptions: This restriction does not prohibit free distribution, open-source sharing, or the receipt of voluntary financial donations
(such as tips, Ko-fi, or Patreon support), provided that such donations are strictly optional
and do not restrict, delay, time-gate, or block access to the Software, Mods, updates, or specific features.

3. Mod Requirements
All Mods or derivative works must:
* Be distributed under terms that allow free use, modification, and redistribution.
* Clearly state they are based on HyperSonic-Games Software.
* Clearly differentiate themselves from the original Software (name, branding, and description must not imply official status).
* Include this license or a reference to it.
* Mods must not imply endorsement, sponsorship, or official affiliation with HyperSonic-Games unless explicitly authorized in writing.

4. Attribution
All copies or substantial portions of the Software must include the original copyright notice and this license.

5. Upstream Contributions
HyperSonic-Games may, at its sole discretion, incorporate fixes, improvements, or other contributions from Mods into the official Software.
By making a Mod or contribution publicly available,
the author grants HyperSonic-Games a non-exclusive, perpetual, irrevocable, royalty-free, worldwide license to use, modify,
and distribute that contribution within the official Software. 

When incorporated, attribution will be provided in-source as:
// Contribution by: [NAME]
// Description: [SHORT DESCRIPTION]

No obligation exists to review, accept, or include any contribution.

6. Branding and Trademark
This license does not grant any rights to use “HyperSonic Games” as a trademark, brand name, or endorsement identity.
Separate permission is required for official branding or affiliation.

7. Warranty Disclaimer
The Software is provided “AS IS”, without warranty of any kind, express or implied. The authors are not liable for any damages arising from its use.

8. Termination
Any violation of the Non-Commercial Restriction, Mod Requirements, or attribution requirements automatically terminates this license.
*/
#ifndef MEME_MAYHEM_CLIENT_SCENE_MANAGER_H
#define MEME_MAYHEM_CLIENT_SCENE_MANAGER_H

#include <stdbool.h>
#include <stdint.h>

#include "cclass.h"

// Forward declaration
typedef struct Scene Scene;

/*
scene struct that holds function pointers to functions
for the scene and a pointer to its internal data.
*/
struct Scene {
    /*
    initializes the scene and allocates any persistent data
    the scene owns the resulting `data` pointer
    */
    bool (*init_scene)(Scene *self);

    /*
    runs the scene with supplied per frame external data
    */
    bool (*run_scene)(Scene *self, void *scene_data);

    /*
    frees all data associated with this scene
    must handle initialization errors and partial initialization
    may be called even if init_scene failed
    */
    bool (*cleanup_scene)(Scene *self);

    /*
    Pointer to scene-owned data.
    */
    void* data;
};

/*
scene registry entry
this is an internal struct
*/
typedef struct SceneEntry SceneEntry;

/*
Scene manager class
*/
CLASS(SceneManager) {
    /*
    PRIVATE
    count of all the scenes we have loaded for this scene manager
    */
    uint16_t _scene_count;
    /*
    PRIVATE
    list of scene entries
    */
    SceneEntry* _scenes;
    /*
    PRIVATE
    scene entry index to the active scene
    used for faster lookups than using the scene's id
    */
    uint16_t _active_scene;
    /*
    PRIVATE
    if we have an active scene or not
    */
    bool _has_active_scene;
    /*
    get the current count of all the scenes we are storing
    in this scene manager
    */
    METHOD_PTR(SceneManager, uint16_t, GetSceneCount);
    /*
    switches the active scene using its id
    returns false on failure
    otherwise returns true
    */
    METHOD_PTR(SceneManager, bool, SwitchScene, const char* scene_id);
    /*
    adds a new scene by copying the Scene struct and binding it to an id
    then calls the scene's init function
    returns false on failure
    otherwise returns true
    */
    METHOD_PTR(SceneManager, bool, AddScene, Scene scene, const char* scene_id);
    /*
    removes a scene using it's id and calls it's shutdown function
    if the active scene is removed, the manager will have
    no active scene afterward
    returns false on failure
    otherwise returns true
    */
    METHOD_PTR(SceneManager, bool, RemoveScene, const char* scene_id);
    /*
    runs the currently active scene and suplies it scene defined data
    returns false on failure
    otherwise returns true
    */
    METHOD_PTR(SceneManager, bool, RunScene, void* scene_data);
};

CONSTRUCTOR_OF(SceneManager);
DESTRUCTOR_OF(SceneManager);

#endif // MEME_MAYHEM_CLIENT_SCENE_MANAGER_H