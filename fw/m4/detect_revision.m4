AC_DEFUN([FW_DETECT_REVISION],
[
  AC_MSG_CHECKING([for revision control type])

  if test -z "$FW_REVISION_TYPE"
    then
      FW_REVISION_TYPE="none"
      for x in `find fw/revision -mindepth 2 -maxdepth 2 -name detect`      \
               `find fw.local/revision -mindepth 2 -maxdepth 2 -name detect \
                2>/dev/null`
        do
          if "$x"
            then
              FW_REVISION_TYPE=`echo "$x" | 
                                perl -ne 'm%revision/([[^/]]+)/detect% && 
                                          print [$]1'`
            fi
        done

      AC_MSG_RESULT([$FW_REVISION_TYPE (autodetected)])
    else
      AC_MSG_RESULT([$FW_REVISION_TYPE (forced)])
    fi

  FW_ARG_VAR([FW_REVISION_TYPE], 
             [revision control type (default: auto detect)])
])
