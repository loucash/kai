# kai

[KairosDB](http://kairosdb.github.io/) Erlang Client

:warning: **WIP. Do not use yet.**

## Roadmap / planned features:

1. Inserting metrics:
  - pool of raw tcp clients (aka [`telnet API`](http://kairosdb.github.io/kairosdocs/telnetapi/index.html))
  - schedules ELB-friendly "ping", prevents corporate firewalls from killing idle connections
  
2. Retreiving metrics and aggregations:
  - [REST API](http://kairosdb.github.io/kairosdocs/restapi/index.html) wrappers
  - API for building [metrics queries](http://kairosdb.github.io/kairosdocs/restapi/QueryMetrics.html)
  
3. [pre-aggregation](http://kairosdb.github.io/kairosdocs/FAQ.html#why-would-i-pre-aggregate) facility

4. benchmarks / load-testing tools

### Pre-aggregation

1. Configuration

   ```erlang
   -type metric_name()            :: binary() | atom().
   -type tag_list()               :: proplists:proplist().
   -type time_unit()              :: seconds | minutes | hours | days.

   -type pre_aggregation_config() :: {pre_aggregation, aggregates()}.
   -type aggregates()             :: list(aggregate()).

   -type aggregate()              :: {what(), when(), how(), using()}.

   -type what()                   :: [{name, metric_name()} |
                                       {tags, tag_list()}].

   -type when()                   :: on_demand |
                                     {every, {non_neg_integer(), entries} |
                                             {non_neg_integer(), time_unit()}}.

   -type how()                    :: [aggregate_specs()].
   -type aggregate_tag()          :: atom() | binary().
   -type aggregate_sample()       :: {non_neg_integer(), time_unit()}.
   -type aggregate_overlap()      :: {non_neg_integer(), time_unit()}.
   -type aggregate_specs()        :: {aggregate_tag(),
                                      aggregate_sample(),
                                      aggregate_overlap()}.

   -type using()                  :: [{aggregate_tag_name, atom() | binary()}].
   ```

2. Configuration examples

   ```erlang
   {env, [{pre_aggregation,
           [
            {[{name, "tx"}, {tags, [{interface, eth0}]}],
             [{every, {30, seconds}}],
             [{'1sec', {1, seconds}, {30, seconds}},
              {'1min', {1, minutes}, {5, minutes}}],
             [{aggregate_tag_name, aggregate}]}
           ]
          }
         ]
   }
   ```


### Detailed implementation status

- [x] Configuration
  - [x] Telnet port
  - [x] Telnet host
  - [x] Pool size
  - [x] Ping interval
  - [x] REST API port
  - [x] REST API host

- [x] Pool of telnet clients
   - [x] Insert data points
   - [x] Query version
   - [x] Auto-reconnect
       - [ ] Proper back-off on connection errors (currently each connection is delayed to prevent reconnections at the same time)
   - [x] ELB friendly keep-alive (each connection queries KairosDB for version once in a while)

- [ ] REST API (adding data points is not planned, there is no good reason to do it within the scope of this client)
-   - [ ] custom response wrappers
      - [x] delete data points
      - [x] delete metric
      - [x] list metric names
      - [x] list tag names
      - [x] list tag values
      - [ ] query metrics
          - [ ] query builder api - stable (improvements pending)
          - [ ] aggregates:
              - [x] avg
              - [x] sum
              - [ ] dev
              - [ ] div
              - [ ] histogram
              - [ ] least_squares
              - [ ] max
              - [ ] min
              - [ ] rate
          - [x] tags support
          - [ ] group_by support
              - [ ] tags
              - [ ] time
              - [ ] value
          - [ ] exclude_tags
          - [x] limit
          - [ ] order

  - [ ] Pre-aggregation (TBD)
  - [ ] Load-testing / spammers (TBD)

## Credits

### Authors

Adam Rutkowski <hq@mtod.org>

Łukasz Biedrycki <lukasz.biedrycki@gmail.com>

#### Special thanks

Thanks to Mahesh Paolini-Subramanya and Ubiquiti Networks for letting us
making it an open source project.
