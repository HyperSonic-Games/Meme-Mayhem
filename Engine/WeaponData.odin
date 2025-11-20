package Engine

//
// ======================= MODDING GUIDE =======================
//
//  HOW WEAPON FILES WORK:
//
//  • Each weapon MUST have a matching image in:
//        Assets/Images/Weapons/<WEAPON_NAME>.png
//    The file name (no extension) must match the `name` field EXACTLY.
//
//  • Each weapon MAY have a firing sound in:
//        Assets/Audio/Weapons/<WEAPON_NAME>.mp3
//    If present, the engine loads it automatically.
//
//  • To add a new weapon:
//       1. Copy any struct below.
//       2. Adjust stats (damage, ammo, reload_time, rarity, etc).
//       3. Ensure the `name` matches your .png (and optional .mp3).
//       4. Add an entry to WeaponDATABASE.
//
//  • rarity_percentage:
//       0–100, controls how frequently the weapon appears.
//
//  • Fields starting with "_" are INTERNAL.
//       Do NOT edit `_image` or `_sound`. The engine fills them.
//
// =============================================================
//

WeaponDATABASE :: enum {
    AK,
    CHEWIECATT_MG,
    MOOSEY_ANTLERS,
    SUB_MACHINE_GUN,
    FATHERS_BELT,
    MOTHERS_ROLLING_PIN,
}

//
// Автомат Калашникова
//
AK_DATA: WeaponData = {
    name              = "Автомат Калашникова",
    type              = .AUTOMATIC,
    reload_time       = 5.0,
    ammo              = 30,
    base_damage       = 5,
    head_shot_damage  = 15,
    range             = 800,
    is_one_use        = false,
    rarity_percentage = 100,
    _image            = {},  // INTERNAL
    _sound            = {},  // INTERNAL
};

//
// Chewiecatt's machinegun
//
CHEWIECATT_MG_DATA: WeaponData = {
    name              = "Chewiecatt's machinegun",
    type              = .AUTOMATIC,
    reload_time       = 6.5,
    ammo              = 100,
    base_damage       = 3,
    head_shot_damage  = 13,
    range             = 800,
    is_one_use        = false,
    rarity_percentage = 100,
    _image            = {},  // INTERNAL
    _sound            = {},  // INTERNAL
};

//
// moosey's antlers (melee)
//
MOOSEY_ANTLERS_DATA: WeaponData = {
    name              = "moosey's antlers",
    type              = .MELEE,
    reload_time       = 5.0,   // melee cooldown
    ammo              = -1,    // infinite
    base_damage       = 25,
    head_shot_damage  = 35,
    range             = 800,
    is_one_use        = false,
    rarity_percentage = 100,
    _image            = {},  // INTERNAL
    _sound            = {},  // INTERNAL
};

//
// SUB Machine Gun
//
SUB_MACHINE_GUN_DATA: WeaponData = {
    name              = "SUB Machine Gun",
    type              = .AUTOMATIC,
    reload_time       = 5.0,
    ammo              = 35,
    base_damage       = 5,
    head_shot_damage  = -10,
    range             = 800,
    is_one_use        = false,
    rarity_percentage = 100,
    _image            = {},  // INTERNAL
    _sound            = {},  // INTERNAL
};

//
// THE FATHER'S BELT (single-use melee)
//
FATHERS_BELT_DATA: WeaponData = {
    name              = "THE FATHER'S BELT",
    type              = .MELEE,
    reload_time       = 5.0,
    ammo              = 1,
    base_damage       = 200,
    head_shot_damage  = 0,
    range             = 800,
    is_one_use        = true,
    rarity_percentage = 100,
    _image            = {},  // INTERNAL
    _sound            = {},  // INTERNAL
};

//
// THE MOTHERS ROLLING PIN (single-use melee)
//
MOTHERS_ROLLING_PIN_DATA: WeaponData = {
    name              = "THE MOTHERS ROLLING PIN",
    type              = .MELEE,
    reload_time       = 5.0,
    ammo              = 1,
    base_damage       = 200,
    head_shot_damage  = 0,
    range             = 800,
    is_one_use        = true,
    rarity_percentage = 100,
    _image            = {},  // INTERNAL
    _sound            = {},  // INTERNAL
};
