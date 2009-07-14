#! /bin/sh

# unfortunately, escript is a recent innovation ...

ERL_CRASH_DUMP=/dev/null
export ERL_CRASH_DUMP

erl -pa "${FW_ROOT}/share/fw/template/erlang/" -pa "${FW_ROOT}/share/fw.local/template/erlang" -pa "${top_srcdir}/fw/template/erlang/" -pa "${top_srcdir}/fw.local/template/erlang" -noshell -noinput -eval '
  find_start_module:main (init:get_plain_arguments ()),
  halt (0).
' -extra "$@" 3>&1 >/dev/null 
