var target_yoffset;

if (place_meeting(x, y, obj_player)) {
    target_yoffset = 0.1;
} else {
    target_yoffset = 0.8;
}

// Smoothly transition the global.yoffset towards the target value
global.y_offset = lerp(global.y_offset, target_yoffset, 0.01);
