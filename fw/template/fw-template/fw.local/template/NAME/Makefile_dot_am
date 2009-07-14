SUBDIRS = 

templatedir = $(prefix)/share/fw/template/@FW_TEMPLATE_TEMPLATE_TYPE@

dist_template_SCRIPTS =			\
  bootstrap				\
  init					\
  load-config				\
  make-dist				\
  release-ok				\
  source-install

install-data-hook:
	find "$(DESTDIR)$(templatedir)" -type f | xargs chmod -w

noinst_DATA =				\
  $(dist_template_SCRIPTS:%=.%.script_ok)

CLEANFILES =				\
  $(wildcard .*.script_ok)

MAINTAINERCLEANFILES = 			\
  Makefile.am				\
  Makefile.in

EXTRA_DIST =

include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
include $(top_srcdir)/fw.local/template/NAME/Makefile.am.local
