%%%-------------------------------------------------------------------
%% @doc islands_interface public API
%% @end
%%%-------------------------------------------------------------------

-module(islands_interface_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    cowboy:start_clear(http,
                       [{port, application:get_env(n2o, port, 8001)}],
                       #{env => #{dispatch => n2o_cowboy2:points()}}),
    islands_interface_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
