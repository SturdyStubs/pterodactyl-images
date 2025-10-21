// Minimal LD_PRELOAD shim to prevent stdio (fd 0/1/2) from being closed.
// This mitigates Unity/Mono aborts when fd 0 gets reused for sockets/files.

#define _GNU_SOURCE
#include <dlfcn.h>
#include <errno.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

static int (*real_close)(int) = NULL;
static int (*real_fclose)(FILE *) = NULL;
static int (*real_dup)(int) = NULL;
static int (*real_dup2)(int, int) = NULL;
#ifdef __GLIBC__
static int (*real_dup3)(int, int, int) = NULL;
#endif
static int (*real_fcntl)(int, int, ...) = NULL;

__attribute__((constructor)) static void init_keepstdio(void) {
    real_close = (int (*)(int))dlsym(RTLD_NEXT, "close");
    real_fclose = (int (*)(FILE *))dlsym(RTLD_NEXT, "fclose");
    real_dup = (int (*)(int))dlsym(RTLD_NEXT, "dup");
    real_dup2 = (int (*)(int,int))dlsym(RTLD_NEXT, "dup2");
#ifdef __GLIBC__
    real_dup3 = (int (*)(int,int,int))dlsym(RTLD_NEXT, "dup3");
#endif
    real_fcntl = (int (*)(int,int,...))dlsym(RTLD_NEXT, "fcntl");
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
        // Avoid returning stdio fds accidentally
        int newfd = fcntl(fd, F_DUPFD, 3);
        if (newfd >= 0) {
            real_close(fd);
            return newfd;
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

int fcntl(int fd, int cmd, ...) {
    if (!real_fcntl) real_fcntl = (int (*)(int,int,...))dlsym(RTLD_NEXT, "fcntl");
    va_list ap;
    va_start(ap, cmd);
    int ret;
    if (cmd == F_DUPFD || cmd == F_DUPFD_CLOEXEC) {
        int start = va_arg(ap, int);
        if (start <= 2) start = 3;
        ret = real_fcntl(fd, cmd, start);
        if (ret >= 0 && ret <= 2) {
            int newfd = real_fcntl(fd, cmd, 3);
            if (newfd >= 0) {
                real_close(ret);
                ret = newfd;
            }
        }
    } else {
        // Pass through other commands, extracting the right argument type is caller-specific;
        // for simplicity, forward the original va_list (undefined in strict C), but glibc tolerates it.
        ret = real_fcntl(fd, cmd, ap);
    }
    va_end(ap);
    return ret;
}
