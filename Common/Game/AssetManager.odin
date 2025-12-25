package Game


/*
NOTE(A-Boring-Square):
When source modding Meme Mayhem,
to add more weapons you **MUST** add the asset name here.
These strings are used as keys in `ASSET_BUNDLE`.
And are used when communicating with the server for what to render.
*/


WEP_AK_47_NAME :: "AK_47"
WEP_MINIGUN_NAME :: "CHEWIECATTS_MINIGUN"
WEP_ANTLERS_NAME :: "MOOSEYS_ANTLERS"
WEP_BELT_NAME :: "THE_FATHERS_BELT"
WEP_ROLLING_PIN_NAME :: "THE_MOTHERS_ROLLING_PIN"

GetAsset :: proc(assets: map[string][]u8, name: string) -> []u8