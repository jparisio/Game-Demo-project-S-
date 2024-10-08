draw_self();
//// Draw the circle around the point (x, y)

if(global.toggle_debug){
	draw_set_color(c_white); // Set the color of the circle
	draw_circle(x, y, radius, true); // Draw the circle with a radius of 10
	if draw_line_ draw_line(x, y, obj_player.x, obj_player.y - 20)
}