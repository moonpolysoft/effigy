SUBDIRS =

packagehookdir=$(libexecdir)/fw/@FW_PACKAGE_NAME@-@FW_PACKAGE_VERSION@

dist_packagehook_SCRIPTS =			\
  post-install					\
  post-remove					\
  pre-install					\
  pre-remove					\
  start						\
  stop

noinst_DATA =					\
  $(dist_packagehook_SCRIPTS:%=.%.script_ok)

CLEANFILES =

MAINTAINERCLEANFILES =				\
  Makefile.am					\
  Makefile.in

EXTRA_DIST = 					\
  config

include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
include $(top_srcdir)/fw-pkgin/Makefile.am.local
