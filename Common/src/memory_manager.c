#include "../include/memory_manager.h"

#include <stdatomic.h>

/*
counter for the current handle generation
wraps to 0 if full
*/
_Atomic(uint32_t) current_generation = 0;

struct handle_t {
    uint32_t generation;
    _Atomic(void*) data;
};

#define HEADER_SIZE sizeof(handle*)
#define GET_RAW_BLOCK(user_ptr) ((void*)((uintptr_t)(user_ptr) - HEADER_SIZE))
#define GET_USER_BLOCK(raw_ptr) ((void*)((uintptr_t)(raw_ptr) + HEADER_SIZE))

handle *Allocate(size_t size) {
    // allocate space for the handle pointer header and user payload
    size_t total_size = size + HEADER_SIZE;
    void *raw_block = malloc(total_size);
    
    if (raw_block == NULL) {
        return INVALID_HANDLE;
    }

    handle *h = malloc(sizeof(handle));
    
    if (h == NULL) {
        free(raw_block);
        return INVALID_HANDLE;
    }

    // insert the handle pointer into the hidden structural header
    *(handle**)raw_block = h;

    // shift pointer forward to derive the user's data block
    void *user_data = GET_USER_BLOCK(raw_block);

    h->generation = atomic_fetch_add(&current_generation, 1);
    atomic_init(&h->data, user_data);

    return h;
}

handle *ContiguousAllocation(size_t num, size_t size) {
    // defend against potential multiplication overflow bounds check
    if (num != 0 && size > SIZE_MAX / num) {
        return INVALID_HANDLE;
    }
    
    size_t payload_size = num * size;
    size_t total_size = payload_size + HEADER_SIZE;

    // calloc clears payload memory completely to default zero
    void *raw_block = calloc(1, total_size);
    
    if (raw_block == NULL) {
        return INVALID_HANDLE;
    }

    handle *h = malloc(sizeof(handle));
    
    if (h == NULL) {
        free(raw_block);
        return INVALID_HANDLE;
    }

    *(handle**)raw_block = h;
    void *user_data = GET_USER_BLOCK(raw_block);

    h->generation = atomic_fetch_add(&current_generation, 1);
    atomic_init(&h->data, user_data);

    return h;
}

bool Reallocate(handle *h, size_t new_size) {
    if (h == INVALID_HANDLE) {
        return false;
    }

    void *current_user_data = atomic_load(&h->data);
    
    if (current_user_data == NULL) {
        return false;
    }

    while (current_user_data != NULL) {
        // step back to locate the true boundary of our underlying malloc block
        void *current_raw_block = GET_RAW_BLOCK(current_user_data);
        size_t total_new_size = new_size + HEADER_SIZE;

        void *resized_raw_ptr = realloc(current_raw_block, total_new_size);
        
        if (resized_raw_ptr == NULL) {
            return false; // Out of memory
        }

        // re establish the internal user payload offset
        void *new_user_data = GET_USER_BLOCK(resized_raw_ptr);

        // re stamp the handle location in the fresh allocation block
        *(handle**)resized_raw_ptr = h;

        if (atomic_compare_exchange_weak(&h->data, &current_user_data, new_user_data)) {
            return true;
        }

        // CONFLICT! another thread mutated the data discard it and loop
        free(resized_raw_ptr);
    }

    return false;
}

void Free(handle *h) {
    if (h == INVALID_HANDLE) {
        return;
    }

    void *user_data_to_free = atomic_exchange(&h->data, NULL);

    if (user_data_to_free != NULL) {
        // recover original base address boundary to safely trigger the OS memory dealocator
        void *raw_block_to_free = GET_RAW_BLOCK(user_data_to_free);
        free(raw_block_to_free);

        // keep the handle tracking shell metadata block alive for continuous thread loops
        // (prevents crashing other threads accessing `GetPointerFromHandle` or `_GetHandleFromPointer`)
    }
}

void *GetPointerFromHandle(handle *h) {
    if (h == INVALID_HANDLE) {
        return NULL;
    }
    
    return atomic_load(&h->data);
}

handle *_GetHandleFromPointer(void *ptr) {
    if (ptr == NULL) {
        return INVALID_HANDLE;
    }

    // read the secret header hidden directly in front of the object pointer 
    handle **secret_header = (handle**)GET_RAW_BLOCK(ptr);
    return *secret_header;
}

void *_RAYLIB_Allocate(size_t size) {
    handle *h = Allocate(size);
    
    if (h == INVALID_HANDLE) {
        return NULL;
    }
    
}
