var _bounds = obj_player.cam_bounds
// Follow the target with smoothing
if (follow != noone) {
    x += (follow.x - x) / 15;
	if(_bounds != noone) {
		//y = _bounds.y;
		//show_debug_message("WERE WORKING")
		y += (_bounds.set_y - y) / 30;
	} else {
		y += (follow.y - 30 - y) / 15;
	}
}

//show_debug_message(y)

// Anchor specifics
if (follow == obj_temp_camera_anchor) {
    global.x_offset = lerp(global.x_offset, 0.5, 0.03);
}
//} else {
//    global.x_offset = 0.45;
//}

// Move the camera offset depending on if the player is facing left or right
if (follow == obj_player) {
	if(obj_player.facing == 1){
		//show_debug_message("facing right")
		global.x_offset = lerp(global.x_offset, 0.48, 0.05);
		//show_debug_message(global.x_offset);
	} else {
		//show_debug_message("facing left")
		global.x_offset = lerp(global.x_offset, 0.52, 0.05);
		//show_debug_message(global.x_offset);
	}

}

var _x = x - global.cam_width * global.x_offset;
var _y = y - global.cam_height * global.y_offset;
// Calculate thresholds
//var upper_threshold = _y + (global.cam_height / 4);
//var lower_threshold = _y + (global.cam_height * 3 / 4);

//// Apply threshold logic
//if (obj_player.y < upper_threshold) {
//    _y = obj_player.y - (global.cam_height / 4);  // Center player at 1/4th height
//} else if (obj_player.y > lower_threshold) {
//    _y = obj_player.y - (global.cam_height * 3 / 4);  // Center player at 3/4th height
//}

//clamp to room boundaries
_x = clamp(_x, 0, room_width - global.cam_width);
_y = clamp(_y, 0, room_height - global.cam_height);

// Apply the camera position
camera_set_view_pos(view_camera[0], _x, _y);
camera_set_view_size(view_camera[0], global.cam_width, global.cam_height);

