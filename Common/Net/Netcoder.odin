/*
HyperSonic Games Non-Commercial Source License (HSG-NCSL)
Copyright (c) 2025 HyperSonic-Games

This license governs the use, modification, and distribution of [PROJECT NAME]
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
  - Mods must clearly indicate they are based on [PROJECT NAME].
  - Mods must not imply official endorsement or affiliation with HyperSonic-Games.
  - All contributions must include proper attribution to [OWNER NAME],
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

import "core:strings"
import "core:slice"

import "../../Magma/Util"


Buffer :: [dynamic]u8

InitBuffer :: proc() -> Buffer {
    return make(Buffer)
}

ClearBuffer :: proc(buffer: ^Buffer) {
    clear(buffer)
}

DestroyBuffer :: proc(buffer: ^Buffer) {
    delete(buffer^)
}

BufferWritei8 :: proc(data: i8, buffer: ^Buffer) {
    append(buffer, transmute(u8)data)
}

BufferWriteu8 :: proc(data: u8, buffer: ^Buffer) {
    append(buffer, data)
}

BufferWritei16 :: proc(data: i16le, buffer: ^Buffer) {
    dat := transmute([2]u8)data
    append(buffer, dat[0])
    append(buffer, dat[1])
}

BufferWriteu16 :: proc(data: u16le, buffer: ^Buffer) {
    dat := transmute([2]u8)data
    append(buffer, dat[0])
    append(buffer, dat[1])
}

BufferWritei32 :: proc(data: i32le, buffer: ^Buffer) {
    dat := transmute([4]u8)data
    append(buffer, dat[0])
    append(buffer, dat[1])
    append(buffer, dat[2])
    append(buffer, dat[3])
}

BufferWriteu32 :: proc(data: u32le, buffer: ^Buffer) {
    dat := transmute([4]u8)data
    append(buffer, dat[0])
    append(buffer, dat[1])
    append(buffer, dat[2])
    append(buffer, dat[3])
}

BufferWritei64 :: proc(data: i64le, buffer: ^Buffer) {
    dat := transmute([8]u8)data
    append(buffer, dat[0])
    append(buffer, dat[1])
    append(buffer, dat[2])
    append(buffer, dat[3])
    append(buffer, dat[4])
    append(buffer, dat[5])
    append(buffer, dat[6])
    append(buffer, dat[7])
}

BufferWriteu64 :: proc(data: u64le, buffer: ^Buffer) {
    dat := transmute([8]u8)data
    append(buffer, dat[0])
    append(buffer, dat[1])
    append(buffer, dat[2])
    append(buffer, dat[3])
    append(buffer, dat[4])
    append(buffer, dat[5])
    append(buffer, dat[6])
    append(buffer, dat[7])
}

BufferWritef32 :: proc(data: f32le, buffer: ^Buffer) {
    dat := transmute([4]u8)data
    append(buffer, dat[0])
    append(buffer, dat[1])
    append(buffer, dat[2])
    append(buffer, dat[3])
}

BufferWritef64 :: proc(data: f64le, buffer: ^Buffer) {
    dat := transmute([8]u8)data
    append(buffer, dat[0])
    append(buffer, dat[1])
    append(buffer, dat[2])
    append(buffer, dat[3])
    append(buffer, dat[4])
    append(buffer, dat[5])
    append(buffer, dat[6])
    append(buffer, dat[7])
}

BufferWriteBool :: proc(data: b8, buffer: ^Buffer) {
    dat := transmute(u8)data
    append(buffer, dat)
}

/*
NOTE(A-Boring-Square):
strings are a pain in the ass
as we encode them as `[string data][len]`
and decode them as `[len][string data]`
*/
BufferWriteString :: proc(data: string, buffer: ^Buffer) {
    bytes := transmute([]u8)data

    // write data 
    // NOTE: this is reversed
    for b in bytes {
        append(buffer, b)
    }

    // then write the length at the end
    BufferWriteu64(cast(u64le)len(bytes), buffer)
}

BufferWriteBytes :: proc(data: []u8, buffer: ^Buffer) {
    for b in data {
        BufferWriteu8(b, buffer)
    }
}


BufferWrite :: proc {
    BufferWritei8,
    BufferWriteu8,
    BufferWritei16,
    BufferWriteu16,
    BufferWritei32,
    BufferWriteu32,
    BufferWritei64,
    BufferWriteu64,
    BufferWritef32,
    BufferWritef64,
    BufferWriteBool,
    BufferWriteString,
    BufferWriteBytes,
}


