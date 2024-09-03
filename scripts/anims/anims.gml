function animation_hit_frame(frame){
	var frame_range = image_speed * sprite_get_speed(sprite_index) / game_get_speed(gamespeed_fps)
	return image_index >= frame and image_index < frame + frame_range;
}


function animation_end(){
    return (image_index + image_speed*sprite_get_speed(sprite_index)/(sprite_get_speed_type(sprite_index) == spritespeed_framespergameframe? 1 : game_get_speed(gamespeed_fps)) >= image_number);   
}

