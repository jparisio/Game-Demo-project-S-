//step

// Lerp the rectangle's x position from left to right
current_x = lerp(current_x, x_end, animation_speed);

// Check if the animation is complete (optional)
if (current_x >= x_end - 1) {
    // Animation complete, you can trigger any additional actions here
}

//go to next room and move player to those coords
if(!finished and abs(x_end - current_x) <= 0.1){
	x_end = 0;
	room_goto(next_room);
	//var restart_instance = instance_find(obj_respawn_point, 0); // Find the restart point
	//if (restart_instance != noone) {
	//    obj_player.x = restart_instance.x; // Set player x to restart point x
	//    obj_player.y = restart_instance.y; // Set player y to restart point y
	//}
	obj_player.x = target_x;
	obj_player.y = target_y;
	finished = true
}


if(finished and (abs(current_x - x_end) <= 0.1)){
	instance_destroy();
}
