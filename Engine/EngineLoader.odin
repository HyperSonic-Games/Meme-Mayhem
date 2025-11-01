package Engine

import rl "vendor:raylib"
import "core:fmt"
import "core:dynlib"

// Data types

Vec2 :: #simd[2]f64



Player :: struct {
    pos: ^Vec2,
    rot: f32,
    texture: rl.Texture,
    name: string,
    equiped_weapon: WeaponData,
    hp: u8
}

WeaponType :: enum {
    Automatic,
    Melee,
    OneUse,
}

WeaponData :: struct {
    type: WeaponType,
    display_name: string,
    ammo: u16,
    shot_dmg: u16,
    head_shot_dmg: u16,
    range: u32, // in pixels
    reload_time: u8 // in seconds
}

MapTileType :: enum {
    GROUND, // Simple ground tile has no metadata
    WALL, // Simple wall tile has collision and blocks light
}

MapTile :: struct {
    type: MapTileType,
    image_ref: ^rl.Image,  // points to global texture
    grid_pos_x: u32,
    grid_pos_y: u32,
}

MapInteractable :: struct {
    pos: ^Vec2,
    on_place_attempt: MapInteractableOnPlaceAtempt
}


Map :: struct {
    tile_dat: [dynamic]MapTile,
    interactables: [dynamic]MapInteractable
}

EngineContext :: struct {
    curr_loaded_map_dat: Map,
    players: []Player
}


// Game called procs

// Called when a mod is first loaded by the game client
ClientOnLoad :: #type proc()

// Called when a mod is first loaded by the game server
ServerOnLoad :: #type proc()

// Called when a map interactable is atempting to be placed in the world
MapInteractableOnPlaceAtempt :: #type proc(
    map_data: ^Map,
    atempted_place_pos: Vec2,
) -> (did_place: bool, atempts_left: u8)

// Called when a player interacts with a map interactable
MapInteractableOnInteract :: #type  proc(
    interacted_player_dat: ^Player,
    map_data: ^Map
)

// Loader
MemeMayhemEngine :: struct {

    _handle: dynlib.Library
}


ENGINE_SHARED_LIB_PATH :: "Engine." + dynlib.LIBRARY_FILE_EXTENSION

// Mods are stored in the mods folder so we need to look one dir up
MOD_ENGINE_SHARED_LIB_PATH :: "../Engine." + dynlib.LIBRARY_FILE_EXTENSION


LoadMemeMayhemEngine :: proc(symbol_table: ^MemeMayhemEngine, is_mod: bool = true) {
    engine_lib_path := is_mod ? MOD_ENGINE_SHARED_LIB_PATH : ENGINE_SHARED_LIB_PATH

    count, ok := dynlib.initialize_symbols(symbol_table, engine_lib_path)
    if !ok {
        fmt.panicf("Error loading: %s\nStoped with count: %d\nLoader Error: %s", ENGINE_SHARED_LIB_PATH, count, dynlib.last_error())
    }
}