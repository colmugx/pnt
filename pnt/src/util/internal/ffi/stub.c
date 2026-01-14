#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/utsname.h>
#include <string.h>
#include <stdio.h>
#include "moonbit.h"

#ifndef MOONBIT_FFI_EXPORT
#define MOONBIT_FFI_EXPORT
#endif

// Symlink operations
MOONBIT_FFI_EXPORT int pnt_symlink(moonbit_bytes_t target, moonbit_bytes_t linkpath) {
    return symlink((const char*)target, (const char*)linkpath);
}

MOONBIT_FFI_EXPORT int pnt_readlink(moonbit_bytes_t path, moonbit_bytes_t buf, int bufsize) {
    return readlink((const char*)path, (char*)buf, bufsize);
}

// Terminal operations
MOONBIT_FFI_EXPORT int pnt_get_term_size(int *rows, int *cols) {
    struct winsize w;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == -1) {
        return -1;
    }
    *rows = w.ws_row;
    *cols = w.ws_col;
    return 0;
}

MOONBIT_FFI_EXPORT int pnt_is_interactive() {
    return isatty(STDOUT_FILENO);
}

// System info
MOONBIT_FFI_EXPORT moonbit_bytes_t pnt_get_os() {
    const char* os_str =
    #if defined(_WIN32)
        "win";
    #elif defined(__APPLE__)
        "darwin";
    #elif defined(__linux__)
        "linux";
    #else
        "unknown";
    #endif
    int len = strlen(os_str);
    moonbit_bytes_t result = moonbit_make_bytes(len, 0);
    memcpy(result, os_str, len);
    return result;
}

MOONBIT_FFI_EXPORT moonbit_bytes_t pnt_get_arch() {
    const char* arch_str =
    #if defined(__x86_64__) || defined(_M_X64)
        "x64";
    #elif defined(__i386__) || defined(_M_IX86)
        "x86";
    #elif defined(__aarch64__) || defined(_M_ARM64)
        "arm64";
    #else
        "unknown";
    #endif
    int len = strlen(arch_str);
    moonbit_bytes_t result = moonbit_make_bytes(len, 0);
    memcpy(result, arch_str, len);
    return result;
}
