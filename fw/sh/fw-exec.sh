#! /bin/sh

fw_source "fw-exec.sh" "sh/fatal.sh"
fw_source "fw-exec.sh" "sh/fw-find.sh"

fw_exec () \
  {
    local cmd

    fw_find "$1" cmd

    test -z "$cmd" && {
      echo "fw_exec: error: can't find $1" 1>&2
      fatal "fw_exec"
    }

    shift
    "$cmd" "$@"
  }
