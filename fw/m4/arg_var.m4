AC_DEFUN([FW_ARG_VAR],
[
  $1=`perl -e 'chomp $ARGV[[0]]; $ARGV[[0]] =~ s%\n% %gs; print $ARGV[[0]];' -- "$$1"`
  AC_ARG_VAR([$1], [$2])
])
