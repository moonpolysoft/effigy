include $(top_srcdir)/fw/build/automake/Makefile_dot_am

SUBDIRS += src doc tests

MAINTAINERCLEANFILES +=			\
  Makefile.otp

if FW_ERLANG_WANT_ERLRC
install-data-hook:
	mkdir -p "${DESTDIR}@ERLRCDIR@/applications"
	touch "${DESTDIR}@ERLRCDIR@/applications/@FW_PACKAGE_NAME@"
endif
