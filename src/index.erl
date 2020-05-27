-module(index).

-compile(export_all).

-include_lib("nitro/include/nitro.hrl").
-include_lib("n2o/include/n2o.hrl").

event(init) ->
    init_sid(),
    nitro:clear(history),
    nitro:update(newGameButton,
                 #button{id = newGameButton,
                         body = "New Game",
                         postback = new_game,
                         source = [player1]}),
    nitro:update(addPlayerButton,
                 #button{id = addPlayerButton,
                         body = "Add Player",
                         postback = add_player,
                         source = [player1, player2]}),
    nitro:update(positionIslandButton,
                 #button{id = positionIslandButton,
                         body = "Position Island",
                         postback = position_island,
                         source = [island, row, col]}),
    nitro:update(setIslandsButton,
                 #button{id = setIslandsButton,
                         body = "Set Islands",
                         postback = set_islands}),
    nitro:update(guessCoordinateButton,
                 #button{id = guessCoordinateButton,
                         body = "Guess Coordinate",
                         postback = guess_coordinate,
                         source = [guessrow, guesscol]});
event(#client{data = {msg, User, Message}}) ->
    HTML = nitro:to_list(Message),
    nitro:insert_top(history,
                     nitro:render(#message{body = [#author{body = User}, nitro:jse(HTML)]}));
event(new_game) ->
    Player1 = nitro:to_list(nitro:q(player1)),
    n2o:user(Player1),
    started_game(islands_engine_sup:start_game(Player1),
                 Player1),
    ok;
event(add_player) ->
    Player1 = nitro:to_list(nitro:q(player1)),
    Player2 = nitro:to_list(nitro:q(player2)),
    add_player(via(Player1), Player1, Player2),
    ok;
event(position_island) ->
    Island = list_to_atom(nitro:to_list(nitro:q(island))),
    Row = try binary_to_integer(nitro:q(row)) catch _:_ -> 0 end,
    Col = try binary_to_integer(nitro:q(col)) catch _:_ -> 0 end,
    position_island(via(n2o:session(room)), Island, Row, Col),
    ok;
event(set_islands) ->
    set_islands(via(n2o:session(room))),
    ok;
event(guess_coordinate) ->
    Row = try binary_to_integer(nitro:q(guessrow)) catch _:_ -> 0 end,
    Col = try binary_to_integer(nitro:q(guesscol)) catch _:_ -> 0 end,
    guess_coordinate(via(n2o:session(room)), Row, Col),
    ok;
event(_) ->
    [].

started_game({ok, _Game}, Player1) ->
    n2o:session(player, player1),
    init_room(Player1),
    reply_msg("New Game!");
started_game({error, Reason}, _Player1) ->
    reply_msg(nitro:to_list(Reason)).

add_player(undefined, _Player1, _Player2) ->
    reply_msg("Undefined Game.");
add_player(Game, Player1, Player2) ->
    n2o:user(Player2),
    player_added(game:add_player(Game, Player2),
                 Player1).

player_added(ok, Player1) ->
    n2o:session(player, player2),
    init_room(Player1),
    broadcast_msg("Just joined.");
player_added(error, _Player1) ->
    reply_msg("Unable to add new player.").

position_island(undefined, _Island, _Row, _Col) ->
    reply_msg("Undefined Game.");
position_island(Game, Island, Row, Col) ->
    positioned_island(game:position_island(Game, n2o:session(player),
                                           Island, Row, Col),
                      Island).

positioned_island(ok, Island) ->
    reply_msg(nitro:to_list(Island) ++ " Island positioned!");
positioned_island({error, Reason}, _Island) ->
    reply_msg(nitro:to_list(Reason));
positioned_island(error, _Island) ->
    reply_msg("Unable to position island.").

set_islands(undefined) ->
    reply_msg("Undefined Game.");
set_islands(Game) ->
    setted_islands(game:set_islands(Game, n2o:session(player))).

setted_islands({ok, _Board}) ->
    nitro:hide(positionIsland),
    nitro:hide(setIslands),
    nitro:show(guessCoordinate),
    broadcast_msg("Set Islands.");
setted_islands({error, Reason}) ->
    reply_msg(nitro:to_list(Reason));
setted_islands(error) ->
    reply_msg("Unable to set islands.").

guess_coordinate(undefined, _Row, _Col) ->
    reply_msg("Undefined Game.");
guess_coordinate(Game, Row, Col) ->
    guessed_coordinate(game:guess_coordinate(Game, n2o:session(player),
                                             Row, Col)).

guessed_coordinate({hit, none, no_win}) ->
    broadcast_msg("Guessed Coordinate.");
guessed_coordinate({hit, Island, no_win}) ->
    broadcast_msg(nitro:to_list(Island) ++ " Island forested!");
guessed_coordinate({hit, _Island, win}) ->
    broadcast_msg("Won!");
guessed_coordinate({miss, _Island, _Win}) ->
    reply_msg("Unable to guess a coordinate.");
guessed_coordinate({error, Reason}) ->
    reply_msg(nitro:to_list(Reason));
guessed_coordinate(error) ->
    reply_msg("Not your turn.").

via(Player) ->
    game:pid_from_name(Player).

init_sid() ->
    n2o:reg(n2o:sid()),
    nitro:hide(positionIsland),
    nitro:hide(setIslands),
    nitro:hide(guessCoordinate).

init_room(Player1) ->
    n2o:session(room, Player1),
    n2o:reg({topic, Player1}),
    nitro:hide(newGame),
    nitro:show(positionIsland),
    nitro:show(setIslands).

reply_msg(Mensaje) ->
    Msg = {msg, n2o:user(), nitro:jse(Mensaje)},
    n2o:send(n2o:sid(), #client{data = Msg}).

broadcast_msg(Mensaje) ->
    Msg = {msg, n2o:user(), nitro:jse(Mensaje)},
    n2o:send({topic, n2o:session(room)}, #client{data = Msg}).
