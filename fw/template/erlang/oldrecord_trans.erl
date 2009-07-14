%% @doc Lower programmer error when using hot code loading.
%% This module looks for attributes of the form 
%% -oldrecord (foo).
%% and enforces the rule that record foo can only be used 
%% inside a code_change/3 handler.  It does not modify the code.
%% @end

% Tests should include:
% 
% 1. (State#state.module):Function (Args),
% 2. foo (State = #state{}) -> bar.
% 3. baz (State) when State#state.foo > State#state.bar -> blorf end.

-module (oldrecord_trans).

-export ([ parse_transform/2 ]).

add_old_record (Name) ->
  case get (oldrecords) of
    undefined ->
      put (oldrecords, [ Name ]);
    L ->
      put (oldrecords, [ Name | L ])
  end.

start_code_change () ->
  put (inside_code_change, true).

end_code_change () ->
  put (inside_code_change, false).

in_code_change () ->
  true =:= get (inside_code_change).

is_old_record (Name) ->
  case get (oldrecords) of
    undefined -> false;
    L -> lists:member (Name, L)
  end.

check_record (Line, Name) ->
  case in_code_change () or not is_old_record (Name) of
    true -> true;
    false -> 
      Stderr = open_port ({ fd, 0, 2 }, [ out ]),
      port_command (Stderr,
                    io_lib:format ("~s:~p: invalid use of record ~p~n", 
                                   [ get (oldrecord_file),
                                     Line, 
                                     Name ])),
      timer:sleep (50),
      halt (1)
  end.

parse_transform (Forms, _Options) ->
  forms (Forms).

forms (Fs) -> 
  [ form (F) || F <- Fs ].

form (F = { attribute, _Line, file, { File, _Line } }) ->
  put (oldrecord_file, File),
  F;
form (F = { attribute, _Line, oldrecord, Name }) ->
  add_old_record (Name),
  F;
form (F = { function, _Line, Name, Arity, Clauses }) ->
  { Name, Arity, Clauses } = function (Name, Arity, Clauses),
  F;
form (F) ->
  F.

function (code_change, 3, Clauses) ->
  start_code_change (),
  Clauses = clauses (Clauses),
  end_code_change (),
  { code_change, 3, Clauses };
function (Name, Arity, Clauses) ->
  Clauses = clauses (Clauses),
  { Name, Arity, Clauses}.

clauses (Cs) ->
  [ clause (C) || C <- Cs ].

clause (C = { clause, _Line, H, G, B }) ->
  H = head (H),
  G = guard (G),
  B = exprs (B),
  C.

head (Ps) -> 
  patterns (Ps).

patterns (Ps) ->
  [ pattern (P) || P <- Ps ].

pattern (P = { match, _Line, L, R }) ->
  L = pattern (L),
  R = pattern (R),
  P;
pattern (P = { cons, _Line, H, T }) ->
  H = pattern (H),
  T = pattern (T),
  P;
pattern (P = { tuple, _Line, Ps }) ->
  Ps = pattern_list (Ps),
  P;
pattern (P = { record, Line, Name, Pfs }) ->
  check_record (Line, Name),
  Pfs = pattern_fields (Pfs),
  P;
pattern (P = { record_index, Line, Name, Field }) ->
  check_record (Line, Name),
  Field = pattern (Field),
  P;
pattern (P = { record_field, Line, Rec, Name, Field }) ->
  check_record (Line, Name),
  Rec = expr (Rec),
  Field = expr (Field),
  P;
pattern (P = { record_field, _Line, Rec, Field }) ->
  Rec = expr (Rec),
  Field = expr (Field),
  P;
pattern (P = { bin, _Line, Fs }) ->
  Fs = pattern_grp (Fs),
  P;
pattern (P = { op, _Line, _Op, A }) ->
  A = pattern (A),
  P;
pattern (P = { op, _Line, _Op, L, R }) ->
  L = pattern (L),
  R = pattern (R),
  P;
pattern (P) ->
  P.

pattern_grp (Fs) ->
  [ pattern_grp_elem (F) || F <- Fs ].

pattern_grp_elem (F = { bin_element, _L, E, S, _T }) ->
  S = case S of default -> default; _ -> expr (S) end,
  E = expr (E),
  F.

pattern_list (Ps) ->
  [ pattern (P) || P <- Ps ].

%% -type pattern_fields([Field]) -> [Field].
%%  N.B. Field names are full expressions here but only atoms are allowed
%%  by the *linter*!.

pattern_fields (Pfs) ->
  [ pattern_field (Pf) || Pf <- Pfs ].

pattern_field (Pf = { record_field, _Lf, _, P }) ->
  P = pattern (P),
  Pf.

guard ([ G0 | Gs ]) when list (G0) ->
  [ guard0 (G0) | guard (Gs) ];
guard (L) ->
  guard0 (L).

guard0 (Gs) ->
  [ guard_test (G) || G <- Gs ].

guard_test (Expr = { call, _Line, { atom, _La, F }, As }) ->
  case erl_internal:type_test (F, length (As)) of
    true -> 
      As = gexpr_list (As),
      Expr;
    _ ->
      gexpr (Expr)
  end;
guard_test (Any) ->
  gexpr (Any).

gexpr (Expr = { cons, _Line, H, T }) ->
  H = gexpr (H),
  T = gexpr (T),
  Expr;
gexpr (Expr = { tuple, _Line, Es }) ->
  Es = gexpr_list (Es),
  Expr;
gexpr (Expr = { record_index, Line, Name, Field }) ->
  check_record (Line, Name),
  Field = gexpr (Field),
  Expr;
gexpr (Expr = { record_field, Line, Rec, Name, Field }) ->
  check_record (Line, Name),
  Rec = gexpr (Rec),
  Field = gexpr (Field),
  Expr;
gexpr (Expr = { record, Line, Name, Inits }) ->
  check_record (Line, Name),
  Inits = grecord_inits (Inits),
  Expr;
gexpr (Expr = { call, _Line, { atom, _La, _F }, As }) ->
  As = gexpr_list (As),
  Expr;
gexpr (Expr = { call, 
                _Line, 
                { remote, _La, { atom, _Lb, erlang }, { atom, _Lc, _F }},
                As }) ->
  As = gexpr_list (As),
  Expr;
% Unfortunately, writing calls as {M,F}(...) is also allowed.
gexpr (Expr = { call,
                _Line,
                { tuple, _La, [{ atom, _Lb, erlang }, { atom, _Lc, _F }]},
                As }) ->
  As = gexpr_list (As),
  Expr;
gexpr (Expr = { bin, _Line, Fs }) ->
  Fs = pattern_grp (Fs),
  Expr;
gexpr (Expr = { op, _Line, _Op, A }) ->
  A = gexpr (A),
  Expr;
gexpr (Expr = { op, _Line, Op, L, R }) when Op =:= 'andalso'; Op =:= 'orelse' ->
  L = gexpr (L),
  R = gexpr (R),
  Expr;
gexpr (Expr = { op, _Line, _Op, L, R }) ->
  L = gexpr (L),
  R = gexpr (R),
  Expr;
gexpr (Expr) ->
  Expr.

gexpr_list (Es) ->
  [ gexpr (E) || E <- Es ].

grecord_inits (Is) ->
  [ grecord_init_item (I) || I <- Is ].

grecord_init_item (GRec = { record_field, _Lf, { atom, _La, _F }, Val }) ->
  Val = gexpr (Val),
  GRec;
grecord_init_item (GRec = { record_field, _Lf, { var, _La, '_' }, Val }) ->
  Val = gexpr (Val),
  GRec.

exprs (Es) ->
  [ expr (E) || E <- Es ].

%% -type expr(Expression) -> Expression.


expr (Expr = { cons, _Line, H, T }) ->
  H = expr (H),
  T = expr (T),
  Expr;
expr (Expr = { lc, _Line, E, Qs }) ->
  Qs = lc_bc_quals (Qs),
  E = expr (E),
  Expr;
expr (Expr = { bc, _Line, E, Qs }) ->
  Qs = lc_bc_quals (Qs),
  E = expr (E),
  Expr;
expr (Expr = { tuple, _Line, Es }) ->
  Es = expr_list (Es),
  Expr;
expr (Expr = { record_index, Line, Name, Field }) ->
  check_record (Line, Name),
  Field = expr (Field),
  Expr;
expr (Expr = { record, Line, Name, Inits }) ->
  check_record (Line, Name),
  Inits = record_inits (Inits),
  Expr;
expr (Expr = { record_field, Line, Rec, Name, Field }) ->
  check_record (Line, Name),
  Rec = expr (Rec),
  Field = expr (Field),
  Expr;
expr (Expr = { record, Line, Rec, Name, Upds }) ->
  check_record (Line, Name),
  Rec = expr (Rec),
  Upds = record_updates (Upds),
  Expr;
expr (Expr = { record_field, _Line, Rec, Field }) ->
  Rec = expr (Rec),
  Field = expr (Field),
  Expr;
expr (Expr = { block, _Line, Es }) ->
  Es = exprs (Es),
  Expr;
expr (Expr = { 'if', _Line, Cs }) ->
  Cs = icr_clauses (Cs),
  Expr;
expr (Expr = { 'case', _Line, E, Cs }) ->
  E = expr (E),
  Cs = icr_clauses (Cs),
  Expr;
expr (Expr = { 'receive', _Line, Cs }) ->
  Cs = icr_clauses (Cs),
  Expr;
expr (Expr = { 'receive', _Line, Cs, To, ToEs }) ->
  To = expr (To),
  ToEs = exprs (ToEs),
  Cs = icr_clauses (Cs),
  Expr;
expr (Expr = { 'try', _Line, Es, Scs, Ccs, As }) ->
  Es = exprs (Es),
  Scs = icr_clauses (Scs),
  Ccs = icr_clauses (Ccs),
  As = exprs (As),
  Expr;
expr (Expr = { 'fun', _Line, Body }) ->
  case Body of
    { clauses, Cs } ->
      Cs = fun_clauses (Cs),
      Expr;
    { function, _F, _A } ->
      Expr;
    { function, _M, _F, _A } ->
      % ORLY ?
      Expr
  end;
expr (Expr = { call, _Line, F, As }) ->
  F = expr (F),
  As = expr_list (As),
  Expr;
expr (Expr = {'catch', _Line, E }) ->
  E = expr (E),
  Expr;
expr (Expr = { 'query', _Line, E }) ->
  E = expr (E),
  Expr;
expr (Expr = { match, _Line, P, E }) ->
  E = expr (E),
  P = pattern (P),
  Expr;
expr (Expr = { bin, _Line, Fs }) ->
  Fs = pattern_grp (Fs),
  Expr;
expr (Expr = { op, _Line, _Op, A }) ->
  A = expr (A),
  Expr;
expr (Expr = { op, _Line, _Op, L, R }) ->
  L = expr (L),
  R = expr (R),
  Expr;
%% The following are not allowed to occur anywhere!
expr (Expr = { remote, _Line, M, F }) ->
  M = expr (M),
  F = expr (F),
  Expr;
expr (Expr) ->
  Expr.

expr_list (Es) ->
  [ expr (E) || E <- Es ].

record_inits (Is) ->
  [ record_init_item (I) || I <- Is ].

record_init_item (Rec = { record_field, _Lf, { atom, _La, _F }, Val }) ->
  Val = gexpr (Val),
  Rec;
record_init_item (Rec = { record_field, _Lf, { var, _La, '_' }, Val }) ->
  Val = gexpr (Val),
  Rec.

record_updates (Upds) ->
  [ record_update (U) || U <- Upds ].

record_update (Upd = { record_field, _Lf, { atom, _La, _F }, Val }) ->
  Val = expr (Val),
  Upd.

icr_clauses (Cs) ->
  [ clause (C) || C <- Cs ].

lc_bc_quals (Qs) ->
  [ lc_bc_qual (Q) || Q <- Qs ].

lc_bc_qual (Q = { generate, _Line, P, E }) ->
  E = expr (E),
  P = pattern (P),
  Q;
lc_bc_qual (Q = { b_generate, _Line, P, E }) ->
  E = expr (E),
  P = pattern (P),
  Q;
lc_bc_qual (Q) ->
  Q = expr (Q),
  Q.

fun_clauses (Cs) ->
  [ clause (C) || C <- Cs ].
