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
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#include "scene_manager.h"
#include "cclass.h"

/*
internal scene registry entry
*/
struct SceneEntry {
    // scene ID
    char *scene_id;
    // scene data
    Scene scene;
};

/*
INTERNAL
copies a string into newly allocated memory
*/
char *CopyStringToNewMemory(const char *str) {
    if (str == NULL) {
        return NULL;
    }

    size_t length = strlen(str) + 1;
    char *copy = (char*)malloc(length);

    if (copy == NULL) {
        return NULL;
    }

    memcpy(copy, str, length);
    return copy;
}

/*
INTERNAL
finds a scene by ID
returns its index, or -1 if it does not exist
*/
int32_t FindScene(SceneManager *self, const char *scene_id) {
    if (self == NULL || scene_id == NULL) {
        return -1;
    }

    for (uint16_t i = 0; i < self->_scene_count; i++) {
        if (strcmp(self->_scenes[i].scene_id, scene_id) == 0) {
            return (int32_t)i;
        }
    }

    return -1;
}

METHOD_IMPL(SceneManager, uint16_t, GetSceneCount) {
    if (self == NULL) {
        return 0;
    }

    return self->_scene_count;
}

METHOD_IMPL(SceneManager, bool, SwitchScene, const char *scene_id) {
    if (self == NULL || scene_id == NULL) {
        return false;
    }

    int32_t index = FindScene(self, scene_id);

    if (index < 0) {
        return false;
    }

    self->_active_scene = (uint16_t)index;
    self->_has_active_scene = true;

    return true;
}

METHOD_IMPL(SceneManager, bool, AddScene, Scene scene, const char *scene_id) {
    if (self == NULL || scene_id == NULL || scene_id[0] == '\0') {
        return false;
    }

    if (scene.init_scene == NULL ||
        scene.run_scene == NULL ||
        scene.cleanup_scene == NULL
    ) {
        return false;
    }

    if (FindScene(self, scene_id) >= 0) {
        return false;
    }

    if (self->_scene_count == UINT16_MAX) {
        return false;
    }

    char *id_copy = CopyStringToNewMemory(scene_id);

    if (id_copy == NULL) {
        return false;
    }

    uint16_t new_count = self->_scene_count + 1;

    SceneEntry *new_scenes = (SceneEntry*)realloc(
        self->_scenes,
        sizeof(SceneEntry) * new_count
    );

    if (new_scenes == NULL) {
        free(id_copy);
        return false;
    }

    self->_scenes = new_scenes;

    SceneEntry *entry = &self->_scenes[self->_scene_count];

    entry->scene_id = id_copy;
    entry->scene = scene;

    /*
    scene data is created by init_scene,
    not by the scene factory
    */
    entry->scene.data = NULL;

    if (!entry->scene.init_scene(&entry->scene)) {
        entry->scene.cleanup_scene(&entry->scene);

        free(entry->scene_id);

        memset(entry, 0, sizeof(SceneEntry));

        return false;
    }

    self->_scene_count = new_count;

    return true;
}

METHOD_IMPL(SceneManager, bool, RemoveScene, const char *scene_id) {
    if (self == NULL || scene_id == NULL) {
        return false;
    }

    int32_t index = FindScene(self, scene_id);

    if (index < 0) {
        return false;
    }

    uint16_t scene_index = (uint16_t)index;
    uint16_t old_count = self->_scene_count;

    SceneEntry *entry = &self->_scenes[scene_index];

    bool was_active = (self->_has_active_scene && self->_active_scene == scene_index);

    bool cleanup_success = entry->scene.cleanup_scene(&entry->scene);

    free(entry->scene_id);

    // shift remaining entries down
    if (scene_index + 1 < old_count) {
        memmove(
            &self->_scenes[scene_index],
            &self->_scenes[scene_index + 1],
            sizeof(SceneEntry) * (old_count - scene_index - 1)
        );
    }

    self->_scene_count--;

    // update active scene tracking
    if (was_active) {
        self->_has_active_scene = false;
        self->_active_scene = 0;
    }
    else if (self->_has_active_scene && self->_active_scene > scene_index) {
        self->_active_scene--;
    }

    // free the registry if it is now empty
    if (self->_scene_count == 0) {
        free(self->_scenes);
        self->_scenes = NULL;

        self->_has_active_scene = false;
        self->_active_scene = 0;
    }

    return cleanup_success;
}

METHOD_IMPL(SceneManager, bool, RunScene, void *scene_data) {
    if (self == NULL || !self->_has_active_scene) {
        return false;
    }

    if (self->_active_scene >= self->_scene_count) {
        return false;
    }

    Scene *scene = &self->_scenes[self->_active_scene].scene;

    return scene->run_scene(scene, scene_data);
}

CONSTRUCTOR_OF(SceneManager) {
    SceneManager *sm = (SceneManager*)calloc(
        1,
        sizeof(SceneManager)
    );

    if (sm == NULL) {
        return NULL;
    }

    REGISTER_METHOD(sm, SceneManager, GetSceneCount);

    REGISTER_METHOD(sm, SceneManager, SwitchScene);

    REGISTER_METHOD(sm, SceneManager, AddScene);

    REGISTER_METHOD(sm, SceneManager, RemoveScene);

    REGISTER_METHOD(sm, SceneManager, RunScene);

    return sm;
}

DESTRUCTOR_OF(SceneManager) {
    if (self == NULL) {
        return;
    }

    for (uint16_t i = 0; i < self->_scene_count; i++) {
        SceneEntry *entry = &self->_scenes[i];

        if (entry->scene.cleanup_scene != NULL) {
            entry->scene.cleanup_scene(&entry->scene);
        }

        free(entry->scene_id);
    }

    free(self->_scenes);
    free(self);
}
