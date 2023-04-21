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
CFLAGS += -Wall -Wextra -Wpedantic -Werror -std=gnu99 -fPIC -g

LOWOBJS := $(patsubst liboldworld/src/%.c,liboldworld/src/%.o,$(wildcard liboldworld/src/*.c))

all: $(PKGNAME) liboldworld/liboldworld.a

$(PKGNAME): liboldworld/liboldworld.a $(PKGNAME).c
	@printf " \033[1;32mCC\033[0m $(PKGNAME).c\n"
	$(Q)$(CC) $(CFLAGS) $(OPTFLAGS) -o $(PKGNAME) $(PKGNAME).c -Lliboldworld -loldworld -Iliboldworld/src

liboldworld/liboldworld.a: $(LOWOBJS)
	@printf " \033[1;34mAR\033[0m liboldworld.a\n"
	@$(AR) -r liboldworld/liboldworld.a $(LOWOBJS)

liboldworld/src/%.o: liboldworld/src/%.c
	@printf " \033[1;32mCC\033[0m %s\n" "liboldworld/$(patsubst liboldworld/src/%,%,$<)"
	$(Q)$(CC) $(CFLAGS) $(OPTFLAGS) -c -o $@ $<

install:
	@printf "Installing...\n"
	@printf "%s\n" "$(PKGNAME) -> $(DESTDIR)$(BINDIR)"
	$(Q)install -D $(PKGNAME) $(DESTDIR)$(BINDIR)/$(PKGNAME)
	$(Q)$(STRIP) $(DESTDIR)$(BINDIR)/$(PKGNAME)
	$(Q)chown root:root $(DESTDIR)$(BINDIR)/$(PKGNAME)
	$(Q)chmod 6755 $(DESTDIR)$(BINDIR)/$(PKGNAME)

uninstall:
	@printf "Uninstalling...\n"
	$(Q)$(RM) -f $(DESTDIR)$(BINDIR)/$(PKGNAME)

clean:
	@printf "Cleaning...\n"
	$(Q)$(RM) -f chperms *.snalyzerinfo *.analyzerinfo liboldworld/liboldworld.* liboldworld/src/*.o
