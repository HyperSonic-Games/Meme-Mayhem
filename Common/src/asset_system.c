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
#include "asset_system.h"
#include "miniz_zip.h"

#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>


char *TrimWhitespace(char *str) {
    while (isspace((unsigned char)*str)) {
        str++;
    }

    char *end = str + strlen(str);

    while (end > str && isspace((unsigned char)end[-1])) {
        end--;
    }

    *end = '\0';

    return str;
}

bool AssetRegistryGrow(asset_registry *registry) {
    if (registry->count < registry->capacity) {
        return true;
    }

    uint32_t new_capacity = registry->capacity ? registry->capacity * 2 : ASSET_REGISTRY_INITIAL_CAPACITY;

    if (new_capacity < registry->capacity) {
        return false;
    }

    asset_registry_entry *entries = realloc(
        registry->entries,
        sizeof(asset_registry_entry) * new_capacity
    );

    if (!entries) {
        return false;
    }

    registry->entries = entries;
    registry->capacity = new_capacity;

    return true;
}

bool AssetRegistryParseManifest(
    asset_registry *registry,
    const char *manifest_data,
    size_t manifest_size
) {
    if (!manifest_data || manifest_size == 0) {
        return false;
    }

    char *buffer = malloc(manifest_size + 1);

    if (!buffer) {
        return false;
    }

    memcpy(buffer, manifest_data, manifest_size);
    buffer[manifest_size] = '\0';

    char *line = buffer;
    bool first_line = true;
    bool success = true;

    while (line < buffer + manifest_size) {
        char *next_line = strchr(line, '\n');

        if (next_line) {
            *next_line = '\0';
            next_line++;
        }

        char *current = TrimWhitespace(line);

        if (*current == '\0') {
            line = next_line ? next_line : buffer + manifest_size;
            continue;
        }

        char *id_text = current;
        char *path_text = strchr(id_text, ',');
        
        if (!path_text) {
            success = false;
            break;
        }

        *path_text++ = '\0';

        char *type_text = strchr(path_text, ',');

        if (!type_text) {
            success = false;
            break;
        }

        *type_text++ = '\0';

        if (strchr(type_text, ',')) {
            success = false;
            break;
        }

        id_text = TrimWhitespace(id_text);
        path_text = TrimWhitespace(path_text);
        type_text = TrimWhitespace(type_text);

        // skip the CSV header
        if (first_line && strcmp(id_text, "id") == 0) {
            first_line = false;
            line = next_line ? next_line : buffer + manifest_size;
            continue;
        }

        first_line = false;

        if (!*id_text || !*path_text || !*type_text) {
            success = false;
            break;
        }

        errno = 0;

        char *end = NULL;
        unsigned long parsed_id = strtoul(id_text, &end, 10);

        if (errno != 0 || !end || *end != '\0' || parsed_id > UINT32_MAX) {
            success = false;
            break;
        }

        uint32_t id = (uint32_t)parsed_id;

        if (strlen(path_text) >= MAX_ASSET_ARCHIVE_PATH_LEN) {
            success = false;
            break;
        }

        asset_type type = AssetTypeFromString(type_text);

        if (type == ASSET_TYPE_UNKNOWN) {
            success = false;
            break;
        }

        // verify the type matches the reserved ID range
        if (AssetTypeFromID(id) != type) {
            success = false;
            break;
        }

        // reject duplicate IDs
        for (uint32_t i = 0; i < registry->count; i++) {
            if (registry->entries[i].id == id) {
                success = false;
                break;
            }
        }

        if (!success)
            break;

        // find the file inside the ZIP archive
        mz_uint archive_index = mz_zip_reader_locate_file(
            &registry->archive,
            path_text,
            NULL,
            MZ_ZIP_FLAG_CASE_SENSITIVE
        );

        if (archive_index == MZ_UINT32_MAX) {
            success = false;
            break;
        }

        mz_zip_archive_file_stat file_stat;

        if (
            !mz_zip_reader_file_stat(
                &registry->archive,
                archive_index,
                &file_stat
            ) 
            || file_stat.m_is_directory
        ) {
            success = false;
            break;
        }

        if (!AssetRegistryGrow(registry)) {
            success = false;
            break;
        }

        asset_registry_entry *entry = &registry->entries[registry->count];

        memset(entry, 0, sizeof(*entry));

        entry->id = id;
        entry->archive_index = archive_index;

        strcpy(entry->archive_path, path_text);

        entry->loaded_asset.id = id;
        entry->loaded_asset.type = type;
        entry->loaded_asset.loaded = false;

        registry->count++;

        line = next_line ? next_line : buffer + manifest_size;
    }

    free(buffer);

    return success;
}

