#include <stdio.h>

/// Flush the standard output stream
/// This is used by the Spinner to ensure animations are displayed immediately
void mug_fflush_stdout(void) {
    fflush(stdout);
}
