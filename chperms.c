#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <string.h>
#include <pwd.h>
#include <unistd.h>
#include <pthread.h>

void printerr(const char* restrict format, ...) {
    char msg[1024];
    va_list args;
    va_start(args, format);
    vsnprintf(msg, 1024, format, args);
    va_end(args);
    fprintf(stderr, "\033[1;31mError:\033[0m %s\n", msg);
    exit(EXIT_FAILURE);
}

void chperms(const char *file) {
    const char* real = realpath(file, NULL);
    const struct passwd * pw = getpwnam(strtok(strdup(real) + 5, "/"));
    const uid_t uid = pw->pw_uid;
    const gid_t gid = pw->pw_gid;

    int perms = 0664;
    struct stat st;
    if (stat(real, &st) == 0 && S_ISDIR(st.st_mode)) perms = 02775;
    if (chmod(real, perms) != 0) printerr("Failed to change permissions for %s", file);
    if (chown(real, uid, gid) != 0) printerr("Failed to change ownership for %s", file);
}

int main(int argc, char *argv[]) {
    if (geteuid() != 0) printerr("Must be run as root or setuid");

    if (argc < 2) { fprintf(stderr, "Usage: chperms <file1> [file2] [file3]\n"); exit(EXIT_FAILURE); }

    for (int i = 1; i < argc; i++) {
        const char* file = realpath(argv[i], NULL);
        if (file == NULL) printerr("%s not found", argv[i]); else {
        if (strncmp(file, "/srv/", 5) != 0) printerr("%s is not in /srv", argv[i]);

        const char* user = strtok(strdup(file) + 5, "/");
        if (getpwnam(user) == NULL) printerr("User %s does not exist", user);

        if (access(file, W_OK) != 0) printerr("No write access to %s", argv[i]);
    }}

    pthread_t thread;
    for (int i = 1; i < argc; i++) {
        pthread_create(&thread, NULL, (void*)chperms, (void*)argv[i]);
    }
    pthread_exit(NULL);
}
