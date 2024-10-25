//create
transition_squares = [];
square_size_max = 70;
square_size = square_size_max;
approach_val = 2.3;
rows = ceil(display_get_gui_width() / square_size) + 1;
columns = ceil(display_get_gui_width() / square_size) + 1;
reset = false;
next_room = false;

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
        if (transition_squares[i].size != square_size) {
            return false;
        }
    }
    return true;
}

fsm = new SnowState("start")


fsm	
	.add("start", {
		enter: function() {
			
		},
		step: function() {
			if(all_squares_done() and square_size == square_size_max){
				fsm.change("transition");
			}
		}
	})
		
		
	.add("transition", {
		enter: function() {
			timer = 15;
		},
		step: function() {
			timer--;		
			if timer <= 0 fsm.change("final");
		}
		
 })
 
 	.add("final", {
		enter: function() {
			//make squares approach 0 now
			square_size = 0;
			if (reset) {
				    reset_room_states();
				} else if (next_room && room != room_last) {
				    room_goto_next();
			}
		},
		step: function() {
			if (all_squares_done()){
					instance_destroy();
			}
		}
		
 });

