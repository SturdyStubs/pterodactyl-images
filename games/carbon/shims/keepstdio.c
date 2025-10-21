// Minimal LD_PRELOAD shim to prevent stdio (fd 0/1/2) from being closed.
// This mitigates Unity/Mono aborts when fd 0 gets reused for sockets/files.

#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdarg.h>

static int (*real_close)(int) = NULL;
static int (*real_fclose)(FILE *) = NULL;
static int (*real_dup)(int) = NULL;
static int (*real_dup2)(int, int) = NULL;
#ifdef __GLIBC__
static int (*real_dup3)(int, int, int) = NULL;
#endif
static int (*real_close_range)(unsigned int, unsigned int, unsigned int) = NULL;

__attribute__((constructor)) static void init_keepstdio(void) {
    real_close = (int (*)(int))dlsym(RTLD_NEXT, "close");
    real_fclose = (int (*)(FILE *))dlsym(RTLD_NEXT, "fclose");
    real_dup = (int (*)(int))dlsym(RTLD_NEXT, "dup");
    real_dup2 = (int (*)(int,int))dlsym(RTLD_NEXT, "dup2");
#ifdef __GLIBC__
    real_dup3 = (int (*)(int,int,int))dlsym(RTLD_NEXT, "dup3");
#endif
    real_close_range = (int (*)(unsigned int,unsigned int,unsigned int))dlsym(RTLD_NEXT, "close_range");
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

int dup(int oldfd) {
    if (!real_dup) real_dup = (int (*)(int))dlsym(RTLD_NEXT, "dup");
    int fd = real_dup(oldfd);
    if (fd >= 0 && fd <= 2) {
        // Avoid returning stdio fds accidentally; duplicate until >= 3
        int tmp = fd;
        while (tmp >= 0 && tmp <= 2) {
            int next = real_dup(fd);
            if (next < 0) break;
            tmp = next;
        }
        if (tmp >= 3) {
            real_close(fd);
            return tmp;
        }
    }
    return fd;
}

int dup2(int oldfd, int newfd) {
    if (!real_dup2) real_dup2 = (int (*)(int,int))dlsym(RTLD_NEXT, "dup2");
    if (newfd >= 0 && newfd <= 2) {
        // Disallow making stdio fds point to sockets/files
        errno = EBADF;
        return -1;
    }
    return real_dup2(oldfd, newfd);
}

#ifdef __GLIBC__
int dup3(int oldfd, int newfd, int flags) {
    if (!real_dup3) real_dup3 = (int (*)(int,int,int))dlsym(RTLD_NEXT, "dup3");
    if (newfd >= 0 && newfd <= 2) {
        errno = EBADF;
        return -1;
    }
    return real_dup3(oldfd, newfd, flags);
}
#endif

// Prevent closing stdio via close_range
int close_range(unsigned int first, unsigned int last, unsigned int flags) {
    if (!real_close_range) real_close_range = (int (*)(unsigned int,unsigned int,unsigned int))dlsym(RTLD_NEXT, "close_range");
    if (first <= 2) first = 3;
    if (first > last) {
        errno = 0;
        return 0;
    }
    if (real_close_range) {
        return real_close_range(first, last, flags);
    }
    // Fallback: best-effort loop with a safety cap
    unsigned int max = last > 65535 ? 65535 : last;
    for (unsigned int i = first; i <= max; ++i) {
        if (i <= 2) continue;
        real_close(i);
    }
    return 0;
}
