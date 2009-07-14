-module (find_registered).
-export ([ main/1 ]).

%% looks like fun_clauses are the same as clauses (?)
print_registered_fun_clauses (Clauses) ->
  print_registered_clauses (Clauses).

%% looks like icr_clauses are the same as clauses (?)
print_registered_icr_clauses (Clauses) ->
  print_registered_clauses (Clauses).

print_registered_inits (Inits) ->
  lists:foreach (fun ({ record_field, _, _, E }) ->
                   print_registered_expr (E);
                     (_) ->
                   ok
                 end,
                 Inits).

print_registered_upds (Upds) ->
  lists:foreach (fun ({ record_field, _, _, E }) ->
                   print_registered_expr (E);
                     (_) ->
                   ok
                 end,
                 Upds).

% hmmm ... pretty sure patterns are not supposed to have side-effects ...
print_registered_pattern (_) -> ok.
print_registered_pattern_group (_) -> ok.

print_registered_quals (Qs) ->
  lists:foreach (fun ({ generate, _, P, E }) ->
                   print_registered_pattern (P),
                   print_registered_expr (E);
                     ({ b_generate, _, P, E }) ->
                   print_registered_pattern (P),
                   print_registered_expr (E);
                     (E) ->
                   print_registered_expr (E)
                 end,
                 Qs).

print_registered_expr ({ cons, _, H, T }) ->
  print_registered_expr (H),
  print_registered_expr (T);
print_registered_expr ({ lc, _, E, Qs }) ->
  print_registered_expr (E), 
  print_registered_quals (Qs);
print_registered_expr ({ bc, _, E, Qs }) ->
  print_registered_expr (E), 
  print_registered_quals (Qs);

%% Ok, here's some meat:
%% the "supervisor child spec" rule
%% { _, start, [ { local, xxx }, ... ] } -> xxx being registered
%% { _, start_link, [ { local, xxx }, ... ] } -> xxx being registered
print_registered_expr ({ tuple, _,
                         Exprs=[ _,
                           { atom, _, Func },
                           { cons, 
                             _, 
                             { tuple, _, [ { atom, _, local }, 
                                           { atom, _, Name } ] },
                             _ } ] }) when (Func =:= start) or
                                           (Func =:= start_link) ->
  port_command (get (three), io_lib:format ("~p~n", [ Name ])),
  print_registered_exprs (Exprs);

print_registered_expr ({ tuple, _, Exprs }) ->
  print_registered_exprs (Exprs);
print_registered_expr ({ record_index, _, _, E }) ->
  print_registered_expr (E);
print_registered_expr ({ record, _, _, Inits }) ->
  print_registered_inits (Inits);
print_registered_expr ({ record_field, _, E0, _, E1 }) ->
  print_registered_expr (E0),
  print_registered_expr (E1);
print_registered_expr ({ record, _, E, _, Upds }) ->
  print_registered_expr (E),
  print_registered_upds (Upds);
print_registered_expr ({ record_field, _, E0, E1 }) ->
  print_registered_expr (E0),
  print_registered_expr (E1);
print_registered_expr ({ block, _, Exprs }) ->
  print_registered_exprs (Exprs);
print_registered_expr ({ 'if', _, IcrClauses }) ->
  print_registered_icr_clauses (IcrClauses);
print_registered_expr ({ 'case', _, E, IcrClauses }) ->
  print_registered_expr (E),
  print_registered_icr_clauses (IcrClauses);
print_registered_expr ({ 'receive', _, IcrClauses }) ->
  print_registered_icr_clauses (IcrClauses);
print_registered_expr ({ 'receive', _, IcrClauses, E, Exprs }) ->
  print_registered_icr_clauses (IcrClauses),
  print_registered_expr (E),
  print_registered_exprs (Exprs);
