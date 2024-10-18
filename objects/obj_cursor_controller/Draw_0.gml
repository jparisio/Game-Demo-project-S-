if (lock_on != noone){
	//if hovering a point lock onto that point
	draw_sprite_ext(sprite_index, image_index, lock_on.x, lock_on.y, xscale, yscale, image_angle, c_white, image_alpha)
} else {
	//else follow the mouse
	draw_sprite_ext(sprite_index, image_index, mouse_x, mouse_y, xscale, yscale, image_angle, c_white, image_alpha)
}