BufferReadi8 :: proc(buffer: ^Buffer) -> i8 {
    return cast(i8)pop(buffer)
}

BufferReadu8 :: proc(buffer: ^Buffer) -> u8 {
    return pop(buffer)
}

BufferReadi16 :: proc(buffer: ^Buffer) -> i16le {
    dat: [2]u8

    dat[1] = pop(buffer)
    dat[0] = pop(buffer)

    return transmute(i16le)dat
}

BufferReadu16 :: proc(buffer: ^Buffer) -> u16le {
    dat: [2]u8
    
    dat[1] = pop(buffer)
    dat[0] = pop(buffer)
    
    return transmute(u16le)dat
}

BufferReadi32 :: proc(buffer: ^Buffer) -> i32le {
    dat: [4]u8

    dat[3] = pop(buffer)
    dat[2] = pop(buffer)
    dat[1] = pop(buffer)
    dat[0] = pop(buffer)

    return transmute(i32le)dat
}

BufferReadu32 :: proc(buffer: ^Buffer) -> u32le {
    dat: [4]u8

    dat[3] = pop(buffer)
    dat[2] = pop(buffer)
    dat[1] = pop(buffer)
    dat[0] = pop(buffer)

    return transmute(u32le)dat
}

BufferReadi64 :: proc(buffer: ^Buffer) -> i64le {
    dat: [8]u8

    dat[7] = pop(buffer)
    dat[6] = pop(buffer)
    dat[5] = pop(buffer)
    dat[4] = pop(buffer)
    dat[3] = pop(buffer)
    dat[2] = pop(buffer)
    dat[1] = pop(buffer)
    dat[0] = pop(buffer)

    return transmute(i64le)dat
}

BufferReadu64 :: proc(buffer: ^Buffer) -> u64le {
    dat: [8]u8

    dat[7] = pop(buffer)
    dat[6] = pop(buffer)
    dat[5] = pop(buffer)
    dat[4] = pop(buffer)
    dat[3] = pop(buffer)
    dat[2] = pop(buffer)
    dat[1] = pop(buffer)
    dat[0] = pop(buffer)

    return transmute(u64le)dat
}

BufferReadf32 :: proc(buffer: ^Buffer) -> f32le {
    dat: [4]u8

    dat[3] = pop(buffer)
    dat[2] = pop(buffer)
    dat[1] = pop(buffer)
    dat[0] = pop(buffer)
    
    return transmute(f32le)dat
}

BufferReadf64 :: proc(buffer: ^Buffer) -> f64le {
    dat: [8]u8

    dat[7] = pop(buffer)
    dat[6] = pop(buffer)
    dat[5] = pop(buffer)
    dat[4] = pop(buffer)
    dat[3] = pop(buffer)
    dat[2] = pop(buffer)
    dat[1] = pop(buffer)
    dat[0] = pop(buffer)

    return transmute(f64le)dat
}

BufferReadBool :: proc(buffer: ^Buffer) -> b8 {
    return transmute(b8)pop(buffer)
}

/*
NOTE(A-Boring-Square):
this keeps any data already in the `string_buffer` intact
why you would want this idk but i bet some random modder
is going to be like OMG they have this built in

The returned string is allocated to the heap and must be freed by the caller
*/
BufferReadString :: proc(buffer: ^Buffer, string_buffer: ^[dynamic]u8, allocator := context.allocator) -> string {
    length: u64le = BufferReadu64(buffer)

    start := cast(u64le)len(string_buffer)

    for i: u64le = 0; i < length; i += 1 {
        append(string_buffer, pop(buffer))
    }

    slice.reverse(string_buffer[start:start+length])

    return strings.clone(cast(string)string_buffer[start:start+length], allocator)
}

// The returned buffer is the same length as you passed in and is allocated on the heap
BufferReadBytes :: proc(length: int, buffer: ^Buffer, allocator := context.allocator) -> [^]u8 {
    data := make([^]u8, length, allocator)

    for i in 0..<length {
        data[length - 1 - i] = BufferReadu8(buffer)
    }

    return data
}


