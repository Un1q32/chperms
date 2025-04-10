PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
STRIP := strip

ifndef VERBOSE
V := @
endif

OPTFLAGS := -O2 -flto
CFLAGS := -Wall -Wextra -Werror -std=gnu99

all: $(PKGNAME)

$(PKGNAME): $(PKGNAME).c
	@printf " \033[1;32mCC\033[0m %s\n" "$(PKGNAME)"
	$(V)$(CC) -fstack-protector-all $(CFLAGS) $(LDFLAGS) $(OPTFLAGS) -o $(PKGNAME) $(PKGNAME).c

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
	@printf "Cleaning up...\n"
	$(V)rm -f $(PKGNAME) $(PKGNAME).o
