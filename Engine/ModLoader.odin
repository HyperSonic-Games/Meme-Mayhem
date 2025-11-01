package Engine

ModCallbacks :: struct {
    client_on_load: ClientOnLoad,
    server_on_load: ServerOnLoad,
    map_interactable_on_place_attempt: MapInteractableOnPlaceAtempt,
    map_interactable_on_interact: MapInteractableOnInteract,
}


LoadedMods :: struct {
    mods_callbacks: [dynamic]ModCallbacks
}