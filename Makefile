PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
OS := $(shell uname -s)
STRIP := llvm-strip
CC := clang

ifndef VERBOSE
	Q := @
endif

OPTFLAGS += -O2 -march=native -fuse-ld=lld -flto
CFLAGS += -Wall -Wextra -Werror -std=gnu99 -o $(PKGNAME) $(PKGNAME).c

all: $(PKGNAME)

$(PKGNAME): $(PKGNAME).c
	@printf " \033[1;32mCC\033[0m %s\n" "$(PKGNAME).c"
	$(Q)$(CC) $(CFLAGS) $(OPTFLAGS)
	$(Q)$(STRIP) $(PKGNAME)

debug: $(PKGNAME).c
	@printf " \033[1;32mCC\033[0m %s\n" "$(PKGNAME).c"
	$(Q)$(CC) $(CFLAGS) -g -O0 -DDEBUG

install: $(PKGNAME)
	@printf "Installing...\n"
	@printf "%s\n" "$(PKGNAME) -> $(DESTDIR)$(BINDIR)"
	$(Q)install -D $(PKGNAME) $(DESTDIR)$(BINDIR)/$(PKGNAME)
	$(Q)chown root:root $(DESTDIR)$(BINDIR)/$(PKGNAME)
	$(Q)chmod 6755 $(DESTDIR)$(BINDIR)/$(PKGNAME)

uninstall:
	@printf "Uninstalling...\n"
	$(Q)$(RM) -f $(DESTDIR)$(BINDIR)/$(PKGNAME)

clean:
	@printf "Cleaning...\n"
	$(Q)$(RM) -f chperms
