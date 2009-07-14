#! /bin/sh

fw_source "fw-exec.sh" "sh/fatal.sh"

detect_revision () \
  {
    local _dr_rt
    local _dr_x

    test -z "$1" && return 1

    _dr_rt="none"
    for _dr_x in `find fw/revision -mindepth 2 -maxdepth 2 -name detect`      \
                 `find fw.local/revision -mindepth 2 -maxdepth 2 -name detect \
                  2>/dev/null`                                                \
                 `find $FW_ROOT/share/fw.local/revision -mindepth 2           \
                  -maxdepth 2 -name detect 2>/dev/null`
      do
        if "$_dr_x"
          then
            _dr_rt=`echo "$_dr_x" | 
                    perl -ne 'm%revision/([^/]+)/detect% && print $1'`
          fi
      done

    eval $1=\$_dr_rt

    return 0
  }
