package Engine


import "core:os"
import "core:strings"
import "core:path/filepath"
import rl "vendor:raylib"
import "core:encoding/json"



// Helper to convert string to enum
@(private="file")
WeaponTypeFromString :: proc(s: string) -> WeaponType {
    type: WeaponType
    switch s {
    case "AUTOMATIC": type = .AUTOMATIC
    case "SEMIAUTO": type = .SEMIAUTO
    case "MELEE": type = .MELEE
    }
    return type
}

/*
LoadWeapons loads the data for every weapon
and then returns a dynamic array of weapon data
NOTE(A-Boring-Square): caller has to free the array returned
*/
LoadWeapons :: proc() -> [dynamic]WeaponData {
    file_path := strings.join(
        {"Assets", filepath.SEPARATOR_STRING, "WEAPON_DAT.json"},
        "",
        context.temp_allocator
    )

    data, ok := os.read_entire_file(file_path)
    if !ok {
        Critical(
            "MEME_MAYHEM.FILE_LOADER.LOAD_WEAPONS",
            "Failed to load weapon data from file: '%s'. Ensure the file exists and is located in the correct directory.",
            file_path
        )
    }

    free_all(context.temp_allocator)

    val, err := json.parse(data)
    if err != json.Error.None {
        Critical("MEME_MAYHEM.FILE_LOADER.LOAD_WEAPONS", "Failed to parse JSON")
    }

    arr := val.(json.Array)
    weapons := make([dynamic]WeaponData)

    // Helper functions for safe numeric extraction
    get_f64 := proc(value: json.Value) -> (f64, bool) {
        #partial switch v in value {
        case json.Integer: return cast(f64)v, true
        case json.Float:   return v, true
        }
        return 0.0, false
    }

    get_i64 := proc(value: json.Value) -> (i64, bool) {
        #partial switch v in value {
        case json.Integer: return v, true
        case json.Float:   return cast(i64)v, true
        }
        return 0, false
    }

    #no_type_assert for item in arr {


        obj := item.(json.Object)
        weapon: WeaponData

        // Strings
        if s, ok := obj["NAME"].(json.String); ok { weapon.name = s } else { weapon.name = "<unknown>" }
        if t, ok := obj["TYPE"].(json.String); ok { weapon.type = WeaponTypeFromString(t) } else { weapon.type = WeaponTypeFromString("UNKNOWN") }

        // reload_time (float)
        if rt, ok := get_f64(obj["RELOAD_TIME"]); ok { weapon.reload_time = rt } else { weapon.reload_time = -1.0 }

        // ammo, base_damage, head_shot_damage, range (i64)
        if v, ok := get_i64(obj["AMMO"]); ok { weapon.ammo = v } else { weapon.ammo = 0 }
        if v, ok := get_i64(obj["BASE_DAMAGE"]); ok { weapon.base_damage = v } else { weapon.base_damage = 0 }
        if v, ok := get_i64(obj["HEAD_SHOT_DAMAGE"]); ok { weapon.head_shot_damage = v } else { weapon.head_shot_damage = 0 }
        if v, ok := get_i64(obj["RANGE"]); ok { weapon.range = v } else { weapon.range = 1 }

        // boolean
        if b, ok := obj["IS_ONE_USE"].(json.Boolean); ok { weapon.is_one_use = b } else { weapon.is_one_use = false }

        Debug("MEME_MAYHEM.FILE_LOADER.LOAD_WEAPONS", "Loaded Weapon: %v", weapon)
        append(&weapons, weapon)
    }

    return weapons
}
