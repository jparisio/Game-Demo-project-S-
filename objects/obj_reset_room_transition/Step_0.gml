fsm.step();

for (var i = 0; i < array_length(transition_squares); i++) {
    var square = transition_squares[i];
        
    // Forward transition: Grow squares
    square.size = Approach(square.size, square_size, approach_val + square._offset / 2);
}


//show_debug_message(instance_number(obj_reset_room_transition))