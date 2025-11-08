package Engine

import "core:math/rand"
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


LoadWeapons :: proc() -> []WeaponData {
    file_path := strings.join(
        {"Assets", filepath.SEPARATOR_STRING, "WEAPON_DAT.json"},
        "",
        context.temp_allocator
    )
    data, ok := os.read_entire_file(file_path)
    if !ok {
        Critical(
            "MEME_MAYHEM.FILE_LOADER.LOAD_WEAPONS",
            "Failed to load weapon data from file: \'%s\'. Ensure the file exists and is located in the correct directory.",
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
    defer delete(weapons)

    for item in arr {
        obj := item.(json.Object)
        weapon: WeaponData
        weapon.name = obj["NAME"].(json.String)
        weapon.type = WeaponTypeFromString(obj["TYPE"].(json.String))
        weapon.reload_time = clamp(obj["RELOAD_TIME"].(json.Integer), -1, 9223372036854775807)
        weapon.ammo = cast(u64)obj["AMMO"].(json.Integer)
        weapon.base_damage = obj["BASE_DAMAGE"].(json.Integer)
        weapon.head_shot_damage = obj["HEAD_SHOT_DAMAGE"].(json.Integer)
        weapon.range = clamp(cast(u16)obj["RANGE"].(json.Integer), 1, 65535)
        weapon.is_one_use = obj["IS_ONE_USE"].(json.Boolean)
        Debug("MEME_MAYHEM.FILE_LOADER.LOAD_WEAPONS", "Loaded Weapon: %v", weapon)
        append(&weapons, weapon)
    }
    return weapons[:]
}

