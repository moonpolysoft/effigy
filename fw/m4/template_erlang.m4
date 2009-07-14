AC_DEFUN([FW_TEMPLATE_ERLANG],
[
  AC_REQUIRE([FW_TEMPLATE_ERLANG_EUNIT_CHECK])
  AC_REQUIRE([FW_TEMPLATE_ERLANG_ENABLE_ERLRC])
  echo "$FW_PACKAGE_NAME" | perl -ne 'm/-/ && exit 1; exit 0'

  if test $? != 0
    then
      AC_MSG_ERROR([sorry, FW_PACKAGE_NAME ($FW_PACKAGE_NAME) cannot contain dashes, modify fw-pkgin/config])
      exit 1
    fi

  AC_ARG_VAR([ERLAPPDIR],
             [application directory (default: $libdir/erlang/lib/$FW_PACKAGE_NAME-$FW_PACKAGE_VERSION)])

  if test "x$ERLAPPDIR" = x
    then
      ERLAPPDIR="\$(libdir)/erlang/lib/\$(FW_PACKAGE_NAME)-\$(FW_PACKAGE_VERSION)"
    fi

  AC_ARG_VAR([ERLDOCDIR],
             [documentation directory (default: $datadir/doc/erlang-doc-html/html/lib/$FW_PACKAGE_NAME-$FW_PACKAGE_VERSION/doc/html)])

  if test "x$ERLDOCDIR" = x
    then
      ERLDOCDIR="\$(datadir)/erlang/lib/\$(FW_PACKAGE_NAME)-\$(FW_PACKAGE_VERSION)/doc/html"
    fi

  AC_ARG_VAR([ERLRCDIR],
             [erlrc configuration directory (default: /etc/erlrc.d)])

  if test "x$ERLRCDIR" = x
    then
      ERLRCDIR="/etc/erlrc.d"
    fi

  AC_CHECK_PROG([ERLC], [erlc], [erlc])

  if test "x$ERLC" = x
    then
      AC_MSG_ERROR([cant find erlang compiler])
      exit 1
    fi

  AC_ARG_VAR(ERLC, [erlang compiler])

  AC_CONFIG_FILES([doc/Makefile
                   src/Makefile
                   tests/Makefile])

  AC_CONFIG_FILES([src/fw-erl-app-template.app])

  FW_SUBST_PROTECT([FW_EDOC_OPTIONS])
  FW_SUBST_PROTECT(ERLCFLAGS)
])