/*
MODDERS INFO - NETWORK SERIALIZATION RULES

This file defines the binary encoding/decoding rules for ALL messages in ANY_MESSAGE.

IMPORTANT: This system uses a FILO (stack-based) buffer.

--------------------------------------------------------------------
1. BUFFER MODEL (CRITICAL)
--------------------------------------------------------------------
- BufferWrite() PUSHES values onto a stack
- BufferRead*() POPS values from a stack
- There is NO streaming / FIFO behavior
- Everything is stack ordered

This means:
  LAST WRITTEN = FIRST READ

--------------------------------------------------------------------
3. FIELD ORDER RULES (MOST IMPORTANT RULE)
--------------------------------------------------------------------
For every struct:

ENCODE RULE:
  - Write fields in REVERSE order of struct definition
  - Because buffer is FILO (stack push)

DECODE RULE:
  - Read fields in REVERSE order of encoding
  - Because buffer is FILO (stack pop)

If field order is wrong → data is silently corrupted.

--------------------------------------------------------------------
4. VARIABLE LENGTH DATA (LEN + DATA PAIR RULE)
--------------------------------------------------------------------

ALL dynamic data MUST follow this strict rule:

ENCODE:
  1. Write DATA first
  2. Write LENGTH second

DECODE:
  1. Read LENGTH first (it was pushed last)
  2. Allocate memory using LENGTH
  3. Read DATA second

Example:

ENCODE:
  BufferWrite(data)
  BufferWrite(len)

DECODE:
  len  = BufferRead*()
  data = BufferReadBytes(len)

--------------------------------------------------------------------
5. FIXED ARRAYS (e.g UUID)
--------------------------------------------------------------------
- Must be written element-by-element
- Must be read in reverse element order due to stack behavior

Example:
ENCODE:
  for i in data:
      BufferWrite(i)

DECODE:
  for i from end -> start:
      BufferRead()

--------------------------------------------------------------------
6. HOW TO ADD A NEW MESSAGE TYPE
--------------------------------------------------------------------

STEP 1: Define struct

STEP 2: Create encoder
  BufferEncode_<NAME>

  RULES:
    - Write fields in REVERSE struct order
    - Apply LEN/DATA rule for slices/strings
    - No assumptions about FIFO streams

STEP 3: Create decoder
  BufferDecode_<NAME>

  RULES:
    - Read fields in reverse order of encoder
    - Allocate variable-length fields using popped length
    - Reverse-read fixed arrays

STEP 4: Register usage manually in network logic

--------------------------------------------------------------------
7. SAFETY MODEL
--------------------------------------------------------------------
- No bounds checking is performed
- No validation of buffer contents exists
- Corrupt input WILL desync decoding
- Encode/Decode symmetry is entirely manual responsibility

--------------------------------------------------------------------
8. FORBIDDEN PRACTICES
--------------------------------------------------------------------
- Do NOT reorder existing struct fields
- Do NOT assume FIFO serialization semantics
- Do NOT mix streaming assumptions with stack buffer
- Do NOT forget to free the multi pointer inside the struct before freeing the struct (if used)

--------------------------------------------------------------------
9. DESIGN INTENT
--------------------------------------------------------------------
This system is intentionally deterministic and low-level:
- Zero metadata overhead
- Zero runtime dispatch
- Maximum performance via stack operations
- Strict symmetry requirement between encode/decode

Any deviation breaks protocol correctness.
*/
_ :: 0 // Comment seperator

@(private)
BufferEncode_CLIENT_HELLO_MSG :: proc(msg: CLIENT_HELLO_MSG, buffer: ^Buffer) {
    for i in msg.player_id {
        BufferWrite(i, buffer)
    }

    BufferWrite(slice.from_ptr(msg.player_name, cast(int)msg.player_name_len), buffer)
    BufferWrite(msg.player_name_len, buffer)


    BufferWrite(msg.protocol_version, buffer)

    for i: int = 0; i < 3; i += 1 {
        BufferWrite(msg.engine_version[i], buffer)
    }
}

@(private)
BufferDecode_CLIENT_HELLO_MSG :: proc(
    buffer: ^Buffer,
    allocator := context.allocator
) -> ^CLIENT_HELLO_MSG {

    msg := new(CLIENT_HELLO_MSG, allocator)

    for i: int = 0; i < 3; i += 1 {
        msg.engine_version[i] = BufferReadu32(buffer)
    }

    msg.protocol_version = BufferReadu16(buffer)

    msg.player_name_len = BufferReadu16(buffer)

    name_bytes := BufferReadBytes(cast(int)msg.player_name_len, buffer, allocator)
    msg.player_name = name_bytes

    for i := len(msg.player_id) - 1; i >= 0; i -= 1 {
        msg.player_id[i] = BufferReadu8(buffer)
    }

    return msg
}



