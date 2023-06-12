# Variables
PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
OS := $(shell uname -s)

HASGCC := $(shell command -v gcc 2> /dev/null)
ifdef HASGCC
	TMP_CC := gcc
else
	HASCLANG := $(shell command -v clang 2> /dev/null)
	ifdef HASCLANG
		TMP_CC := clang
	else
		HASCC := $(shell command -v cc 2> /dev/null)
		ifdef HASCC
			TMP_CC := cc
		endif
	endif
endif

HASSTRIP := $(shell command -v strip 2> /dev/null)
ifdef HASSTRIP
	TMP_STRIP := strip
endif

ifdef CROSS_COMPILE
	HASGCC := $(shell command -v $(CROSS_COMPILE)-gcc 2> /dev/null)
	ifdef HASGCC
		TMP_CC := $(CROSS_COMPILE)-gcc
	else
		HASCLANG := $(shell command -v $(CROSS_COMPILE)-clang 2> /dev/null)
		ifdef HASCLANG
			TMP_CC := $(CROSS_COMPILE)-clang
		else
			HASCC := $(shell command -v $(CROSS_COMPILE)-cc 2> /dev/null)
			ifdef HASCC
				TMP_CC := $(CROSS_COMPILE)-cc
			endif
		endif
	endif

	HASSTRIP := $(shell command -v $(CROSS_COMPILE)-strip 2> /dev/null)
	ifdef HASSTRIP
		TMP_STRIP := $(CROSS_COMPILE)-strip
	endif
endif

CC := $(TMP_CC)
STRIP := $(TMP_STRIP)

ifndef CC
	$(error No C compiler found)
endif
ifndef STRIP
	$(error No strip found)
endif

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
CFLAGS += -Wall -Wextra -Werror -std=gnu99

all: $(PKGNAME)

$(PKGNAME): $(PKGNAME).c
	$(Q)$(MAKE) -C liboldworld/src CROSS_COMPILE=$(CROSS_COMPILE)
	@printf " \033[1;32mCC\033[0m $(PKGNAME).c\n"
	$(Q)$(CC) $(CFLAGS) $(OPTFLAGS) -o $(PKGNAME) $(PKGNAME).c -Lliboldworld -loldworld
	$(Q)$(STRIP) $(PKGNAME)

debug: $(PKGNAME).c
	$(Q)$(MAKE) -C liboldworld/src debug CROSS_COMPILE=$(CROSS_COMPILE)
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
