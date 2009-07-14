AC_DEFUN([FW_TEMPLATE_ERLANG_CHECK_MODULE],
[
  AC_MSG_CHECKING([for erlang module $1])
  ERL_CRASH_DUMP="/dev/null" erl -eval "$1:module_info ()" -noshell -noinput -s erlang halt 2>/dev/null >/dev/null
  if test $? = 0
    then
      AC_MSG_RESULT([yes])
      $2
    else
      AC_MSG_RESULT([no])
      $3
    fi
])
