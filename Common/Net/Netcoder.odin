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


Buffer :: [dynamic]u8

InitBuffer :: proc() -> Buffer {
    return make(Buffer)
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
    BufferWriteString
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
why you would want this idk but i bet some random moder
is going to be like OMG they have this built in
*/
BufferReadString :: proc(buffer: ^Buffer, string_buffer: ^[dynamic]u8, allocator := context.allocator) -> string {
    length := int(BufferReadu64(buffer))

    start := len(string_buffer)

    for i := 0; i < length; i += 1 {
        append(string_buffer, pop(buffer))
    }

    slice.reverse(string_buffer[start:start+length])

    return strings.clone(cast(string)string_buffer[start:start+length], allocator)
}