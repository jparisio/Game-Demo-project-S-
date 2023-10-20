
if(surface_exists(surface)){
	surface_set_target(surface)
	draw_clear(c_black)

	gpu_set_blendmode(bm_normal);
	surface_reset_target()
	draw_surface_ext(surface, x, y, 1, 1, 0, c_white, 0.7);
} else surface = surface_create(room_width, room_height)
