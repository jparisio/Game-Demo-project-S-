

//if(!instance_exists(obj_exit_animation)) {
//	with(instance_create_layer(x, y, "Instances", obj_exit_animation)){
//		next_room = other.next_room;
//		target_x = other.target_x;
//		target_y = other.target_y;
//	}
	
//}

if(obj_game_state.fsm.get_current_state() != "room transition"){
	obj_game_state.fsm.change("room transition");
}