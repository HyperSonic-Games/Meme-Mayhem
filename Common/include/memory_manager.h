/*
HyperSonic Games Non-Commercial Source License (HSG-NCSL)
Copyright (c) 2026 HyperSonic-Games

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the “Software”), to use, copy, modify, and distribute the Software, subject to the terms below.

1. Permissions
You may:
* Use the Software for any non-commercial purpose.
* Copy and redistribute the Software in source or binary form.
* Modify the Software and create derivative works (“Mods”).

2. Non-Commercial Restriction
The Software and all derivative works (“Mods”) may not be used for any Commercial Purpose. “Commercial Purpose”
means any use intended to generate revenue or monetary compensation, directly or indirectly, including but not limited to:
* Selling the Software or Mods.
* Charging access, subscription, or usage fees.
* Placing the Software or Mods behind paywalls or gated access.
* Bundling with paid products or services.
* Monetizing distribution or access in any form.

Exceptions: This restriction does not prohibit free distribution, open-source sharing, or the receipt of voluntary financial donations
(such as tips, Ko-fi, or Patreon support), provided that such donations are strictly optional
and do not restrict, delay, time-gate, or block access to the Software, Mods, updates, or specific features.

3. Mod Requirements
All Mods or derivative works must:
* Be distributed under terms that allow free use, modification, and redistribution.
* Clearly state they are based on HyperSonic-Games Software.
* Clearly differentiate themselves from the original Software (name, branding, and description must not imply official status).
* Include this license or a reference to it.
* Mods must not imply endorsement, sponsorship, or official affiliation with HyperSonic-Games unless explicitly authorized in writing.

4. Attribution
All copies or substantial portions of the Software must include the original copyright notice and this license.

5. Upstream Contributions
HyperSonic-Games may, at its sole discretion, incorporate fixes, improvements, or other contributions from Mods into the official Software.
By making a Mod or contribution publicly available,
the author grants HyperSonic-Games a non-exclusive, perpetual, irrevocable, royalty-free, worldwide license to use, modify,
and distribute that contribution within the official Software. 

When incorporated, attribution will be provided in-source as:
// Contribution by: [NAME]
// Description: [SHORT DESCRIPTION]

No obligation exists to review, accept, or include any contribution.

6. Branding and Trademark
This license does not grant any rights to use “HyperSonic Games” as a trademark, brand name, or endorsement identity.
Separate permission is required for official branding or affiliation.

7. Warranty Disclaimer
The Software is provided “AS IS”, without warranty of any kind, express or implied. The authors are not liable for any damages arising from its use.

8. Termination
Any violation of the Non-Commercial Restriction, Mod Requirements, or attribution requirements automatically terminates this license.
*/
#ifndef MEME_MAYHEM_COMMON_MEMORY_MANAGER_H
#define MEME_MAYHEM_COMMON_MEMORY_MANAGER_H

#include <stdint.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct handle_t handle;

#define INVALID_HANDLE NULL

/*
allocates memory of a specified size
then creates a handle for it
*/
handle *Allocate(size_t size);

/*
realocates the data stored in the handle
and updates its data
*/
bool Reallocate(handle *h, size_t new_size);
/*
allocates a contiguous block of memory for an array of multiple elements
and automatically initializes all the allocated bytes to zero.
*/
handle *ContiguousAllocation(size_t num, size_t size);

/*
frees the memory backed by the handle and
deletes the handle to allow the ID to be reused
*/
void Free(handle *h);

/*
return a void pointer to the data stored in the handle
it is not recomended to hold on to this poiner
as the handle could be freed or realocated
at any time
*/
void *GetPointerFromHandle(handle *hr);

/*
internal function used to look up a handle from a pointer
*/
handle *_GetHandleFromPointer(void *ptr);

/*
internal function used to interface with raylib
wraps the `Allocate` function
*/
void *_RAYLIB_Allocate(size_t size);

/*
internal function used to interface with raylib
wraps the `Reallocate` function
*/
void *_RAYLIB_Reallocate(void *ptr, size_t new_size);

/*
internal function used to interface with raylib
wraps the `ContiguousAllocation` function
*/
void *_RAYLIB_ContiguousAllocation(size_t num, size_t size);

#endif // MEME_MAYHEM_COMMON_MEMORY_MANAGER_H
