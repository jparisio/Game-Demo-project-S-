event_inherited();
onClick = function(){
	 if (obj_game_state.fsm.get_current_state() != "load game") obj_game_state.fsm.change("load game");
}




