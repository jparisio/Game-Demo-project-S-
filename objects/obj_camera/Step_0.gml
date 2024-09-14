var _bounds = obj_player.cam_bounds
// Follow the target with smoothing
if (follow != noone) {
    x += (follow.x - x) / 25;
	if(_bounds != noone) {
		//y = _bounds.y;
		//show_debug_message("WERE WORKING")
		y += (_bounds.set_y - y) / 30;
	} else {
		y += (follow.y - 30 - y) / 30;
	}
}

//show_debug_message(y)

// Anchor specifics
if (follow == obj_temp_camera_anchor) {
    global.x_offset = lerp(global.x_offset, 0.5, 0.03);
} else {
    global.x_offset = 0.35;
}

// Move the camera offset depending on if the player is facing left or right
if (follow == obj_player) {
    if (follow.facing == 1) {
        global.x_offset = lerp(global.x_offset, 0.35, 0.0025);
    } else {
        global.x_offset = lerp(global.x_offset, 0.65, 0.0025);
    }
}

var _x = x - global.cam_width * global.x_offset;
var _y = y - global.cam_height * global.y_offset;

// Apply the camera position
camera_set_view_pos(view_camera[0], _x, _y);
camera_set_view_size(view_camera[0], global.cam_width, global.cam_height);

