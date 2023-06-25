#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>

void printerr(const char* restrict format, ...) {
    va_list args;
    va_start(args, format);
    fprintf(stderr, "\033[1;31mError:\033[0m ");
    vfprintf(stderr, format, args);
    fprintf(stderr, "\n");
    va_end(args);
    exit(EXIT_FAILURE);
}

int main(const int argc, const char *argv[]) {
    if (geteuid() != 0) printerr("Must be run as root or setuid");

    if (argc < 2) { fprintf(stderr, "Usage: chperms <file1> [file2] [file3]\n"); exit(EXIT_FAILURE); }

    for (int i = 1; i < argc; i++) {
        const char* file = realpath(argv[i], NULL);
        if (file == NULL) printerr("%s not found", argv[i]); else
        if (strncmp(file, "/srv/", 5) != 0) printerr("%s is not in /srv", argv[i]); else {

        const char* user = strtok(strdup(file) + 5, "/");
        if (getpwnam(user) == NULL) printerr("User %s does not exist", user); }
    }

    for (int i = 1; i < argc; i++) {
        const char* file = realpath(argv[i], NULL);
        const struct passwd * pw = getpwnam(strtok(strdup(file) + 5, "/"));
        const uid_t uid = pw->pw_uid;
        const gid_t gid = pw->pw_gid;

        int perms = 0664;
        struct stat st; 
        if (stat(file, &st) == 0 && S_ISDIR(st.st_mode)) perms = 02775;
        if (chmod(file, perms) != 0) printerr("Failed to change permissions for %s", argv[i]);
        if (chown(file, uid, gid) != 0) printerr("Failed to change ownership for %s", argv[i]);
    }
}
