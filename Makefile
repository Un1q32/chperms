# Variables
PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
OS := $(shell uname -s)
ifndef CC
	HASGCC := $(shell command -v $(CROSS_COMPILE)gcc 2> /dev/null)
	ifdef HASGCC
		CC := $(CROSS_COMPILE)gcc
	else
		HASCLANG := $(shell command -v $(CROSS_COMPILE)clang 2> /dev/null)
		ifdef HASCLANG
			CC := $(CROSS_COMPILE)clang
		else
			CC := $(CROSS_COMPILE)cc
		endif
	endif
endif
STRIP := $(CROSS_COMPILE)strip

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
CFLAGS += -Wall -Wextra -Wpedantic -Werror -std=gnu99

all: $(PKGNAME)

$(PKGNAME): $(PKGNAME).c
	$(Q)$(MAKE) -C liboldworld/src
	@printf " \033[1;32mCC\033[0m $(PKGNAME).c\n"
	$(Q)$(CC) $(CFLAGS) $(OPTFLAGS) -o $(PKGNAME) $(PKGNAME).c -Lliboldworld -loldworld
	$(Q)$(STRIP) $(PKGNAME)

debug: $(PKGNAME).c
	$(Q)$(MAKE) -C liboldworld/src debug
	@printf " \033[1;32mCC\033[0m $(PKGNAME).c\n"
	$(Q)$(CC) $(CFLAGS) -g -O0 -DDEBUG -o $(PKGNAME) $(PKGNAME).c -Lliboldworld -loldworld

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
	$(Q)$(RM) -f chperms liboldworld/liboldworld.* liboldworld/src/*.o
