# Variables
PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
OS := $(shell uname -s)
STRIP := strip

ifndef VERBOSE
	Q := @
endif

# Flags
OPTFLAGS += -O2
ifdef MARCHNATIVE
	OPTFLAGS += -march=native
endif
ifdef LTO
	OPTFLAGS += -flto
endif
ifdef LLD
	OPTFLAGS += -fuse-ld=lld
endif
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
