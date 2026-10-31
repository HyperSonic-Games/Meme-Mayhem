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
