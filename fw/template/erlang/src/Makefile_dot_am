SUBDIRS =

@FW_PACKAGE_NAME@.app: $(wildcard *.erl) $(wildcard *.hrl) Makefile fw-erl-app-template.app
	@cd @top_srcdir@ && {						\
          if test -d fw/bin;                    			\
            then                                			\
              PATH="`pwd`/fw/bin:$$PATH";       			\
              export PATH;                      			\
	      FW_ROOT="`pwd`/fw";					\
	      export FW_ROOT;						\
	      (cd fw && ln -sf .. share);				\
            fi;                                 			\
          fw-exec template/erlang/make-app-file --top "`pwd`";		\
        }

CLEANFILES =			\
  fw-erl-app-template.app	\
  @FW_PACKAGE_NAME@.app

MAINTAINERCLEANFILES = 		\
  Makefile.am			\
  Makefile.in			\
  fw-erl-app-template.app.in	\
  $(check_DATA)

EXTRA_DIST =			\
  fw-erl-app-template.app.in	\
  $(check_DATA)

include $(top_srcdir)/Makefile.otp
include $(top_srcdir)/fw/build/automake/check-shell.am
include $(top_srcdir)/fw/build/automake/gnu-make-check.am
include $(top_srcdir)/src/Makefile.am.local
