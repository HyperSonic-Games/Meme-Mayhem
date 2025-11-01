package Engine

import "core:simd"
import "base:runtime"


// SIMD Emulation check
@init
CheckSIMDEmulation :: proc() {
    when runtime.HAS_HARDWARE_SIMD {
        Log(.Info, "SIMD is currently supported")
    } else {
        Log(.Warn, "SIMD emulation mode active performance on this platfrom could suffer")
    }
}


@(export)
Vec2GetRawData :: proc(vector: ^Vec2) -> [2]f64 {
    return simd.to_array(vector^)
}