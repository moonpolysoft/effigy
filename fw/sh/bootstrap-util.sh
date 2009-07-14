#! /bin/sh

fw_source "fw-exec.sh" "sh/fatal.sh"
fw_source "fw-exec.sh" "sh/fw-find.sh"

#---------------------------------------------------------------------
#                       bootstrap_link_optional                       
# 
# Arguments:
# 
# $1: source of link
# $2: directory of target link
# $3: basename of target link
#---------------------------------------------------------------------

bootstrap_link_optional () \
  {
    local file
    local ignore

    fw_find "$1" file
    fw_find "revision/$revision/ignore-files" ignore

    test -e "$2/$3" ||                                          \
    test -z "$file" ||                                          \
    (
      cd "$2" &&                                                \
      ln -sf "$file" "$3" &&                                    \
      test -n "$ignore" &&                                      \
      "$ignore" "$3"                                            \
    ) 
  }
