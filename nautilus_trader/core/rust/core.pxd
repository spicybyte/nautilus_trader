# Warning, this file is autogenerated by cbindgen. Don't modify this manually. */

from libc.stdint cimport uintptr_t, uint8_t, int64_t

cdef extern from "../includes/core.h":

    cdef struct Buffer16:
        uint8_t data[16];
        uintptr_t len;

    cdef struct Buffer32:
        uint8_t data[32];
        uintptr_t len;

    cdef struct Buffer36:
        uint8_t data[36];
        uintptr_t len;

    cdef struct UUID4_t:
        Buffer36 value;

    Buffer16 dummy_16(Buffer16 ptr);

    Buffer32 dummy_32(Buffer32 ptr);

    # Returns the current seconds since the UNIX epoch.
    double unix_timestamp();

    # Returns the current milliseconds since the UNIX epoch.
    int64_t unix_timestamp_ms();

    # Returns the current microseconds since the UNIX epoch.
    int64_t unix_timestamp_us();

    # Returns the current nanoseconds since the UNIX epoch.
    int64_t unix_timestamp_ns();

    UUID4_t uuid4_new();

    void uuid4_free(UUID4_t uuid4);

    UUID4_t uuid4_from_bytes(Buffer36 value);

    Buffer36 uuid4_to_bytes(const UUID4_t *uuid);
