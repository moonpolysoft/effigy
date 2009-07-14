SUBDIRS =

check_SCRIPTS = 		\
  $(patsubst %.erl, %.beam, $(wildcard *.erl))

CLEANFILES = 			\
  .flass			\
  $(wildcard module-*) 		\
  $(wildcard *.test.out) 	\
  $(wildcard *.COVER.out)	\
  $(check_SCRIPTS)

MAINTAINERCLEANFILES = 		\
  Makefile.am			\
  Makefile.in			\
  otp-test-wrapper.sh

TESTS_ENVIRONMENT = ./otp-test-wrapper.sh

EXTRA_DIST = 			\
  otp-test-wrapper.sh		\
  $(wildcard *.erl)

module-%: 
	@touch $@

include $(top_srcdir)/Makefile.otp
include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
include $(top_srcdir)/tests/Makefile.am.local
