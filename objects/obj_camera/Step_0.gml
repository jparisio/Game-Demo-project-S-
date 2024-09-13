var _bounds = obj_player.cam_bounds
// Follow the target with smoothing
if (follow != noone) {
    x += (follow.x - x) / 25;
	if(_bounds != noone) {
		//y = _bounds.y;
		//show_debug_message("WERE WORKING")
		y += (_bounds.y - y) / 30;
	} else {
		y += (follow.y - y) / 30;
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

// Check if the player is inside an instance of obj_cam_bounds
var cam_bounds = instance_place(follow.x, follow.y, obj_cam_bounds);

if (cam_bounds != noone) {
    // Get the boundaries of the obj_cam_bounds instance
    var left_bound = cam_bounds.x;
    var right_bound = cam_bounds.x + cam_bounds.sprite_width;
    var top_bound = cam_bounds.y;
    var bottom_bound = cam_bounds.y + cam_bounds.sprite_height;

    // Clamp the camera position to stay within the bounds
    //_x = clamp(_x, left_bound, right_bound - global.cam_width);
    _y = clamp(_y, top_bound, bottom_bound - global.cam_height);
}

// Apply the camera position
camera_set_view_pos(view_camera[0], _x, _y);
camera_set_view_size(view_camera[0], global.cam_width, global.cam_height);

