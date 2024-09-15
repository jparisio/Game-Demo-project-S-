// Get the current camera's top-left position directly from the camera system
var cam_x = camera_get_view_x(view_camera[0]);
var cam_y = camera_get_view_y(view_camera[0]);

// Set the color to black
draw_set_color(c_black);

// Draw the rectangle, adjusting its position based on the camera and the lerped value
draw_rectangle(cam_x, cam_y, cam_x + current_x, cam_y + global.cam_height + 400, false);

