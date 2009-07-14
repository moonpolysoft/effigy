SUBDIRS =

.run_edoc: overview.edoc $(wildcard ../src/*.erl)
	(cd .. && erl -eval 'edoc:application (@FW_PACKAGE_NAME@, ".", [ @FW_EDOC_OPTIONS@ ])' -noshell -s init stop)
	@touch $@

noinst_DATA =			\
  .run_edoc

dist_erldoc_DATA = 		\
  $(wildcard *.css)		\
  $(wildcard *.png)		\
  $(wildcard *.html)

CLEANFILES =			\
  .run_edoc			\
  edoc-info			\
  $(wildcard *.css)		\
  $(wildcard *.html)		\
  $(wildcard *.png)

MAINTAINERCLEANFILES = 		\
  Makefile.am			\
  Makefile.in

EXTRA_DIST =			\
  overview.edoc

include $(top_srcdir)/Makefile.otp
include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
include $(top_srcdir)/doc/Makefile.am.local
