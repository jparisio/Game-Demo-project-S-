
// Get the camera's top-left position considering the offsets
var cam_x = obj_camera.x - global.cam_width * global.x_offset;
var cam_y = obj_camera.y - global.cam_height * global.y_offset;

// Set the color to black
draw_set_color(c_black);

// Draw the rectangle lerping from left to right
draw_rectangle(cam_x, cam_y, cam_x + current_x, cam_y + global.cam_height, false);
