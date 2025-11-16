package Engine

import rl "vendor:raylib"

Vec2 :: [2]f32

WeaponType :: enum {
    AUTOMATIC,
    SEMIAUTO,
    MELEE,
}

WeaponData :: struct {
    name: string,
    type: WeaponType,
    reload_time: f64,
    ammo: i64,
    base_damage: i64,
    head_shot_damage: i64,
    range: i64,
    is_one_use: bool,
} 


Entity :: struct {
    is_player: bool,
    pos: Vec2,
    rot: f32,
    texture: rl.Texture

}

MapTileType :: enum {
    GROUND,
    WALL
}

MapTile :: struct {
    type: MapTileType,
    grid_pos_x: u32,
    grid_pos_y: u32,
    texture: rl.Texture
}


MapObject :: struct {
    pos: Vec2,
    rot: f32,
    textures: rl.Texture, // NOTE: for animations replace the image then set it back
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