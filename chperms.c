#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>
#include <limits.h>
#include <libgen.h>

void printerr(const char* restrict format, ...) {
    va_list args;
    va_start(args, format);
    char msg[vsnprintf(NULL, 0, format, args) + 1];
    va_end(args);
    va_start(args, format);
    vsnprintf(msg, sizeof(msg), format, args);
    va_end(args);
    fprintf(stderr, "\033[1;31mError:\033[0m %s\n", msg);
    exit(EXIT_FAILURE);
}

char* abspath(char* path) {
    if (path == NULL)
        return NULL;

    struct stat st;
    if (lstat(path, &st) != 0)
        return NULL;

    char* ret = malloc(PATH_MAX);
    char cwd[PATH_MAX];
    getcwd(cwd, PATH_MAX);
    if (path[0] == '/')
        strcpy(ret, path);
    else {
        strcpy(ret, cwd);
        strcat(ret, "/");
        strcat(ret, path);
    }

    chdir(dirname(ret));
    getcwd(ret, PATH_MAX);
    const char* base = basename(path);
    if (strcmp(base, ".") != 0) {
        strcat(ret, "/");
        strcat(ret, basename(path));
    }
    chdir(cwd);
    return ret;
}

int main(int argc, char *argv[]) {
    if (geteuid() != 0)
        printerr("Must be run as root or setuid");

    if (argc < 2) {
        fprintf(stderr, "Usage: chperms <file1> [file2] [file3]\n");
        exit(EXIT_FAILURE);
    }

    for (int i = 1; i < argc; i++) {
        const char* file = abspath(argv[i]);
        if (file == NULL)
            printerr("%s not found", argv[i]);
        if (strncmp(file, "/srv/", 5) != 0)
            printerr("%s is not in /srv", argv[i]);

        const char* user = strtok(strdup(file) + 5, "/");
        const struct passwd * pw = getpwnam(user);
        if (pw == NULL)
            printerr("User %s does not exist", user);
        const uid_t uid = pw->pw_uid;
        const gid_t gid = pw->pw_gid;

        struct stat st;
        if (lstat(file, &st) == 0 && !S_ISLNK(st.st_mode))
            if (chmod(file, st.st_mode | S_IWGRP) != 0)
                printerr("Failed to change permissions for %s", argv[i]);
        if (lchown(file, uid, gid) != 0)
            printerr("Failed to change ownership for %s", argv[i]);
    }

    return EXIT_SUCCESS;
}
