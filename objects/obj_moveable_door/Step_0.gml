fsm.step();

if obj_game_state.fsm.get_current_state() == "reload room" fsm.change("start");

