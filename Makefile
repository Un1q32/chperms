PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
STRIP := llvm-strip

ifndef VERBOSE
V := @
endif

OPTFLAGS := -Os
CFLAGS := -Wall -Wextra -Werror -std=gnu99

all: $(PKGNAME)

$(PKGNAME): $(PKGNAME).c
	@printf " \033[1;32mCC\033[0m %s\n" "$(PKGNAME).c"
	$(V)$(CC) $(CFLAGS) $(OPTFLAGS) -c $(PKGNAME).c
	@printf " \033[1;34mLD\033[0m %s\n" "$(PKGNAME)"
	$(V)$(CC) $(LDFLAGS) $(OPTFLAGS) -o $(PKGNAME) $(PKGNAME).o

debug: OPTFLAGS := -g
debug: all

install: $(PKGNAME)
	@printf "Installing...\n"
	@printf "%s\n" "$(PKGNAME) -> $(DESTDIR)$(BINDIR)"
	$(V)install -D $(PKGNAME) $(DESTDIR)$(BINDIR)/$(PKGNAME)
	$(V)$(STRIP) $(DESTDIR)$(BINDIR)/$(PKGNAME)
	$(V)chmod 6755 $(DESTDIR)$(BINDIR)/$(PKGNAME)

uninstall:
	@printf "Uninstalling...\n"
	$(V)$(RM) -f $(DESTDIR)$(BINDIR)/$(PKGNAME)

clean:
	@printf "Cleaning...\n"
	$(V)rm -f $(PKGNAME) $(PKGNAME).o