BufferEncode_SERVER_HELLO_MSG :: proc(msg: SERVER_HELLO_MSG, buffer: ^Buffer) {
    BufferWrite(cast(b8)msg.ack, buffer)
    BufferWrite(slice.from_ptr(msg.reason, cast(int)msg.reason_len), buffer)
    BufferWrite(msg.reason_len, buffer)
}

BufferDecode_SERVER_HELLO_MSG :: proc(
    buffer: ^Buffer,
    allocator := context.allocator
) -> ^SERVER_HELLO_MSG {
    
    msg := new(SERVER_HELLO_MSG, allocator)
    
    msg.reason_len = BufferReadu16(buffer)
    msg.reason = BufferReadBytes(cast(int)msg.reason_len, buffer, allocator)
    msg.ack = cast(bool)BufferReadBool(buffer)
    return msg
}


BufferEncode_CLIENT_PING_MSG :: proc(msg: CLIENT_PING_MSG, buffer: ^Buffer) {
    BufferWrite(msg.sequence_id, buffer)
    BufferWrite(msg.client_time_ms, buffer)
}

BufferDecode_CLIENT_PING_MSG :: proc(buffer: ^Buffer) -> ^CLIENT_PING_MSG {
    msg := new(CLIENT_PING_MSG)
    msg.client_time_ms = BufferReadu64(buffer)
    msg.sequence_id = BufferReadu32(buffer)
    return msg
}



BufferEncode_SERVER_PONG_MSG :: proc(msg: SERVER_PONG_MSG, buffer: ^Buffer) {

    BufferWrite(msg.client_time_ms, buffer)
    BufferWrite(msg.server_time_ms, buffer)
    BufferWrite(msg.sequence_id, buffer)
}

BufferDecode_SERVER_PONG_MSG :: proc(buffer: ^Buffer, allocator := context.allocator) -> ^SERVER_PONG_MSG {
    msg := new(SERVER_PONG_MSG)
    msg.sequence_id = BufferReadu32(buffer)
    msg.server_time_ms = BufferReadu64(buffer)
    msg.client_time_ms = BufferReadu64(buffer)

    return msg
}



BufferEncode_CLIENT_INPUT_MSG :: proc(msg: CLIENT_INPUT_MSG, buffer: ^Buffer) {
    BufferWrite(msg.requested_pos_change_x, buffer)
    BufferWrite(msg.requested_pos_change_y, buffer)
    BufferWrite(msg.requested_rot_change, buffer)
}

BufferDecode_CLIENT_INPUT_MSG :: proc(buffer: ^Buffer, allocator := context.allocator) -> ^CLIENT_INPUT_MSG {
    msg := new(CLIENT_INPUT_MSG)
    msg.requested_rot_change = BufferReadf32(buffer)
    msg.requested_pos_change_y = BufferReadf32(buffer)
    msg.requested_pos_change_x = BufferReadf32(buffer)
    return msg
}


BufferEncode_SERVER_EVENT_SPAWN_MSG :: proc(msg: SERVER_EVENT_SPAWN_MSG, buffer: ^Buffer) {
    if msg.player_name_len != 0 {
        BufferWrite(slice.from_ptr(msg.player_name, cast(int)msg.player_name_len), buffer)
    }
    BufferWrite(msg.player_name_len, buffer)
    BufferWrite(msg.pos_x, buffer)
    BufferWrite(msg.pos_y, buffer)
    BufferWrite(msg.rot, buffer)
    BufferWrite(msg.texture_id, buffer)
    if msg.is_player {
        for i: int = 0; i < 16; i += 1 {
            BufferWrite(msg.player_id[i], buffer)
        }
    }
    BufferWrite(cast(b8)msg.is_player, buffer)
}

BufferDecode_SERVER_EVENT_SPAWN_MSG :: proc(buffer: ^Buffer, allocator := context.allocator) -> ^SERVER_EVENT_SPAWN_MSG {
    msg := new(SERVER_EVENT_SPAWN_MSG)
    msg.is_player = cast(bool)BufferReadBool(buffer)

    if msg.is_player {
        for i := len(msg.player_id) - 1; i >= 0; i -= 1 {
            msg.player_id[i] = BufferReadu8(buffer)
        }
    }
    else {
        msg.player_id = {}
    }
    msg.texture_id = BufferReadu16(buffer)

    return msg
}

