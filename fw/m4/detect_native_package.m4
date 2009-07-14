AC_DEFUN([FW_DETECT_NATIVE_PACKAGE],
[
  AC_MSG_CHECKING([for native package type])

  if test -z "$FW_NATIVE_PACKAGE_TYPE"
    then
      FW_NATIVE_PACKAGE_TYPE="none"
      for x in `find fw/package -mindepth 2 -maxdepth 2 -name detect`      \
               `find fw.local/package -mindepth 2 -maxdepth 2 -name detect \
                2>/dev/null`
        do
          if "$x"
            then
              FW_NATIVE_PACKAGE_TYPE=`echo "$x" | 
                                      perl -ne 'm%package/([[^/]]+)/detect% && 
                                                print [$]1'`
            fi
        done

      AC_MSG_RESULT([$FW_NATIVE_PACKAGE_TYPE (autodetected)])
    else
      AC_MSG_RESULT([$FW_NATIVE_PACKAGE_TYPE (forced)])
    fi

  AM_CONDITIONAL([FW_HAVE_NATIVE_PACKAGE_TYPE], 
                 [ test "$FW_NATIVE_PACKAGE_TYPE" != "none" ])

  FW_ARG_VAR([FW_NATIVE_PACKAGE_TYPE], 
             [native package type (default: auto detect)])
])
