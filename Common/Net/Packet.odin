package Net

/*
NOTE(A-Boring-Square):
Handshake → assets → gameplay.
If it explodes, it explodes.
*/

// -----------------------------
// IMPORTS
// -----------------------------

import "core:encoding/uuid"
import "core:encoding/cbor"
import "../../Magma/Types"
import "../../Magma/Util"

// -----------------------------
// PACKET KINDS
// -----------------------------

PacketKind :: enum u8 {
    CONNECT_REQUEST,
    CONNECT_RESPONSE,
    ASSET_BUNDLE,

    POS_UPDATE,
    MAP_PLAYER_POS_UPDATE,

    SHOT,
    SHOT_RESPONSE,
}

// -----------------------------
// HANDSHAKE
// -----------------------------

ConnectRequest :: struct #packed {
    player_name: string,
    skin_id: u8, // maps to Game.PlayerSkinID
}

ConnectResponse :: struct #packed {
    accepted: b8,
    player_id: uuid.Identifier,
}

// -----------------------------
// ASSETS
// -----------------------------
// Raw image bundle
// key = asset name
// value = compressed 16x16 image bytes

AssetBundle :: struct #packed {
    assets: map[string][]u8,
}

// -----------------------------
// GAMEPLAY
// -----------------------------

PosUpdate :: struct #packed {
    player_id: uuid.Identifier,
    movement: Types.Vector2f,
    rot: f32,
}

MapPlayerPosUpdate :: struct #packed {
    player_id: uuid.Identifier,
    pos: Types.Vector2f,
    rot: f32,
}

Shot :: struct #packed {
    player_id: uuid.Identifier,
    rot: f32,
}

ShotResponse :: struct #packed {
    player_id: uuid.Identifier,
    hit: b8,
    hit_pos: Types.Vector2f,
}

// -----------------------------
// PAYLOAD
// -----------------------------

PacketData :: union {
    ConnectRequest,
    ConnectResponse,
    AssetBundle,

    PosUpdate,
    MapPlayerPosUpdate,

    Shot,
    ShotResponse,
}

// -----------------------------
// FINAL PACKET
// -----------------------------

Packet :: struct #packed {
    kind: PacketKind,
    data: PacketData,
}

// -----------------------------
// ENCODE / DECODE
// -----------------------------

EncodePacket :: proc(packet: Packet) -> []u8 {
    bytes, err := cbor.marshal_into_bytes(packet)
    if err != {} {
        Util.log(.ERROR, "MEME_MAYHEM_NET_PACKET_ENCODE", "%s", err)
        return nil
    }
    return bytes
}

DecodePacket :: proc(bytes: []u8) -> Packet {
    packet: Packet
    err := cbor.unmarshal_from_bytes(bytes, &packet)
    if err != {} {
        Util.log(.ERROR, "MEME_MAYHEM_NET_PACKET_DECODE", "%s", err)
        return {}
    }
    return packet
}
