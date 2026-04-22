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

import "core:reflect"

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

BufferWriteString :: proc(data: string, buffer: ^Buffer) {
    
}