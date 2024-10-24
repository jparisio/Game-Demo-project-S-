//create
transition_squares = [];
square_size_max = 70;
square_size = square_size_max;
approach_val = 2.3;
rows = ceil(display_get_gui_width() / square_size) + 1;
columns = ceil(display_get_gui_width() / square_size) + 1;
alarm[0] = -1;

// Initialize squares with size 0
for (var i = 0; i < columns; i++) {
    for (var j = 0; j < rows; j++) {
        array_push(transition_squares, {
			_x: i * square_size, 
			_y: j * square_size, 
			size: 0, 
			_offset: i
		});
    }
}


all_squares_done = function() {
    for (var i = 0; i < array_length(transition_squares); i++) {
		show_debug_message(transition_squares[i].size);
        if (transition_squares[i].size != square_size) {
            return false;
        }
    }
    return true;
}

