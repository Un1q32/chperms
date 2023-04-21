# Variables
PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
OS := $(shell uname -s)
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
CFLAGS += -Wall -Wextra -Wpedantic -Werror -std=gnu99 -fPIC -g -Iliboldworld/src

all: $(PKGNAME) liboldworld/liboldworld.a

$(PKGNAME): liboldworld/liboldworld.a $(PKGNAME).c
	@printf " \033[1;32mCC\033[0m $(PKGNAME).c\n"
	$(Q)$(CC) $(CFLAGS) $(OPTFLAGS) -o $(PKGNAME) $(PKGNAME).c -Lliboldworld -loldworld

liboldworld/liboldworld.a:
	$(Q)$(MAKE) -C liboldworld CC=$(CC) LTO=$(LTO) MARCHNATIVE=$(MARCHNATIVE) VERBOSE=$(VERBOSE) AR=$(AR)

install:
	@printf "Installing...\n"
	@printf "%s\n" "$(PKGNAME) -> $(DESTDIR)$(BINDIR)"
	$(Q)$(INSTALL) -o root -Dm6755 $(PKGNAME) $(DESTDIR)$(BINDIR)/$(PKGNAME)

uninstall:
	@printf "Uninstalling...\n"
	$(Q)$(RM) -f $(DESTDIR)$(BINDIR)/$(PKGNAME)

clean:
	@printf "Cleaning...\n"
	$(Q)$(RM) -f chperms *.snalyzerinfo *.analyzerinfo liboldworld/liboldworld.* liboldworld/src/*.o