BufferEncode_SERVER_EVENT_DESPAWN_MSG :: proc(msg: SERVER_EVENT_DESPAWN_MSG, buffer: ^Buffer) {
    if msg.is_player {
        for i: int = 0; i < 16; i += 1 {
            BufferWrite(msg.player_id[i], buffer)
        }
        BufferWrite(msg.pos_x, buffer)
        BufferWrite(msg.pos_y, buffer)
        BufferWrite(msg.rot, buffer)
        BufferWrite(cast(b8)msg.is_player, buffer)
    }
}

BufferDecode_SERVER_EVENT_DESPAWN_MSG :: proc(buffer: ^Buffer) -> ^SERVER_EVENT_DESPAWN_MSG {
    msg := new(SERVER_EVENT_DESPAWN_MSG)
    msg.is_player = cast(bool)BufferReadBool(buffer)
    msg.rot = BufferReadf32(buffer)
    msg.pos_y = BufferReadf32(buffer)
    msg.pos_x = BufferReadf32(buffer)
    if msg.is_player {
        for i: int = len(msg.player_id) - 1; i >= 0; i -= 1 {
            msg.player_id[i] = BufferReadu8(buffer)
        }
    }
    else {
        msg.player_id = {}
    }
    return msg
}




// NOTE(A-Boring-Square): THE MESSAGE MUST BE A NON POINTER VARIANT
EncodeMessage :: proc(msg: ANY_MESSAGE, buffer: ^Buffer) {

    #partial switch v in msg {
        case CLIENT_HELLO_MSG:
            BufferEncode_CLIENT_HELLO_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.CLIENT_HELLO, buffer)

        case SERVER_HELLO_MSG:
            BufferEncode_SERVER_HELLO_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_HELLO, buffer)

        case CLIENT_PING_MSG:
            BufferEncode_CLIENT_PING_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.CLIENT_PING, buffer)

        case SERVER_PONG_MSG:
            BufferEncode_SERVER_PONG_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_PONG, buffer)

        case CLIENT_INPUT_MSG:
            BufferEncode_CLIENT_INPUT_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.CLIENT_INPUT, buffer)

        case SERVER_EVENT_SPAWN_MSG:
            BufferEncode_SERVER_EVENT_SPAWN_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_EVENT_SPAWN, buffer)

        case SERVER_EVENT_DESPAWN_MSG:
            BufferEncode_SERVER_EVENT_DESPAWN_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_EVENT_DESPAWN, buffer)

        case SERVER_EVENT_TILE_CHANGE_MSG:
            BufferEncode_SERVER_EVENT_TILE_CHANGE_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_EVENT_TILE_CHANGE, buffer)

        case SERVER_EVENT_PLAYER_POS_CHANGE_MSG:
            BufferEncode_SERVER_EVENT_PLAYER_POS_CHANGE_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_EVENT_PLAYER_POS_CHANGE, buffer)

        case SERVER_EVENT_DAMAGE_DEALT_MSG:
            BufferEncode_SERVER_EVENT_DAMAGE_DEALT_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_EVENT_DAMAGE_DEALT, buffer)

        case SERVER_MAP_BEGIN_MSG:
            BufferEncode_SERVER_MAP_BEGIN_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_MAP_BEGIN, buffer)

        case SERVER_MAP_REGION_CHUNK_MSG:
            BufferEncode_SERVER_MAP_REGION_CHUNK_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_MAP_REGION_CHUNK, buffer)

        case SERVER_MAP_END_MSG:
            BufferEncode_SERVER_MAP_END_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_MAP_END, buffer)

        case SERVER_ASSET_BEGIN_MSG:
            BufferEncode_SERVER_ASSET_BEGIN_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_ASSET_BEGIN, buffer)

        case SERVER_ASSET_MSG:
            BufferEncode_SERVER_ASSET_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_ASSET, buffer)

        case CLIENT_ASSET_ACK_MSG:
            BufferEncode_CLIENT_ASSET_ACK_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.CLIENT_ASSET_ACK, buffer)

        case SERVER_ASSET_END_MSG:
            BufferEncode_SERVER_ASSET_END_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_ASSET_END, buffer)

        case SERVER_WEAPON_INFO_BEGIN_MSG:
            BufferEncode_SERVER_WEAPON_INFO_BEGIN_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_WEAPON_INFO_BEGIN, buffer)

        case SERVER_WEAPON_INFO_MSG:
            BufferEncode_SERVER_WEAPON_INFO_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_WEAPON_INFO, buffer)

        case CLIENT_WEAPON_INFO_ACK_MSG:
            BufferEncode_CLIENT_WEAPON_INFO_ACK_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.CLIENT_WEAPON_INFO_ACK, buffer)

        case SERVER_WEAPON_INFO_END_MSG:
            BufferEncode_SERVER_WEAPON_INFO_END_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_WEAPON_INFO_END, buffer)

        case SERVER_ERROR_MSG:
            BufferEncode_SERVER_ERROR_MSG(v, buffer)
            BufferWriteu16(cast(u16le)MessageType.SERVER_ERROR, buffer)
        
        case :
            Util.Log(
                .ERROR,
                "MEME_MAYHEM",
                "COMMON_NET_NETCODER_ENCODE_MESSAGE",
                "Expected a message not a message pointer"
            )
    }
}



