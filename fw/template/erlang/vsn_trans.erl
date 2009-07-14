%% @doc Adds a -vsn attribute to the file is one is not already declared,
%% using the environment variable FW_PACKAGE_VERSION.
%% @end

-module (vsn_trans).

-export([ parse_transform/2 ]).

parse_transform (Forms, Options) ->
  maybe_add_vsn (Forms, fw_package_version (Options)).

fw_package_version ([]) -> undefined;
fw_package_version ([ { fw_package_version, Vsn } | _ ]) -> { ok, Vsn };
fw_package_version ([ _ | T ]) -> fw_package_version (T).

maybe_add_vsn (Fs, undefined) -> Fs;
maybe_add_vsn (Fs, { ok, FwPackageVersion }) ->
  case get_vsn (Fs) of
    undefined ->
      add_vsn (FwPackageVersion, Fs);
    _ ->
      Fs
  end.

get_vsn (Fs) ->
  get_vsn (Fs, undefined).

get_vsn ([], Val) -> Val;
get_vsn ([ { attribute, _, vsn, Val } | _ ], _) -> Val;
get_vsn ([ _ | T ], Val) -> get_vsn (T, Val).

add_vsn (Vsn, []) -> 
  [ { attribute, 1, vsn, [ Vsn ] } ];
add_vsn (Vsn, [ { attribute, Line, module, Mod } | T ]) ->
  [ { attribute, Line, module, Mod }, { attribute, Line, vsn, [ Vsn ] } | T ];
add_vsn (Vsn, [ H | T ]) ->
  [ H | add_vsn (Vsn, T) ].
