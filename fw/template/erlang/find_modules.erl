-module (find_modules).
-export ([ main/1 ]).

is_skipped ([]) -> false;
is_skipped ([ { attribute, _, fwskip, _ } | _ ]) -> true;
is_skipped ([ _ | Rest ]) -> is_skipped (Rest).

print_module (Dir, F) ->
  case compile:file (F, [ binary, 'E', { outdir, Dir } ]) of
    { ok, Mod, { Mod, _, Forms } } ->
      case is_skipped (Forms) of
        true ->
          ok;
        false ->
          port_command (get (three), io_lib:format ("~p~n", [ Mod ]))
      end;
    _ ->
      ok
  end.

main ([ Dir | Rest ]) ->
  ok = file:make_dir (Dir),

  try
    Three = open_port ({ fd, 0, 3 }, [ out ]),
    % ugh ... don't want to have to change all these function signatures,
    % so i'm gonna be dirty
    put (three, Three),
    lists:foreach (fun (F) -> print_module (Dir, F) end, Rest)
  after
    { ok, FileNames } = file:list_dir (Dir),
    lists:foreach (fun (F) -> file:delete (Dir ++ "/" ++ F) end, FileNames),
    file:del_dir (Dir)
  end;
main ([]) ->
  Port = open_port ({ fd, 0, 2 }, [ out ]),
  port_command (Port, "usage: find-modules.esc tmpdir filename [filename ...]\n"),
  halt (1).
