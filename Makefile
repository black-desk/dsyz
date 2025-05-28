# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: Chen Linxuan <me@black-desk.cn>

DESTDIR ?=

prefix      ?= /usr/local
bindir      ?= $(prefix)/bin
libdir      ?= $(prefix)/lib
libexecdir  ?= $(prefix)/libexec
datarootdir ?= $(prefix)/share

INSTALL         ?= install
INSTALL_PROGRAM ?= $(INSTALL)
INSTALL_DATA    ?= $(INSTALL) -m 644

SHELL = sh

.PHONY: all
all:
	@echo "Nothing to do."

.PHONY: install-bin
install-bin:
	$(INSTALL) -d "$(DESTDIR)$(bindir)"
	$(INSTALL_PROGRAM) ./bin/dsyz "$(DESTDIR)$(bindir)"/dsyz
	$(INSTALL_PROGRAM) ./bin/dsyz-deepin "$(DESTDIR)$(bindir)"/dsyz-deepin
	$(INSTALL_PROGRAM) ./bin/dsyz-arch "$(DESTDIR)$(bindir)"/dsyz-arch

.PHONY: install
install: install-bin
