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
#ifndef MEME_MAYHEM_COMMON_ASSET_SYSTEM_H
#define MEME_MAYHEM_COMMON_ASSET_SYSTEM_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#include "../../Libs/miniz/miniz.h"
#include "raylib_includes.h"

#define MAX_ASSET_ARCHIVE_PATH_LEN 512
#define MAX_ASSET_REGISTRY_NAME_LEN 128

#define ASSET_REGISTRY_INITIAL_CAPACITY 64

#define ASSET_ID_PLAYER_MIN 0
#define ASSET_ID_PLAYER_MAX 999

#define ASSET_ID_WEAPON_MIN 1000
#define ASSET_ID_WEAPON_MAX 1999

#define ASSET_ID_MAP_MIN 2000
#define ASSET_ID_MAP_MAX 2999

#define ASSET_ID_PROJECTILE_MIN 3000
#define ASSET_ID_PROJECTILE_MAX 3999

#define ASSET_ID_FONT_MIN 4000
#define ASSET_ID_FONT_MAX 4999

#define ASSET_ID_SOUND_MIN 5000
#define ASSET_ID_SOUND_MAX 5999

#define ASSET_ID_MUSIC_MIN 6000
#define ASSET_ID_MUSIC_MAX 6999

#define ASSET_ID_UI_MIN 7000
#define ASSET_ID_UI_MAX 7999

#define ASSET_ID_OTHER_MIN 8000
#define ASSET_ID_OTHER_MAX 8999

#define ASSET_ID_MAP_LAYOUT 2999

typedef enum {
    ASSET_TYPE_UNKNOWN = 0, // this is an error!

    ASSET_TYPE_TEXTURE, // image files
    ASSET_TYPE_SOUND, // short WAV files
    ASSET_TYPE_MUSIC, // longer music files
    ASSET_TYPE_FONT, // font files in TTF format

    ASSET_TYPE_DATA, // generic data

} asset_type;

typedef struct {
    Texture texture;
} asset_texture_data;

typedef struct {
    Sound sound;
} asset_sound_data;

typedef struct {
    Music music;
    void *file_data;
    size_t file_size;
} asset_music_data;

typedef struct {
    Font font;
} asset_font_data;

typedef struct {
    void *data;
    size_t size;
} asset_raw_data;

// Asset
typedef struct {
    uint32_t id;
    asset_type type;
    union {
        asset_texture_data texture;
        asset_sound_data sound;
        asset_music_data music;
        asset_font_data font;
        asset_raw_data raw;
    } data;
    bool loaded;
} asset;

// Registry entry
typedef struct {
    uint32_t id;
    char archive_path[MAX_ASSET_ARCHIVE_PATH_LEN];
    mz_uint archive_index;
    asset loaded_asset;
} asset_registry_entry;

// Asset registry
typedef struct {
    mz_zip_archive archive;
    asset_registry_entry *entries;
    uint32_t count;
    uint32_t capacity;
    bool initialized;
} asset_registry;

// Manifest entry
typedef struct {
    uint32_t id;
    char path[MAX_ASSET_ARCHIVE_PATH_LEN];
    asset_type type;
} asset_manifest_entry;

// Manifest
typedef struct {
    asset_manifest_entry *entries;
    uint32_t count;
    uint32_t capacity;
} asset_manifest;

/*
Initializes the asset registry.

archive_data:
    ZIP archive received from the server.

archive_size:
    Size of the compressed archive.

manifest_data:
    Contents of manifest.csv received from the server.

manifest_size:
    Size of manifest.csv.
 
The registry takes ownership of archive_data and manifest_data
only if the implementation explicitly documents that behavior.
*/
bool AssetRegistryInit(
    asset_registry *registry,
    const void *archive_data,
    size_t archive_size,
    const char *manifest_data,
    size_t manifest_size
);

/*
Releases all loaded assets, registry memory, and archive resources.
*/
void AssetRegistryShutdown(asset_registry *registry);

/*
Determines the asset category from its server-assigned ID.

Returns `ASSET_TYPE_UNKNOWN` if the ID is outside all defined ranges.
*/
asset_type AssetTypeFromID(uint32_t id);

/*
Finds an asset by its server assigned numeric ID.
*/
asset_registry_entry *AssetRegistryFind(asset_registry *registry, uint32_t id);

/*
Loads and returns a texture.
Returns NULL if the ID is invalid or has the wrong type.
*/
Texture *AssetRegistryGetTexture(asset_registry *registry, uint32_t id);

/*
Loads and returns a sound.
*/
Sound *AssetRegistryGetSound(asset_registry *registry, uint32_t id);

/*
Loads and returns music.
*/
Music *AssetRegistryGetMusic(asset_registry *registry, uint32_t id);

/*
Loads and returns a font.
*/
Font *AssetRegistryGetFont(asset_registry *registry,uint32_t id);

/*
Loads and returns raw asset data.

out_size receives the extracted data size.
Returned data remains valid until registry shutdown.
*/
const void *AssetRegistryGetData(asset_registry *registry, uint32_t id, size_t *out_size);

bool AssetRegistryHas(const asset_registry *registry, uint32_t id);

asset_type AssetRegistryGetType(const asset_registry *registry, uint32_t id);

uint32_t AssetRegistryGetCount(const asset_registry *registry);

asset_type AssetTypeFromString(const char *type);

const char *AssetTypeToString(asset_type type);

/*
Unloads a previously loaded asset without removing its manifest entry.
*/
bool AssetRegistryUnload(asset_registry *registry, uint32_t id);

/*
Unloads every loaded asset while keeping the registry and archive.
*/
void AssetRegistryUnloadAll(asset_registry *registry);

/*
Builds the asset package from a directory

The caller owns the returned buffer and must free it
*/
bool CreateAssetPackage(
    const char *folder_path,
    void **out_data,
    size_t *out_size
);


#endif // MEME_MAYHEM_COMMON_ASSET_SYSTEM_H
