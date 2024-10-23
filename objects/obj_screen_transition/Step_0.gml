if all_squares_done() and square_size == 0 {
	instance_destroy();
}


for (var i = 0; i < array_length(transition_squares); i++) {
    var square = transition_squares[i];
        
    // Forward transition: Grow squares
    square.size = Approach(square.size, square_size, approach_val + square._offset / 2);
}


if(all_squares_done() and square_size == square_size_max){
	if (alarm[0] == -1) {
		alarm[0] = 15;
		reset_room_states();
	}
}