//move player to the start of the room first
if (instance_exists(obj_room_start_point)) {
	obj_player.x = obj_room_start_point.x;
	obj_player.y = obj_room_start_point.y;
}

//capture initial states of everything when the room starts
capture_initial_room_states();



