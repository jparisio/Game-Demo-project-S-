draw_self();
//// Draw the circle around the point (x, y)

if(global.toggle_debug){
	draw_set_color(c_white);
	draw_circle(x, y, radius, true); 
	draw_circle(x, y, hover_radius, true);
	if draw_line_ draw_line(x, y, obj_player.x, obj_player.y - 20)
}