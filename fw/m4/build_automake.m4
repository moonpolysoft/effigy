AC_DEFUN([FW_BUILD_AUTOMAKE],
[
  AC_REQUIRE([FW_DETECT_REVISION])
  AC_REQUIRE([FW_DETECT_NATIVE_PACKAGE])
  AC_REQUIRE([FW_CHECK_BUILD_ENVIRONMENT])

  FW_PACKAGE_MAJOR_VERSION=`echo "${FW_PACKAGE_VERSION}" | perl -ne 'm/(\d+)\.(\d+)\.(\d+)/ && print [$]1'`
  FW_SUBST_PROTECT([FW_PACKAGE_MAJOR_VERSION])

  FW_PACKAGE_MINOR_VERSION=`echo "${FW_PACKAGE_VERSION}" | perl -ne 'm/(\d+)\.(\d+)\.(\d+)/ && print [$]2'`
  FW_SUBST_PROTECT([FW_PACKAGE_MINOR_VERSION])

  AC_CHECK_PROGS(FW_LDD, [ ldd otool ], true)

  if test "$FW_LDD" = otool
    then
      FW_LDD_ARGS="-L"
    else
      FW_LDD_ARGS=""
    fi

  FW_SUBST_PROTECT([FW_LDD_ARGS])

  AC_PATH_PROGS(CHECK_SHELL,[ dash ash sh ], echo)
  FW_SUBST_PROTECT([CHECK_SHELL])

  FW_SUBST_PROTECT([FW_BUILD_AUTOMAKE_CREATE_PACKAGE_EXTRA_ARGS])

  AC_CONFIG_FILES([Makefile
                   fw-pkgin/Makefile])
])
