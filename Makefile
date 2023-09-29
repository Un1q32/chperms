PKGNAME := chperms
PREFIX := /usr/local
BINDIR := $(PREFIX)/bin
STRIP := llvm-strip
CC := clang

ifdef VERBOSE
	SHELL += -x
endif

OPTFLAGS := -O2 -march=native -flto
CFLAGS := -Wall -Wextra -Werror -std=gnu99
LDFLAGS := -fuse-ld=lld -lpthread

all: release

release:
	@printf " \033[1;32mCC\033[0m %s\n" "$(PKGNAME).c"
	@$(CC) $(CFLAGS) $(OPTFLAGS) -c $(PKGNAME).c
	@printf " \033[1;34mLD\033[0m %s\n" "$(PKGNAME)"
	@$(CC) $(LDFLAGS) $(OPTFLAGS) -o $(PKGNAME) $(PKGNAME).o
	@$(STRIP) $(PKGNAME)

debug:
	@printf " \033[1;35mCC\033[0m %s\n" "$(PKGNAME).c"
	@$(CC) $(CFLAGS) -g -c $(PKGNAME).c
	@printf " \033[1;34mLD\033[0m %s\n" "$(PKGNAME)"
	@$(CC) $(LDFLAGS) -g -o $(PKGNAME) $(PKGNAME).o

install: $(PKGNAME)
	@printf "Installing...\n"
	@printf "%s\n" "$(PKGNAME) -> $(DESTDIR)$(BINDIR)"
	@install -D $(PKGNAME) $(DESTDIR)$(BINDIR)/$(PKGNAME)
	@chmod 6755 $(DESTDIR)$(BINDIR)/$(PKGNAME)

uninstall:
	@printf "Uninstalling...\n"
	@$(RM) -f $(DESTDIR)$(BINDIR)/$(PKGNAME)

clean:
	@printf "Cleaning...\n"
	@rm -f $(PKGNAME) $(PKGNAME).o