print_registered_expr ({ 'try', _, Exprs0, IcrClauses0, IcrClauses1, Exprs1 }) ->
  print_registered_exprs (Exprs0),
  print_registered_icr_clauses (IcrClauses0),
  print_registered_icr_clauses (IcrClauses1),
  print_registered_exprs (Exprs1);
print_registered_expr ({ 'fun', _, Body }) ->
  case Body of
    { clauses, Cs } ->
      print_registered_fun_clauses (Cs);
    _ ->
      ok
  end;

%% Ok, here's some meat:
%% Module:start ({ local, xxx }, ...) -> xxx being registered
%% Module:start_link ({ local, xxx }, ...) -> xxx being registered

print_registered_expr ({ call, 
                         _, 
                         E={ remote, _, _, { atom, _, Func } },
                         Exprs=[ { tuple, _, [ { atom, _, local },
                                               { atom, _, Name } ] } | _ ] })
                            when (Func =:= start) or
                                 (Func =:= start_link) ->
  port_command (get (three), io_lib:format ("~p~n", [ Name ])),
  print_registered_expr (E),
  print_registered_exprs (Exprs);

%% Ok, here's some meat:
%% erlang:register (xxx, ...) -> xxx being registered

print_registered_expr ({ call, 
                         _,
                         { remote, 
                           _, 
                           { atom, _, erlang }, 
                           { atom, _, register } },
                         Exprs=[ { atom, _, Name } | _ ] }) ->
  port_command (get (three), io_lib:format ("~p~n", [ Name ])),
  print_registered_exprs (Exprs);

print_registered_expr ({ call, _, E, Exprs }) ->
  print_registered_expr (E),
  print_registered_exprs (Exprs);
print_registered_expr ({ 'catch', _, E }) ->
  print_registered_expr (E);
print_registered_expr ({ 'query', _, E }) ->
  print_registered_expr (E);
print_registered_expr ({ match, _, P, E }) ->
  print_registered_pattern (P),
  print_registered_expr (E);
print_registered_expr ({ bin, _, PatternGrp }) ->
  print_registered_pattern_group (PatternGrp);
print_registered_expr ({ op, _, _, E }) ->
  print_registered_expr (E);
print_registered_expr ({ op, _, _, E0, E1 }) ->
  print_registered_expr (E0),
  print_registered_expr (E1);
print_registered_expr ({ remote, _, E0, E1 }) ->
  print_registered_expr (E0),
  print_registered_expr (E1);
print_registered_expr (_) ->
  ok.

print_registered_exprs (Exprs) ->
  lists:foreach (fun (E) -> print_registered_expr (E) end, Exprs).

print_registered_clauses (Clauses) ->
  lists:foreach (fun ({ clause, _, _, _, Exprs }) ->
                   print_registered_exprs (Exprs);
                     (_) ->
                   ok
                 end,
                 Clauses).

print_registered_forms (Forms) ->
  lists:foreach (fun ({ function, _, _, _, Clauses }) -> 
                   print_registered_clauses (Clauses);
                     (_) ->
                   ok
                 end,
                 Forms).

is_skipped ([]) -> false;
is_skipped ([ { attribute, _, fwskip, _ } | _ ]) -> true;
is_skipped ([ _ | Rest ]) -> is_skipped (Rest).

print_registered (Dir, F) ->
  case compile:file (F, [ binary, 'E', { outdir, Dir } ]) of
    { ok, _, { _, _, Forms } } ->
      case is_skipped (Forms) of
        true ->
          ok;
        false ->
          print_registered_forms (Forms)
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
    lists:foreach (fun (F) -> print_registered (Dir, F) end, Rest)
  after
    { ok, FileNames } = file:list_dir (Dir),
    lists:foreach (fun (F) -> file:delete (Dir ++ "/" ++ F) end, FileNames),
    file:del_dir (Dir)
  end;
main ([]) ->
  Port = open_port ({ fd, 0, 2 }, [ out ]),
  port_command (Port, "usage: find-modules.esc tmpdir filename [filename ...]\n"),
  halt (1).
