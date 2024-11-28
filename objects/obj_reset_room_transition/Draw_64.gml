//draw gui
draw_set_color(c_black);
for (var i = 0; i < array_length(transition_squares); i++) {
    var square = transition_squares[i];
    
    var half_size = square.size / 2;
	draw_x = square._x;
	draw_y = square._y;
	if square.size > 1 {
		draw_rectangle(draw_x - half_size, draw_y - half_size, draw_x + half_size, draw_y + half_size, false);
	}
}


