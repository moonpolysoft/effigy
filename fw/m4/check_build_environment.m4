AC_DEFUN([FW_CHECK_BUILD_ENVIRONMENT],
[
  AC_REQUIRE([FW_DETECT_NATIVE_PACKAGE])

  if test "$FW_NATIVE_PACKAGE_TYPE" != none
    then
      AC_MSG_CHECKING([for build dependencies])

      path="package/$FW_NATIVE_PACKAGE_TYPE/check-build-environment"
      fw-exec "$path" --template "$FW_TEMPLATE" || exit 1

      AC_MSG_RESULT([ok])
    fi
])