DecodeMessage :: proc(buffer: ^Buffer, allocator := context.allocator) -> ANY_MESSAGE {
    tag := BufferReadu16(buffer)

    switch cast(Messagetype)tag {
        case .CLIENT_HELLO:
            return BufferDecode_CLIENT_HELLO_MSG(buffer, allocator)

        case .SERVER_HELLO:
            return BufferDecode_SERVER_HELLO_MSG(buffer, allocator)

        case .CLIENT_PING:
            return BufferDecode_CLIENT_PING_MSG(buffer, allocator)

        case .SERVER_PONG:
            return BufferDecode_SERVER_PONG_MSG(buffer, allocator)

        case .CLIENT_INPUT:
            return BufferDecode_CLIENT_INPUT_MSG(buffer, allocator)

        case .SERVER_EVENT_SPAWN:
            return BufferDecode_SERVER_EVENT_SPAWN_MSG(buffer, allocator)

        case .SERVER_EVENT_DESPAWN:
            return BufferDecode_SERVER_EVENT_DESPAWN_MSG(buffer, allocator)

        case .SERVER_EVENT_TILE_CHANGE:
            return BufferDecode_SERVER_EVENT_TILE_CHANGE_MSG(buffer, allocator)

        case .SERVER_EVENT_PLAYER_POS_CHANGE:
            return BufferDecode_SERVER_EVENT_PLAYER_POS_CHANGE_MSG(buffer, allocator)

        case .SERVER_EVENT_DAMAGE_DEALT:
            return BufferDecode_SERVER_EVENT_DAMAGE_DEALT_MSG(buffer, allocator)

        case .SERVER_MAP_BEGIN:
            return BufferDecode_SERVER_MAP_BEGIN_MSG(buffer, allocator)

        case .SERVER_MAP_REGION_CHUNK:
            return BufferDecode_SERVER_MAP_REGION_CHUNK_MSG(buffer, allocator)

        case .SERVER_MAP_END:
            return BufferDecode_SERVER_MAP_END_MSG(buffer, allocator)

        case .SERVER_ASSET_BEGIN:
            return BufferDecode_SERVER_ASSET_BEGIN_MSG(buffer, allocator)

        case .SERVER_ASSET:
            return BufferDecode_SERVER_ASSET_MSG(buffer, allocator)

        case .CLIENT_ASSET_ACK:
            return BufferDecode_CLIENT_ASSET_ACK_MSG(buffer, allocator)

        case .SERVER_ASSET_END:
            return BufferDecode_SERVER_ASSET_END_MSG(buffer, allocator)

        case .SERVER_WEAPON_INFO_BEGIN:
            return BufferDecode_SERVER_WEAPON_INFO_BEGIN_MSG(buffer, allocator)

        case .SERVER_WEAPON_INFO:
            return BufferDecode_SERVER_WEAPON_INFO_MSG(buffer, allocator)

        case .CLIENT_WEAPON_INFO_ACK:
            return BufferDecode_CLIENT_WEAPON_INFO_ACK_MSG(buffer, allocator)

        case .SERVER_WEAPON_INFO_END:
            return BufferDecode_SERVER_WEAPON_INFO_END_MSG(buffer, allocator)

        case .SERVER_ERROR:
            return BufferDecode_SERVER_ERROR_MSG(buffer, allocator)

        case:
            panic("Invalid message tag")
    }
}