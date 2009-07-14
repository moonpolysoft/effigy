SUBDIRS = NAME

CLEANFILES =

MAINTAINERCLEANFILES = 	\
  Makefile.am		\
  Makefile.in		\
  NAME

EXTRA_DIST =		\
  @FW_TEMPLATE_TEMPLATE_TYPE@

dist-hook:
	find "$(distdir)/@FW_TEMPLATE_TEMPLATE_TYPE@" -type d -name CVS | xargs rm -rf
	rm -rf "$(distdir)/NAME"

include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
include $(top_srcdir)/fw.local/template/Makefile.am.local
