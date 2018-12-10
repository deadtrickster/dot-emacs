-module(${1:`(file-name-nondirectory
              (file-name-sans-extension (or (buffer-file-name) (buffer-name))))`}).

-compile(export_all).
-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

%% ===================================================================
%% CT CALLBACKS
%% ===================================================================

%% @doc All tests of this suite.
all() ->
    [
     {group, positive}
    ].

%% @doc Groups of tests
groups() ->
    [
     {positive, [sequential], [
                               sanity
                              ]}
    ].

init_per_suite(Config) ->
    Config.

init_per_testcase(sanity, Config) ->
  [{sanity, sanity} | Config];
init_per_testcase(_Name, Config) ->
  Config.

end_per_testcase(_, _Config) ->
    ok.

end_per_suite(_Config) ->
    ok.

%% ===================================================================
%% Test Cases
%% ===================================================================

sanity(Config) ->
  ?assertMatch(sanity, ?config(sanity, Config)).

%% ===================================================================
%% Private functions
%% ===================================================================

