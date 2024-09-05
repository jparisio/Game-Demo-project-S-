//if surface_exists(obj_back_wall.surf){
//	surface_set_target(obj_back_wall.surf)
//	//for surfaces, the wall is at x = 248 and y = 192 in the room (draw from top left), so i have to subtract those on the surface
//	/*instead I changed it to have the back wall with an origin point at top left, so i can create the surface at
//	just the x and y, and subtract the x and y later*/
//	draw_sprite_ext(spr_blood, image_index, x - obj_back_wall.x, y - obj_back_wall.y ,1,1,0,c_red, 1)
//	surface_reset_target()
//}

show_debug_message("XScale: " + string(image_xscale));

lifetime--;

if animation_end() instance_destroy()
