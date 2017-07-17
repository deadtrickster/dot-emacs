-module(${1:`(file-name-nondirectory
               (file-name-sans-extension (or (buffer-file-name) (buffer-name))))`}).

%% Cowboy callbacks
-export([init/3]).
-export([allowed_methods/2]).
-export([content_types_accepted/2]).
-export([content_types_provided/2]).
-export([is_authorized/2]).
-export([resource_exists/2]).
-export([delete_resource/2]).
-export([to_json_v1/2]).
-export([from_json_v1/2]).

%% ===================================================================
%% Macros
%% ===================================================================

-define(RESOURCE_MODULE, $2).

-record(state, {
          id,
          resource
         }).

%% ===================================================================
%% Cowboy Callbacks
%% ===================================================================

init(_, _, _) ->
    {upgrade, protocol, cowboy_rest}.


allowed_methods(Req, State) ->
    {[<<"GET">>, <<"PUT">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
    {[
      {<<"application/json">>, to_json_v1}
     ], Req, State}.

content_types_accepted(Req, State) ->
    {[
      {{<<"application">>, <<"json">>, '*'}, from_json_v1}
     ], Req, State}.

is_authorized(Req0, State) ->
    case is_authorized(Req0) of
        {{true, _}, Req} ->
            {true, Req, State};
        {{false, Authorization}, Req} ->
            {{false, Authorization}, Req, State}
    end.

resource_exists(Req, _State0) ->
    {Id, _} = cowboy_req:binding(id, Req),
    State = #state{id=Id},
    case get_resource(Id) of
        {ok, Resource} ->
            {true, Req, State#state{resource=Resource}};
        {error, _} ->
            {false, Req, State}
    end.

delete_resource(Req, #state{id=Id}=State) ->
  delete_resource(Id),
  {true, Req, State}.

from_json_v1(Req0, State=#state{id=Id}) ->
    {ok, ReqBody, Req} = es_webserver_req:body(Req0),
    
    case resource_from_json(Id, ReqBody) of
        {ok, _} ->
            {true, Req, State};
        {error, Problem0} ->
            Problem =
                case Problem0 of
                    X when is_list(X) -> X;
                    X -> [X]
                end,
            {false,
             jsx:encode(Problem),
             State}
    end.

to_json_v1(Req, State=#state{resource=Resource}) ->
    {resource_to_json(Resource), Req, State}.

%% ===================================================================
%% Private functions
%% ===================================================================

is_authorized(_Req) ->
  true.

get_resource(Id) ->
  ?RESOURCE_MODULE:get_resource(Id).

delete_resource(Id) ->
  ?RESOURCE_MODULE:delete_resource(Id).

resource_from_json(Id, Json) ->  
  case ?RESOURCE_MODULE:from_json(Id, Json) of
    {ok, Resource} ->
      ?RESOURCE_MODULE:save(Resource);
    {error, Error} ->
      {error, Error}
  end.

resource_to_json(Resource) ->
  ?RESOURCE_MODULE:to_json(Resource).