asset_type AssetTypeFromID(uint32_t id) {
    if (id >= ASSET_ID_PLAYER_MIN && id <= ASSET_ID_PLAYER_MAX) {
        return ASSET_TYPE_TEXTURE;
    }

    if (id >= ASSET_ID_WEAPON_MIN && id <= ASSET_ID_WEAPON_MAX) {
        return ASSET_TYPE_TEXTURE;
    }

    if (id >= ASSET_ID_MAP_MIN && id <= ASSET_ID_MAP_MAX) {
        if (id == ASSET_ID_MAP_LAYOUT) {
            return ASSET_TYPE_DATA;
        }

        return ASSET_TYPE_TEXTURE;
    }

    if (id >= ASSET_ID_PROJECTILE_MIN && id <= ASSET_ID_PROJECTILE_MAX) {
        return ASSET_TYPE_TEXTURE;
    }

    if (id >= ASSET_ID_FONT_MIN && id <= ASSET_ID_FONT_MAX) {
        return ASSET_TYPE_FONT;
    }

    if (id >= ASSET_ID_SOUND_MIN && id <= ASSET_ID_SOUND_MAX) {
        return ASSET_TYPE_SOUND;
    }

    if (id >= ASSET_ID_MUSIC_MIN && id <= ASSET_ID_MUSIC_MAX) {
        return ASSET_TYPE_MUSIC;
    }

    if (id >= ASSET_ID_UI_MIN && id <= ASSET_ID_UI_MAX) {
        return ASSET_TYPE_TEXTURE;
    }

    if (id >= ASSET_ID_OTHER_MIN && id <= ASSET_ID_OTHER_MAX) {
        return ASSET_TYPE_DATA;
    }

    return ASSET_TYPE_UNKNOWN;
}

// registry initialization
bool AssetRegistryInit(
    asset_registry *registry,
    const void *archive_data,
    size_t archive_size,
    const char *manifest_data,
    size_t manifest_size
) {
    if (!registry || !archive_data || archive_size == 0) {
        return false;
    }

    memset(registry, 0, sizeof(*registry));

    if (
        !mz_zip_reader_init_mem(
            &registry->archive,
            archive_data,
            archive_size,
            0
        )
    ) {
        return false;
    }

    registry->initialized = true;

    if (!AssetRegistryParseManifest(registry, manifest_data, manifest_size)) {
        AssetRegistryShutdown(registry);
        return false;
    }

    return true;
}


// registry shutdown
void AssetRegistryShutdown(asset_registry *registry) {
    if (!registry) {
        return;
    }

    if (registry->initialized) {
        AssetRegistryUnloadAll(registry);

        mz_zip_reader_end(&registry->archive);
    }

    free(registry->entries);

    memset(registry, 0, sizeof(*registry));
}

// registry lookup
asset_registry_entry *AssetRegistryFind(asset_registry *registry, uint32_t id) {
    if (!registry || !registry->initialized) {
        return NULL;
    }

    for (uint32_t i = 0; i < registry->count; i++) {
        if (registry->entries[i].id == id) {
            return &registry->entries[i];
        }
    }

    return NULL;
}

bool AssetRegistryHas(const asset_registry *registry, uint32_t id) {
    if (!registry || !registry->initialized) {
        return false;
    }

    for (uint32_t i = 0; i < registry->count; i++) {
        if (registry->entries[i].id == id) {
            return true;
        }
    }

    return false;
}

asset_type AssetRegistryGetType(const asset_registry *registry, uint32_t id) {
    if (!registry || !registry->initialized) {
        return ASSET_TYPE_UNKNOWN;
    }

    for (uint32_t i = 0; i < registry->count; i++) {
        if (registry->entries[i].id == id) {
            return registry->entries[i].loaded_asset.type;
        }
    }

    return ASSET_TYPE_UNKNOWN;
}

