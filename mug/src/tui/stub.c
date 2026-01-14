#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <sys/time.h>
#include "moonbit.h"

#ifndef MOONBIT_FFI_EXPORT
#define MOONBIT_FFI_EXPORT
#endif

void mug_fflush_stdout(void) {
    fflush(stdout);
}

// Helper to encode codepoint to UTF-8
int encode_utf8(uint32_t codepoint, char* out) {
    if (codepoint <= 0x7F) {
        out[0] = (char)codepoint;
        return 1;
    } else if (codepoint <= 0x7FF) {
        out[0] = (char)(0xC0 | (codepoint >> 6));
        out[1] = (char)(0x80 | (codepoint & 0x3F));
        return 2;
    } else if (codepoint <= 0xFFFF) {
        out[0] = (char)(0xE0 | (codepoint >> 12));
        out[1] = (char)(0x80 | ((codepoint >> 6) & 0x3F));
        out[2] = (char)(0x80 | (codepoint & 0x3F));
        return 3;
    } else if (codepoint <= 0x10FFFF) {
        out[0] = (char)(0xF0 | (codepoint >> 18));
        out[1] = (char)(0x80 | ((codepoint >> 12) & 0x3F));
        out[2] = (char)(0x80 | ((codepoint >> 6) & 0x3F));
        out[3] = (char)(0x80 | (codepoint & 0x3F));
        return 4;
    }
    return 0;
}

// Print MoonBit string directly without heap allocation
MOONBIT_FFI_EXPORT void mug_print(moonbit_string_t str) {
    if (!str) return;
    
    int32_t const len = Moonbit_array_length(str);
    const uint16_t* chars = (const uint16_t*)str;
    
    // Use a stack buffer to avoid malloc/free
    char buf[1024]; 
    int buf_idx = 0;

    for (int32_t i = 0; i < len; i++) {
        uint32_t codepoint = chars[i];
        
        // Handle surrogate pairs
        if (codepoint >= 0xD800 && codepoint <= 0xDBFF && i + 1 < len) {
            uint32_t next = chars[i + 1];
            if (next >= 0xDC00 && next <= 0xDFFF) {
                codepoint = 0x10000 + ((codepoint - 0xD800) << 10) + (next - 0xDC00);
                i++; // Skip low surrogate
            }
        }

        // Encode to UTF-8
        char utf8[4];
        int bytes = encode_utf8(codepoint, utf8);
        
        // Flush buffer if it might overflow
        if (buf_idx + bytes >= sizeof(buf) - 1) {
            buf[buf_idx] = '\0';
            printf("%s", buf);
            buf_idx = 0;
        }

        for (int j = 0; j < bytes; j++) {
            buf[buf_idx++] = utf8[j];
        }
    }

    // Print remaining chars
    if (buf_idx > 0) {
        buf[buf_idx] = '\0';
        printf("%s", buf);
    }
}

// Get current time in milliseconds
MOONBIT_FFI_EXPORT uint64_t mug_get_time_ms(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (uint64_t)(tv.tv_sec) * 1000 + (uint64_t)(tv.tv_usec) / 1000;
}
