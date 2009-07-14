#! /bin/sh

fw_find () \
  {
    eval $2=\"\"
    test -f "${FW_ROOT}/share/fw/$1" && eval $2=\"\${FW_ROOT}/share/fw/\$1\"
    test -f "${FW_ROOT}/share/fw.local/$1" && eval $2=\"\${FW_ROOT}/share/fw.local/\$1\"
    test -f "fw/$1" && eval $2=\"\`pwd\`/fw/\$1\"
    test -f "fw.local/$1" && eval $2=\"\`pwd\`/fw.local/\$1\"
  }

fw_source_var_guard () \
  {
    eval $1=\`echo \"\$2\" \| perl -pe \''chomp; s%\W%_%g; tr%a-z%A-Z%; s%^%FW_%;'\'\`
  }

fw_source () \
  {
    local fw_source_file
    local fw_source_var

    fw_source_var_guard fw_source_var "$2"

    eval test ! -z \"\$$fw_source_var\" || {
      fw_find "$2" fw_source_file
      if test -z "$fw_source_file"
        then
          echo "$1: fw_source: error: can't find $2" 1>&2
          fatal "$1"
        else
          . "$fw_source_file"
          eval $fw_source_var=1
        fi
    }
  }