uint32_t AssetRegistryGetCount(const asset_registry *registry) {
    if (!registry || !registry->initialized) {
        return 0;
    }

    return registry->count;
}

// raw data extraction
const void *AssetRegistryGetData(asset_registry *registry, uint32_t id, size_t *out_size) {
    if (out_size) {
        *out_size = 0;
    }

    asset_registry_entry *entry = AssetRegistryFind(registry, id);

    if (!entry || entry->loaded_asset.type != ASSET_TYPE_DATA) {
        return NULL;
    }

    if (!entry->loaded_asset.loaded) {
        size_t size = 0;

        void *data = mz_zip_reader_extract_to_heap(
            &registry->archive,
            entry->archive_index,
            &size,
            0
        );

        if (!data)
            return NULL;

        entry->loaded_asset.data.raw.data = data;
        entry->loaded_asset.data.raw.size = size;
        entry->loaded_asset.loaded = true;
    }

    if (out_size)
        *out_size = entry->loaded_asset.data.raw.size;

    return entry->loaded_asset.data.raw.data;
}

// texture loading
Texture *AssetRegistryGetTexture(asset_registry *registry, uint32_t id) {
    asset_registry_entry *entry = AssetRegistryFind(registry, id);

    if (!entry || entry->loaded_asset.type != ASSET_TYPE_TEXTURE) {
        return NULL;
    }

    if (!entry->loaded_asset.loaded) {
        size_t size = 0;

        void *data = mz_zip_reader_extract_to_heap(
            &registry->archive,
            entry->archive_index,
            &size,
            0
        );

        if (!data || size > INT_MAX) {
            mz_free(data);
            return NULL;
        }

        const char *extension = GetFileExtension(entry->archive_path);

        if (!extension) {
            mz_free(data);
            return NULL;
        }

        Image image = LoadImageFromMemory(
            extension,
            data,
            (int)size
        );

        mz_free(data);

        if (!image.data) {
            return NULL;
        }

        Texture texture = LoadTextureFromImage(image);

        UnloadImage(image);

        if (texture.id == 0) {
            return NULL;
        }

        entry->loaded_asset.data.texture.texture = texture;
        entry->loaded_asset.loaded = true;
    }

    return &entry->loaded_asset.data.texture.texture;
}

// sound loading
Sound *AssetRegistryGetSound(asset_registry *registry, uint32_t id) {
    asset_registry_entry *entry = AssetRegistryFind(registry, id);

    if (!entry || entry->loaded_asset.type != ASSET_TYPE_SOUND) {
        return NULL;
    }

    if (!entry->loaded_asset.loaded) {
        size_t size = 0;

        void *data = mz_zip_reader_extract_to_heap(
            &registry->archive,
            entry->archive_index,
            &size,
            0
        );

        if (!data || size > INT_MAX) {
            mz_free(data);
            return NULL;
        }

        const char *extension = GetFileExtension(entry->archive_path);

        if (!extension) {
            mz_free(data);
            return NULL;
        }

        Wave wave = LoadWaveFromMemory(
            extension,
            data,
            (int)size
        );

        mz_free(data);

        if (!wave.data) {
            return NULL;
        }

        Sound sound = LoadSoundFromWave(wave);

        UnloadWave(wave);

        if (!sound.stream.buffer) {
            return NULL;
        }

        entry->loaded_asset.data.sound.sound = sound;
        entry->loaded_asset.loaded = true;
    }

    return &entry->loaded_asset.data.sound.sound;
}

// music loading
Music *AssetRegistryGetMusic( asset_registry *registry, uint32_t id) {
    asset_registry_entry *entry = AssetRegistryFind(registry, id);

    if (!entry || entry->loaded_asset.type != ASSET_TYPE_MUSIC) {
        return NULL;
    }

    if (!entry->loaded_asset.loaded) {
        size_t size = 0;

        void *data = mz_zip_reader_extract_to_heap(
            &registry->archive,
            entry->archive_index,
            &size,
            0
        );

        if (!data || size > INT_MAX) {
            mz_free(data);
            return NULL;
        }

        const char *extension = GetFileExtension(entry->archive_path);

        if (!extension) {
            mz_free(data);
            return NULL;
        }

        Music music = LoadMusicStreamFromMemory(
            extension,
            data,
            (int)size
        );

        if (!music.stream.buffer) {
            mz_free(data);
            return NULL;
        }

        entry->loaded_asset.data.music.music = music;
        entry->loaded_asset.data.music.file_data = data;
        entry->loaded_asset.data.music.file_size = size;
        entry->loaded_asset.loaded = true;
    }

    return &entry->loaded_asset.data.music.music;
}

