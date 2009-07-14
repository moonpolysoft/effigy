AC_DEFUN([FW_TEMPLATE_FW_BUILD],
[
dnl TODO: This seems like a fragile way to compute the build_type

  FW_BUILD_BUILD_TYPE=`perl -ne 'm/--build_type (\S+)/ && print [$]1' bootstrap`
  FW_SUBST_PROTECT(FW_BUILD_BUILD_TYPE)

  AC_CONFIG_FILES([fw.local/Makefile
                   fw.local/build/Makefile
                   fw.local/build/NAME/Makefile])
])
