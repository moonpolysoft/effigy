#! /bin/sh

fw_source "validate-args.sh" "sh/fatal.sh"

validate_args () \
  {
    for x in $2
      do
        if eval test -z \"\$$x\"
          then
            echo "$1: error: $x not specified" 1>&2
            fatal "$1"
          fi
      done

    for x in $3
      do
        eval test -d \"\${FW_ROOT}/share/fw/$x/\$$x/\"          ||      \
        eval test -d \"\${FW_ROOT}/share/fw.local/$x/\$$x/\"    ||      \
        eval test -d \"fw/$x/\$$x/\"                            ||      \
        eval test -d \"fw.local/$x/\$$x/\"                      || {
          eval echo \"$1: error: unknown $x \$$x\"   1>&2
          printf "$1: error: supported values are: " 1>&2
          (
            (
              cd "fw/$x" 2>/dev/null || cd "${FW_ROOT}/share/fw/$x"
              find . -maxdepth 1 -mindepth 1 -type d | sort | \
              perl -pe 's%\./%%; s%\n% %;' 
            )
            (
              cd "fw.local/$x" 2>/dev/null &&                     \
              find . -maxdepth 1 -mindepth 1 -type d | sort | \
              perl -pe 's%\./%%; s%\n% %;'
            )
            echo
          ) 1>&2
          fatal "$1"
        }
      done
  }