// font loading
Font *AssetRegistryGetFont(asset_registry *registry, uint32_t id) {
    asset_registry_entry *entry = AssetRegistryFind(registry, id);

    if (!entry || entry->loaded_asset.type != ASSET_TYPE_FONT) {
        return NULL;
    }

    if (!entry->loaded_asset.loaded) {
        size_t size = 0;

        void *data = mz_zip_reader_extract_to_heap(
            &registry->archive,
            entry->archive_index,
            &size,
            0
        );

        if (!data || size > INT_MAX) {
            mz_free(data);
            return NULL;
        }

        const char *extension = GetFileExtension(entry->archive_path);

        if (!extension) {
            mz_free(data);
            return NULL;
        }

        Font font = LoadFontFromMemory(
            extension,
            data,
            (int)size,
            32,
            NULL,
            0
        );

        mz_free(data);

        if (font.texture.id == 0) {
            return NULL;
        }

        entry->loaded_asset.data.font.font = font;
        entry->loaded_asset.loaded = true;
    }

    return &entry->loaded_asset.data.font.font;
}

// asset type conversion
asset_type AssetTypeFromString(const char *type) {
    if (!type) {
        return ASSET_TYPE_UNKNOWN;
    }

    if (strcmp(type, "TEXTURE") == 0) {
        return ASSET_TYPE_TEXTURE;
    }

    if (strcmp(type, "SOUND") == 0) {
        return ASSET_TYPE_SOUND;
    }

    if (strcmp(type, "MUSIC") == 0) {
        return ASSET_TYPE_MUSIC;
    }

    if (strcmp(type, "FONT") == 0) {
        return ASSET_TYPE_FONT;
    }

    if (strcmp(type, "DATA") == 0) {
        return ASSET_TYPE_DATA;
    }

    return ASSET_TYPE_UNKNOWN;
}

const char *AssetTypeToString(asset_type type) {
    switch (type) {
        case ASSET_TYPE_TEXTURE:
            return "TEXTURE";

        case ASSET_TYPE_SOUND:
            return "SOUND";

        case ASSET_TYPE_MUSIC:
            return "MUSIC";

        case ASSET_TYPE_FONT:
            return "FONT";

        case ASSET_TYPE_DATA:
            return "DATA";

        default:
            return "UNKNOWN";
    }
}

// asset unloading */
bool AssetRegistryUnload(asset_registry *registry, uint32_t id) {
    asset_registry_entry *entry = AssetRegistryFind(registry, id);

    if (!entry || !entry->loaded_asset.loaded) {
        return false;
    }

    asset *loaded = &entry->loaded_asset;

    switch (loaded->type) {
        case ASSET_TYPE_TEXTURE:
            UnloadTexture(loaded->data.texture.texture);
            break;

        case ASSET_TYPE_SOUND:
            UnloadSound(loaded->data.sound.sound);
            break;

        case ASSET_TYPE_MUSIC:
            UnloadMusicStream(loaded->data.music.music);

            mz_free(loaded->data.music.file_data);

            loaded->data.music.file_data = NULL;
            loaded->data.music.file_size = 0;
            break;

        case ASSET_TYPE_FONT:
            UnloadFont(loaded->data.font.font);
            break;

        case ASSET_TYPE_DATA:
            mz_free(loaded->data.raw.data);

            loaded->data.raw.data = NULL;
            loaded->data.raw.size = 0;
            break;

        default:
            return false;
    }

    memset(&loaded->data, 0, sizeof(loaded->data));

    loaded->loaded = false;

    return true;
}

void AssetRegistryUnloadAll(asset_registry *registry) {
    if (!registry || !registry->initialized) {
        return;
    }

    for (uint32_t i = 0; i < registry->count; i++) {
        AssetRegistryUnload(registry, registry->entries[i].id);
    }
}