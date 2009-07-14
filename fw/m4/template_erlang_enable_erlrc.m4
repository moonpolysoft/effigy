AC_DEFUN([FW_TEMPLATE_ERLANG_ENABLE_ERLRC],
[
  AC_ARG_ENABLE(erlrc,
                [  --disable-erlrc         disable packaging hooks for erlrc integration],
                [case "${enableval}" in
                  yes) FW_ERLANG_ENABLE_ERLRC=1 ;;
                  no) FW_ERLANG_ENABLE_ERLRC=0 ;;
                  *) AC_MSG_ERROR([bad value ${enableval} for --enable-coverage]) ;;
                esac],
                [FW_ERLANG_ENABLE_ERLRC=${FW_ERLANG_ENABLE_ERLRC_DEFAULT-2}])

  FW_BUILD_AUTOMAKE_CREATE_PACKAGE_EXTRA_ARGS="$FW_BUILD_AUTOMAKE_CREATE_PACKAGE_EXTRA_ARGS --erlrc $FW_ERLANG_ENABLE_ERLRC"

  AM_CONDITIONAL([FW_ERLANG_WANT_ERLRC],
                 [test "x$FW_ERLANG_ENABLE_ERLRC" != x0])

  if test "x$FW_ERLANG_ENABLE_ERLRC" != x0
    then
      AC_MSG_NOTICE([enabling erlrc integration])
    else
      AC_MSG_NOTICE([disabling erlrc integration])
    fi
])
