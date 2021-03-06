-module(kai_folsom).
-author('Adam Rutkowski <hq@mtod.org>').

-export([init_static_metrics/0]).

-export([name_rest_ok/1,
         name_rest_nok/1,
         name_rest_ok_lat/1,
         name_rest_nok_lat/1,
         name_rest_ok_size/1]).

-export([name_writes_ok/0,
         name_writes_nok/0,
         name_pong/0,
         name_pang/0]).

-export([begin_rest_ok_lat/1,
         begin_rest_nok_lat/1]).

-export([notify_lat/1,
         notify_spiral/1,
         notify_hist/2]).

-export([notify_pong/0,
         notify_pang/0,
         notify_write_ok/0,
         notify_write_nok/0]).

-define(REST   , "kai.rest.").
-define(TELNET , "kai.telnet.").

-define(REST_ENDPOINTS, [query_metrics,
                         query_metrics_tags,
                         delete_datapoints,
                         delete_metric,
                         list_metric_names,
                         list_tag_values]).

init_static_metrics() ->
    _ = [begin
         N1 = name_rest_ok(Call),
         N2 = name_rest_nok(Call),
         N3 = name_rest_ok_lat(Call),
         N4 = name_rest_nok_lat(Call),
         N5 = name_rest_ok_size(Call),
         ok = folsom_metrics:new_spiral(N1),
         ok = folsom_metrics:new_spiral(N2),
         ok = folsom_metrics:new_histogram(N3),
         ok = folsom_metrics:new_histogram(N4),
         ok = folsom_metrics:new_histogram(N5)
     end || Call <- ?REST_ENDPOINTS],
    N5 = name_writes_ok(),
    N6 = name_writes_nok(),
    ok = folsom_metrics:new_spiral(N5),
    ok = folsom_metrics:new_spiral(N6),
    N7 = name_pong(),
    N8 = name_pang(),
    ok = folsom_metrics:new_spiral(N7),
    ok = folsom_metrics:new_spiral(N8).


begin_rest_ok_lat(Call) ->
    Name = name_rest_ok_lat(Call),
    folsom_metrics:histogram_timed_begin(Name).

begin_rest_nok_lat(Call) ->
    Name = name_rest_nok_lat(Call),
    folsom_metrics:histogram_timed_begin(Name).

notify_lat(LatMetric) ->
    ok = folsom_metrics:histogram_timed_notify(LatMetric).

notify_pong() ->
    Name = name_pong(),
    notify_spiral(Name).

notify_pang() ->
    Name = name_pang(),
    notify_spiral(Name).

notify_write_ok() ->
    Name = name_writes_ok(),
    notify_spiral(Name).

notify_write_nok() ->
    Name = name_writes_nok(),
    notify_spiral(Name).

notify_spiral(Name) ->
    ok = folsom_metrics:notify({Name, 1}).

notify_hist(Name, Size) ->
    ok = folsom_metrics:notify({Name, Size}).

name_rest_ok(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".OK">>.

name_rest_nok(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".NOK">>.

name_rest_ok_lat(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".OK.latency">>.

name_rest_nok_lat(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".NOK.latency">>.

name_rest_ok_size(Call) when is_atom(Call) ->
    <<?REST, (bin(Call))/binary, ".OK.size">>.

name_writes_ok() ->
    <<?TELNET, "writes.OK">>.

name_writes_nok() ->
    <<?TELNET, "writes.NOK">>.

name_pong() ->
    <<?TELNET, "ping.pong">>.

name_pang() ->
    <<?TELNET, "ping.pang">>.

bin(A) when is_atom(A) ->
    erlang:atom_to_binary(A, latin1).
