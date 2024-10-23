var target_yoffset;

//if (place_meeting(x, y, obj_player) and obj_player.facing == -sign(self.image_xscale)) {
if (place_meeting(x, y, obj_player)){
    target_yoffset = 0.5;
} else {
    target_yoffset = 0.7;
}

// Smoothly transition the global.yoffset towards the target value
global.y_offset = lerp(global.y_offset, target_yoffset, 0.03);


//show_debug_message(image_xscale)
//show_debug_message(obj_player.facing)