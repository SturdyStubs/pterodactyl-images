// Minimal LD_PRELOAD shim to prevent stdio (fd 0/1/2) from being closed.
// This mitigates Unity/Mono aborts when fd 0 gets reused for sockets/files.

#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>

static int (*real_close)(int) = NULL;
static int (*real_fclose)(FILE *) = NULL;

__attribute__((constructor)) static void init_keepstdio(void) {
    real_close = (int (*)(int))dlsym(RTLD_NEXT, "close");
    real_fclose = (int (*)(FILE *))dlsym(RTLD_NEXT, "fclose");
}

int close(int fd) {
    if (!real_close) {
        real_close = (int (*)(int))dlsym(RTLD_NEXT, "close");
    }
    if (fd >= 0 && fd <= 2) {
        // Pretend success, keep stdio fds open
        errno = 0;
        return 0;
    }
    return real_close(fd);
}

int fclose(FILE *stream) {
    if (!real_fclose) {
        real_fclose = (int (*)(FILE *))dlsym(RTLD_NEXT, "fclose");
    }
    if (stream == stdin || stream == stdout || stream == stderr) {
        errno = 0;
        return 0;
    }
    return real_fclose(stream);
}

