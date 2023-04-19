#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>

void error(const char *restrict format, ...) {
    va_list args;
    va_start(args, format);
    fprintf(stderr, "\033[1;31mError:\033[0m ");
    vfprintf(stderr, format, args);
    fprintf(stderr, "\n");
    va_end(args);
    exit(EXIT_FAILURE);
}

bool isDir(const char *path) {
    struct stat path_stat;
    stat(path, &path_stat);
    return S_ISDIR(path_stat.st_mode);
}

int main(int argc, char *argv[]) {
    if (geteuid() != 0) { error("Must be run as root or setuid"); }

    if (argc < 2) { fprintf(stderr, "Usage: chperms <file1> [file2] [file3]\n"); exit(EXIT_FAILURE); }

    for (int i = 1; i < argc; i++) {
        char *file = realpath(argv[i], NULL);
        if (file == NULL) { error("%s not found", argv[i]); }
        if (strncmp(file, "/srv/", 5) != 0) { error("%s is not in /srv", argv[i]); }

        char *user = strtok(strdup(file) + 5, "/");
        struct passwd *pw = getpwnam(user);
        if (pw == NULL) { error("User %s does not exist", user); }
    }

    for (int i = 1; i < argc; i++) {
        char *file = realpath(argv[i], NULL);
        char *user = strtok(strdup(file) + 5, "/");
        struct passwd *pw = getpwnam(user);
        uid_t uid = pw->pw_uid;
        gid_t gid = pw->pw_gid;

        int perms = 0664;
        if (isDir(file)) { perms = 02775; }
        if (chmod(file, perms) != 0) { error("Failed to change permissions for %s", argv[i]); }
        if (chown(file, uid, gid) != 0) { error("Failed to change ownership for %s", argv[i]); }
    }
}
