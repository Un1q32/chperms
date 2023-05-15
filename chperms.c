#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>
#include "liboldworld.h"

void checkfile(const char *file) {
    const char * real = realpath(file, NULL);
    if (real == NULL) printerr("%s not found", file); else
    if (strncmp(real, "/srv/", 5) != 0) printerr("%s is not in /srv", file); else {

    const char * user = strtok(strdup(real) + 5, "/");
    if (getpwnam(user) == NULL) printerr("User %s does not exist", user); }
}

void chperms(const char *file) {
    const char * real = realpath(file, NULL);
    const struct passwd * pw = getpwnam(strtok(strdup(real) + 5, "/"));
    const uid_t uid = pw->pw_uid;
    const gid_t gid = pw->pw_gid;

    int perms = 0664;
    if (getfiletype(real) == 1) perms = 02775;
    if (chmod(real, perms) != 0) printerr("Failed to change permissions for %s", file);
    if (chown(real, uid, gid) != 0) printerr("Failed to change ownership for %s", file);
}

int main(const int argc, const char *argv[]) {
    if (geteuid() != 0) printerr("Must be run as root or setuid");

    if (argc < 2) { fprintf(stderr, "Usage: chperms <file1> [file2] [file3]\n"); exit(EXIT_FAILURE); }

    for (int i = 1; i < argc; i++) {
        checkfile(argv[i]);
    }

    for (int i = 1; i < argc; i++) {
        chperms(argv[i]);
    }
}
