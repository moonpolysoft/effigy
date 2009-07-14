#! /bin/sh

fatal () \
  {
    local fatal_var

    fw_source_var_guard fatal_var "sh/parse-args.sh"

    test -z "${FW_TRACE}" && eval test ! -z \"\$$fatal_var\" && {
      echo "$1: fatal: use --trace to get detailed output" 1>&2
      echo "$1: fatal: use --help to get usage information" 1>&2
    }
    exit 1
  }
