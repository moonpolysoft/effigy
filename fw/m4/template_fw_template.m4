AC_DEFUN([FW_TEMPLATE_FW_TEMPLATE],
[
dnl TODO: This seems like a fragile way to compute the template_type

  FW_TEMPLATE_TEMPLATE_TYPE=`perl -ne 'm/--template_type (\S+)/ && print [$]1' bootstrap`
  FW_SUBST_PROTECT(FW_TEMPLATE_TEMPLATE_TYPE)

  test -e fw.local/template/NAME || (cd fw.local/template && ln -s "$FW_TEMPLATE_TEMPLATE_TYPE" NAME)

  AC_CONFIG_FILES([fw.local/Makefile
                   fw.local/template/Makefile
                   fw.local/template/NAME/Makefile
                   tests/Makefile])

  AC_CONFIG_FILES([tests/test-template],
                  [chmod +x tests/test-template])
])
