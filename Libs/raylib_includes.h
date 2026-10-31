#ifndef MEME_MAYHEM_LIBS_RAYLIB_INCLUDES_H
#define MEME_MAYHEM_LIBS_RAYLIB_INCLUDES_H

#include "../Common/include/memory_manager.h"

#ifndef NDEBUG
#define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT 1
#define RLGL_SHOW_GL_DETAILS_INFO 1
#endif

#define RL_MALLOC(sz) _RAYLIB_Allocate(sz)
#define RL_CALLOC(n, sz) _RAYLIB_ContiguousAllocation(n, sz)
#define RL_REALLOC(ptr, sz) _RAYLIB_Reallocate(ptr, sz)
#define RL_FREE(ptr) _RAYLIB_Free(ptr)

#define RAYMATH_USE_SIMD_INTRINSICS 1

#include "raylib/src/config.h"
#include "raylib/src/raylib.h"
#include "raylib/src/raymath.h"
#include "raylib/src/rlgl.h"


#endif // MEME_MAYHEM_LIBS_RAYLIB_INCLUDES_H
