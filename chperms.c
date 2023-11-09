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
    char msg[vsnprintf(NULL, 0, format, args) + 1];
    vsnprintf(msg, sizeof(msg), format, args);
    va_end(args);
    fprintf(stderr, "\033[1;31mError:\033[0m %s\n", msg);
    exit(EXIT_FAILURE);
}

int main(int argc, char *argv[]) {
    if (geteuid() != 0) printerr("Must be run as root or setuid");

    if (argc < 2) { fprintf(stderr, "Usage: chperms <file1> [file2] [file3]\n"); exit(EXIT_FAILURE); }

    for (int i = 1; i < argc; i++) {
        const char* file = realpath(argv[i], NULL);
        if (file == NULL) printerr("%s not found", argv[i]);
        if (strncmp(file, "/srv/", 5) != 0) printerr("%s is not in /srv", argv[i]);

        const char* user = strtok(strdup(file) + 5, "/");
        const struct passwd * pw = getpwnam(user);
        if (pw == NULL) printerr("User %s does not exist", user);
        const uid_t uid = pw->pw_uid;
        const gid_t gid = pw->pw_gid;

        int perms = 0664;
        struct stat st;
        if (stat(file, &st) == 0 && S_ISDIR(st.st_mode)) perms = 02775;
        else if (access(file, X_OK) == 0) perms = 0775;
        if (chmod(file, perms) != 0) printerr("Failed to change permissions for %s", argv[i]);
        if (chown(file, uid, gid) != 0) printerr("Failed to change ownership for %s", argv[i]);
    }

    return EXIT_SUCCESS;
}
