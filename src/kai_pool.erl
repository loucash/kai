-module(kai_pool).
-author('Adam Rutkowski <hq@mtod.org>').

-export([init/1]).
-export([fetch/0, fetch/2]).
-export([join/0]).
-export([leave/0]).

-define(POOL, ?MODULE).

init(N) ->
    {ok, _} = pg2:start(),
    lager:info("KairosDB Initializing pool of ~w connections.", [N]),
    ok = pg2:create(?POOL),
    spawn_connections(N).

join() ->
    ok = pg2:join(?POOL, self()).

fetch() ->
    case pg2:get_closest_pid(?POOL) of
        P when is_pid(P) ->
            {ok, P};
        {error, {no_process, _}} ->
            {error, no_connections_available};
        {error, _}=E ->
            E
    end.

fetch(Fn, N) ->
    case kai_pool:fetch() of
        {ok, Conn} ->
            Response = Fn(Conn),
            fetch_response(Fn, Response, N);
        {error, R} ->
            {error, {kairosdb, R}}
    end.

fetch_response(_Fn, Response, 0) ->
    Response;
fetch_response(Fn, Response, N) ->
    case Response of
        {error, connecting} ->
            fetch(Fn, N - 1);
        _ -> Response
    end.

leave() ->
    ok = pg2:leave(?POOL, self()).

spawn_connections(N) ->
    [ begin
          {ok, _Pid} = kai_conn_sup:start_child(),
          timer:sleep(1000)
      end || _ <- lists:seq(1, N) ],
    ok.


