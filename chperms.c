#include <errno.h>
#include <libgen.h>
#include <limits.h>
#include <pwd.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

void printerr(const char *restrict format, ...) {
  va_list args, args2;
  va_start(args, format);
  va_copy(args2, args);
  char msg[vsnprintf(NULL, 0, format, args) + 1];
  vsnprintf(msg, sizeof(msg), format, args2);
  va_end(args);
  va_end(args2);
  fprintf(stderr, "\033[1;31mError:\033[0m %s\n", msg);
  exit(EXIT_FAILURE);
}

static char *abspath(char *path) {
  if (path == NULL)
    return NULL;

  struct stat st;
  if (lstat(path, &st) != 0)
    return NULL;

  char cwd[PATH_MAX];
  if (!getcwd(cwd, PATH_MAX))
    printerr("getcwd: %s", strerror(errno));
  char *ret = malloc(PATH_MAX + strlen(path) + 1);
  if (!ret)
    printerr("Failed to allocate memory");
  if (path[0] == '/')
    strcpy(ret, path);
  else {
    strcpy(ret, cwd);
    strcat(ret, "/");
    strcat(ret, path);
  }

  if (chdir(dirname(ret)) != 0)
    printerr("chdir: %s", strerror(errno));
  if (!getcwd(ret, PATH_MAX))
    printerr("chdir: %s", strerror(errno));
  char *base = basename(path);
  if (strcmp(base, "..") == 0) {
    char *p = strrchr(ret, '/');
    *p = '\0';
    if (ret[0] == '\0')
      strcpy(ret, "/");
  } else if (strcmp(base, ".") != 0) {
    strcat(ret, "/");
    strcat(ret, basename(path));
  }
  if (chdir(cwd) != 0)
    printerr("chdir: %s", strerror(errno));
  return ret;
}

int main(int argc, char *argv[]) {
  if (geteuid() != 0)
    printerr("Must be run as root or setuid");

  if (argc < 2) {
    fprintf(stderr, "Usage: chperms <file> [files ...]\n");
    exit(EXIT_FAILURE);
  }

  uid_t realuid = getuid();
  for (int i = 1; i < argc; i++) {
    const char *file = abspath(argv[i]);
    if (file == NULL)
      printerr("%s not found", argv[i]);
    if (strncmp(file, "/srv/", 5) != 0)
      printerr("%s is not in /srv", argv[i]);

    char filecopy[strlen(file) + 1];
    strcpy(filecopy, file);
    const char *user = strtok(filecopy + 5, "/");
    const struct passwd *pw = getpwnam(user);
    if (pw == NULL)
      printerr("User %s does not exist", user);
    const uid_t uid = pw->pw_uid;
    const gid_t gid = pw->pw_gid;

    if (realuid != 0 && realuid != uid) {
      int ngroups = getgroups(0, NULL);
      gid_t groups[ngroups];
      if (getgroups(ngroups, groups) != 0)
        printerr("getgroups: %s", strerror(errno));
      bool found = false;
      for (int j = 0; j < ngroups; j++)
        if (groups[j] == gid) {
          found = true;
          break;
        }
      if (!found)
        printerr(
            "You must be a member of the group %s to change permissions for %s",
            user, argv[i]);
    }

    struct stat st;
    if (lstat(file, &st) == 0 && !S_ISLNK(st.st_mode)) {
      mode_t perms = st.st_mode | S_IRGRP | S_IWGRP;
      if (S_ISDIR(st.st_mode))
        perms |= S_ISGID | S_IXGRP;
      if (chmod(file, perms) != 0)
        printerr("Failed to change permissions for %s", argv[i]);
    }
    if (lchown(file, uid, gid) != 0)
      printerr("Failed to change ownership for %s", argv[i]);
  }

  return EXIT_SUCCESS;
}
