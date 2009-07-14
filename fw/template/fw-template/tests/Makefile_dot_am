SUBDIRS = 

check_SCRIPTS = 	\
  test-template

check_DATA =		\
  $(check_SCRIPTS:%=.%.script_ok)

TESTS =			\
  $(check_SCRIPTS)

CLEANFILES = 		\
  test-template		\
  test-template.out

MAINTAINERCLEANFILES =	\
  Makefile.am		\
  Makefile.in

EXTRA_DIST =

include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
include $(top_srcdir)/tests/Makefile.am.local
