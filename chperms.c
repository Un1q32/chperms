#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>
#include "liboldworld.h"

int main(const int argc, const char *argv[]) {
    if (geteuid() != 0) printerr("Must be run as root or setuid");

    if (argc < 2) { fprintf(stderr, "Usage: chperms <file1> [file2] [file3]\n"); exit(EXIT_FAILURE); }

    for (int i = 1; i < argc; i++) {
        const char * real = realpath(argv[i], NULL);
        if (real == NULL) printerr("%s not found", argv[i]); else
        if (strncmp(real, "/srv/", 5) != 0) printerr("%s is not in /srv", argv[i]); else {

        const char * user = strtok(strdup(real) + 5, "/");
        if (getpwnam(user) == NULL) printerr("User %s does not exist", user); }
    }

    for (int i = 1; i < argc; i++) {
        const char * real = realpath(argv[i], NULL);
        const struct passwd * pw = getpwnam(strtok(strdup(real) + 5, "/"));
        const uid_t uid = pw->pw_uid;
        const gid_t gid = pw->pw_gid;

        int perms = 0664;
        if (getfiletype(real) == 1) perms = 02775;
        if (chmod(real, perms) != 0) printerr("Failed to change permissions for %s", argv[i]);
        if (chown(real, uid, gid) != 0) printerr("Failed to change ownership for %s", argv[i]);
    }
}
