AC_DEFUN([FW_SUBST_PROTECT],
[
  $1=`perl -e 'chomp $ARGV[[0]]; $ARGV[[0]] =~ s%\n% %gs; print $ARGV[[0]];' -- "$$1"`
  AC_SUBST($1)
])
