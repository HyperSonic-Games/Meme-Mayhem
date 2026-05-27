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
package Net

import "core:encoding/uuid"

/*
NOTE(A-Boring-Square):
You may notice that asset ids are u16 while all the count felds are u32
this is so in the future we can increase the id max to u32 if needed
*/

_ :: 0 // for comment


CLIENT_HELLO_MSG :: struct {
    player_id: uuid.Identifier,

    player_name_len: u16le,
    player_name: [^]u8,
    protocol_version: u16le,
    engine_version: [3]u32le,
}

SERVER_HELLO_MSG :: struct {
    ack: bool,

    reason_len: u16le,
    reason: [^]u8,
}

CLIENT_PING_MSG :: struct {
    client_time_ms: u64le,
    sequence_id: u32le,
}

SERVER_PONG_MSG :: struct {
    client_time_ms: u64le,
    server_time_ms: u64le,
    sequence_id: u32le,
}

CLIENT_INPUT_MSG :: struct {
    requested_pos_change_x: f32le,
    requested_pos_change_y: f32le,
    requested_rot_change: f32le,
}

SERVER_EVENT_SPAWN_MSG :: struct {
    is_player: bool, // If false it is an object like health, ammo or guns
    player_id: uuid.Identifier, // this will be nil if not a player
    player_name_len: u16le, // this is 0 if not a player
    player_name: [^]u8, // this will be nil if not a player
    pos_x: f32le,
    pos_y: f32le,
    rot: f32le,
    texture_id: u16le,
}

/*
NOTE(A-Boring-Square):
we just give data.
The Client will figure out how to remove the object/player and how to clean up
*/
SERVER_EVENT_DESPAWN_MSG :: struct {
    is_player: bool, // If false it is an object like health, ammo or guns
    player_id: uuid.Identifier,
    pos_x: f32le,
    pos_y: f32le,
    rot: f32le,
}

SERVER_EVENT_TILE_CHANGE_MSG :: struct {
    texture_id: u16le,

    tile_grid_x: u32le,
    tile_grid_y: u32le,
}

SERVER_EVENT_PLAYER_POS_CHANGE_MSG :: struct {
    player_id: uuid.Identifier,
    pos_x: f32le,
    pos_y: f32le,
    rot: f32le,
}


/*
NOTE(A-Boring-Square):
the server will hold and handle all of the data for players like health in the case of this message
this is just to tell the client so it can display info to the user
*/
SERVER_EVENT_DAMAGE_DEALT_MSG :: struct {
    player: uuid.Identifier,
    damage: i8, // clamped between -250 to 250
}

SERVER_MAP_BEGIN_MSG :: struct {
    map_width: u32le,
    map_height: u32le,
}

SERVER_MAP_REGION_CHUNK_MSG :: struct {
    region_x: u32le,
    region_y: u32le,

    tiles_len: u32le,
    tiles: [^]u16le, // row-major
}

SERVER_MAP_END_MSG :: struct {
    ok: bool,
}

SERVER_ASSET_BEGIN_MSG :: struct {
    asset_count: u32le,
}

SERVER_ASSET_MSG :: struct {
    asset_id: u16le, // the id for this texture (server defined the client will just use it as is)
    asset_data_len: u32le,
    asset_data: [^]u8, // this will be encoded via PNG
}

CLIENT_ASSET_ACK_MSG :: struct {
    ok: bool, // if false the server will retry up to 7 times before terminating the conection
}
SERVER_ASSET_END_MSG :: struct {
    asset_count: u32le,
}

SERVER_WEAPON_INFO_BEGIN_MSG :: struct {
    weapon_count: u16le,
}

SERVER_WEAPON_INFO_MSG :: struct {
    weapon_id: u16le,
    texture_id: u16le,
    name: [^]u8,
    name_len: u16le,
}

CLIENT_WEAPON_INFO_ACK_MSG :: struct {
    ok: bool,
}

SERVER_WEAPON_INFO_END_MSG :: struct {
    weapon_count: u16le,
}

SERVER_ERROR_MSG :: struct {
    is_critical: bool, // if true the client should disconect imediatly
    reason: [^]u8,
    reason_len: u16le,
}

/*
FOR MODDERS:

when adding a new packet make sure to add it to this union

NOTE: This contains both the pointer and normal variant

In most cases Encode expects the normal message and decode will return a pointer variant

WARNING DO NOT EDIT ANYTHING ALREADY IN THIS union AS IT COULD BREAK THINGS
*/
ANY_MESSAGE :: union {
    // MESSAGE POINTERS
    ^CLIENT_HELLO_MSG,
    ^SERVER_HELLO_MSG,
    ^CLIENT_PING_MSG,
    ^SERVER_PONG_MSG,
    ^CLIENT_INPUT_MSG,
    ^SERVER_EVENT_SPAWN_MSG,
    ^SERVER_EVENT_DESPAWN_MSG,
    ^SERVER_EVENT_TILE_CHANGE_MSG,
    ^SERVER_EVENT_PLAYER_POS_CHANGE_MSG,
    ^SERVER_EVENT_DAMAGE_DEALT_MSG,
    ^SERVER_MAP_BEGIN_MSG,
    ^SERVER_MAP_REGION_CHUNK_MSG,
    ^SERVER_MAP_END_MSG,
    ^SERVER_ASSET_BEGIN_MSG,
    ^SERVER_ASSET_MSG,
    ^CLIENT_ASSET_ACK_MSG,
    ^SERVER_ASSET_END_MSG,
    ^SERVER_WEAPON_INFO_BEGIN_MSG,
    ^SERVER_WEAPON_INFO_MSG,
    ^CLIENT_WEAPON_INFO_ACK_MSG,
    ^SERVER_WEAPON_INFO_END_MSG,
    ^SERVER_ERROR_MSG,

    // MESSAGES
    CLIENT_HELLO_MSG,
    SERVER_HELLO_MSG,
    CLIENT_PING_MSG,
    SERVER_PONG_MSG,
    CLIENT_INPUT_MSG,
    SERVER_EVENT_SPAWN_MSG,
    SERVER_EVENT_DESPAWN_MSG,
    SERVER_EVENT_TILE_CHANGE_MSG,
    SERVER_EVENT_PLAYER_POS_CHANGE_MSG,
    SERVER_EVENT_DAMAGE_DEALT_MSG,
    SERVER_MAP_BEGIN_MSG,
    SERVER_MAP_REGION_CHUNK_MSG,
    SERVER_MAP_END_MSG,
    SERVER_ASSET_BEGIN_MSG,
    SERVER_ASSET_MSG,
    CLIENT_ASSET_ACK_MSG,
    SERVER_ASSET_END_MSG,
    SERVER_WEAPON_INFO_BEGIN_MSG,
    SERVER_WEAPON_INFO_MSG,
    CLIENT_WEAPON_INFO_ACK_MSG,
    SERVER_WEAPON_INFO_END_MSG,
    SERVER_ERROR_MSG,
}
