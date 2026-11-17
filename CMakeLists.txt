cmake_minimum_required(VERSION 3.20)

project(MemeMayhem
    VERSION 0.1.0
    LANGUAGES C
)

set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

# ============================================================
# Build options
# ============================================================

option(MM_BUILD_CLIENT "Build the game client" ON)
option(MM_BUILD_SERVER "Build the game server" ON)

# ============================================================
# Dependency configuration
# ============================================================

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# ============================================================
# raylib
# ============================================================

set(BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(BUILD_GAMES OFF CACHE BOOL "" FORCE)

add_subdirectory(Libs/raylib)

# ============================================================
# ENet
# ============================================================

set(ENET_SOURCES
    Libs/enet/callbacks.c
    Libs/enet/compress.c
    Libs/enet/host.c
    Libs/enet/list.c
    Libs/enet/packet.c
    Libs/enet/peer.c
    Libs/enet/protocol.c
)

if(WIN32)
    list(APPEND ENET_SOURCES
        Libs/enet/win32.c
    )
else()
    list(APPEND ENET_SOURCES
        Libs/enet/unix.c
    )
endif()

add_library(enet STATIC
    ${ENET_SOURCES}
)

target_include_directories(enet PUBLIC
    Libs/enet/include
)

if(WIN32)
    target_link_libraries(enet PUBLIC
        winmm
        ws2_32
    )
elseif(UNIX AND NOT APPLE)
    target_compile_definitions(enet PRIVATE
        _DEFAULT_SOURCE
        _LARGEFILE_SOURCE
    )
endif()

# ============================================================
# miniz
# ============================================================

include(GenerateExportHeader)

add_library(miniz STATIC
    Libs/miniz/miniz.c
    Libs/miniz/miniz_tdef.c
    Libs/miniz/miniz_tinfl.c
    Libs/miniz/miniz_zip.c
)

generate_export_header(miniz
    BASE_NAME miniz
    EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/miniz_export.h"
)

target_include_directories(miniz PUBLIC
    Libs/miniz
    "${CMAKE_CURRENT_BINARY_DIR}"
)

if(UNIX AND NOT APPLE)
    target_compile_definitions(miniz PRIVATE
        _DEFAULT_SOURCE
        _LARGEFILE_SOURCE
    )
endif()

add_library(Common STATIC
    Common/src/asset_system.c
    Common/src/localized_text.c
)

target_include_directories(Common PUBLIC
    Common/include
    Libs
)

target_link_libraries(Common PUBLIC
    enet
    miniz
)

if(MM_BUILD_CLIENT)
    add_executable(Client
        Client/src/main.c
    )

    target_include_directories(Client PRIVATE
        Client/include
        Libs
    )

    target_link_libraries(Client PRIVATE
        Common
        raylib
    )

    target_compile_definitions(Client PRIVATE
        MM_CLIENT
    )
endif()

# ============================================================
# Server
# ============================================================

if(MM_BUILD_SERVER)
    add_executable(Server
        Server/src/main.c
    )

    target_include_directories(Server PRIVATE
        Server/include
        Libs
    )

    target_link_libraries(Server PRIVATE
        Common
    )

    target_compile_definitions(Server PRIVATE
        MM_SERVER
    )
endif()

# ============================================================
# Asset copying
# ============================================================

if(MM_BUILD_CLIENT)
    add_custom_command(TARGET Client POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_SOURCE_DIR}/Assets"
            "$<TARGET_FILE_DIR:Client>/Assets"
    )
endif()