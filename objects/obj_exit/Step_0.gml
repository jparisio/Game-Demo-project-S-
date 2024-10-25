if(place_meeting(x, y, obj_player)){
	if(!collided) {
		//collide once
		collided = true;
	    obj_game_state.fsm.change("room transition");
	}
}




