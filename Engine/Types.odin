package Engine

import rl "vendor:raylib"
Vec2 :: [2]f64

WeaponType :: enum {
    AUTOMATIC,
    SEMIAUTO,
    MELEE,
}

Entity :: struct {
    is_player: bool,
    pos: Vec2,
    rot: f32,

}

MapTileType :: enum {
    GROUND,
    WALL
}

MapTile :: struct {
    type: MapTileType,
    grid_pos_x: u32,
    grid_pos_y: u32,
    texture: ^rl.Image
}


MapObject :: struct {
    pos: Vec2,
    rot: f32,
    textures: ^rl.Image, // NOTE: for animations replace the image then set it back
}

Map :: struct {
    tiles: []MapTile,
    objects: [dynamic]MapObject,
    entitys: [dynamic]Entity
}


EngineContext :: struct {
    current_map: ^Map,
    wave_number: u16,
    wave_dificulty_mult: u32,
}