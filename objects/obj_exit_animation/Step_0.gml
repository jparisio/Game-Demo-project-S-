// Lerp the rectangle's x position from left to right
current_x = lerp(current_x, x_end, animation_speed);

// Check if the animation is complete (optional)
if (current_x >= x_end - 1) {
    // Animation complete, you can trigger any additional actions here
}

if(!finished and abs(x_end - current_x) <= 0.1){
	x_end = 0;
	room_goto(next_room);
	obj_player.x = target_x;
	obj_player.y = target_y;
	//obj_camera.snap_to = true;
	finished = true;
}


if(finished and (abs(current_x - x_end) <= 0.1)){
	instance_destroy();
}
