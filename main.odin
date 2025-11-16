package main

import "core:fmt"
import "Engine"


main :: proc() {
    fmt.printf("Weapon Data: %v", Engine.LoadWeapons())
}