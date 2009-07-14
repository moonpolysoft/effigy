-module (find_start_module).
-export ([ main/1 ]).

is_application ([]) -> false;
is_application ([ { attribute, _, behaviour, [ application ] } | _ ]) -> true;
is_application ([ { attribute, _, behavior, [ application ] } | _ ]) -> true;
is_application ([ _ | Rest ]) -> is_application (Rest).

is_skipped ([]) -> false;
is_skipped ([ { attribute, _, fwskip, _ } | _ ]) -> true;
is_skipped ([ _ | Rest ]) -> is_skipped (Rest).

find_start_module (_, []) -> 
  ok;
find_start_module (Dir, [ F | Rest ]) ->
  case compile:file (F, [ binary, 'E', { outdir, Dir } ]) of
    { ok, Mod, { Mod, _, Forms } } ->
      case is_application (Forms) and not is_skipped (Forms) of
        true ->
          port_command (get (three), io_lib:format ("~p~n", [ Mod ]));
        false ->
          find_start_module (Dir, Rest)
      end;
    _ ->
      find_start_module (Dir, Rest)
  end.

main ([ Dir | Rest ]) ->
  ok = file:make_dir (Dir),

  try
    Three = open_port ({ fd, 0, 3 }, [ out ]),
    % ugh ... don't want to have to change all these function signatures,
    % so i'm gonna be dirty
    put (three, Three),
    find_start_module (Dir, Rest)
  after
    { ok, FileNames } = file:list_dir (Dir),
    lists:foreach (fun (F) -> file:delete (Dir ++ "/" ++ F) end, FileNames),
    file:del_dir (Dir)
  end;
main ([]) ->
  Port = open_port ({ fd, 0, 2 }, [ out ]),
  port_command (Port, "usage: find-modules.esc tmpdir filename [filename ...]\n"),
  halt (1).
