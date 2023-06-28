PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
OS := $(shell uname -s)
STRIP := llvm-strip
CC := clang

ifndef VERBOSE
	Q := @
endif

OPTFLAGS += -O2 -march=native -flto
CFLAGS += -Wall -Wextra -Werror -std=gnu99
LDFLAGS += -fuse-ld=lld

all: $(PKGNAME)

$(PKGNAME): $(PKGNAME).o
	@printf " \033[1;34mLD\033[0m %s\n" "$(PKGNAME)"
	$(Q)$(CC) $(LDFLAGS) $(OPTFLAGS) -o $(PKGNAME) $(PKGNAME).o
	$(Q)$(STRIP) $(PKGNAME)

$(PKGNAME).o: $(PKGNAME).c
	@printf " \033[1;32mCC\033[0m %s\n" "$(PKGNAME).c"
	$(Q)$(CC) $(CFLAGS) $(OPTFLAGS) -c $(PKGNAME).c

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
	$(Q)$(RM) -f $(PKGNAME) $(PKGNAME).o
