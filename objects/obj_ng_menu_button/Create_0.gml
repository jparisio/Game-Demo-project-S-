event_inherited();
onClick = function(){
		 obj_game_state.new_game = true;
	 if (obj_game_state.fsm.get_current_state() != "load game") obj_game_state.fsm.change("load game");
}




