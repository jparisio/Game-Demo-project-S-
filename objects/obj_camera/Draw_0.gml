if global.toggle_debug {
	draw_set_color(c_white);
	draw_circle(x, y, 15, true);

	//// Get the camera's position and size
	var cam_x = camera_get_view_x(view_camera[0]);
	var cam_y = camera_get_view_y(view_camera[0]);
	var cam_width = camera_get_view_width(view_camera[0]);
	var cam_height = camera_get_view_height(view_camera[0]);
	// Calculate the center X position
	var center_x = cam_x + (cam_width / 2);
	// Draw the line from the top to the bottom of the camera view
	draw_line(center_x, cam_y, center_x, cam_y + cam_height);

}
