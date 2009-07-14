#! /bin/sh

ERL_CRASH_DUMP=${ERL_CRASH_DUMP-"/dev/null"}
export ERL_CRASH_DUMP

command="$1"
shift

trap 'trap - EXIT; rm -f .flass; exit 1' INT QUIT TERM 
trap 'rm -f .flass' EXIT
touch .flass

case $command in
  ./module-*)
    module=${command#./module-}

    erl +A 10 -sname $$ -pa ../src -eval '
      Module = list_to_atom (hd (init:get_plain_arguments ())),
      { value, { exports, E } } = lists:keysearch (exports,
                                                   1,
                                                   Module:module_info ()),
      case lists:member ({ test, 0 }, E) of
        true -> ok;
        false -> io:format ("error, ~p:test/0 not exported; " ++
                            "possibly you do not have eunit installed~n",
                            [ Module ]),
                 halt (77)
      end,
      cover:compile_beam_directory ("../src"),
      io:format ("~p:test () ...", [ Module ]),
      ok = Module:test (),
      cover:analyse_to_file (Module).
    ' -noshell -s init stop -extra "$module" 2>&1 > $module.test.out || exit $?

  ;;
  *)
    "$command" "$@" || exit $?
  ;;
esac

find . -name '*.COVER.out' -and -newer .flass -print | \
  perl -MIO::File -lne 'chomp;
                       $fh = new IO::File $_, "r" or die $!;
                       my @lines = grep { ! / 0\.\.\|  -module \(/ } <$fh>;
                       my $bad = grep / 0\.\.\|/, @lines;
                       my $total = scalar @lines;
                       my $perc = int (100 * (1.0 - ($bad / $total)));
                       print "$perc% of $total lines covered in $_"'

# find . -name '*.COVER.out' -and -newer .flass -print | \
# xargs grep -n -H -A2 -B2 '0\.\.\|'
