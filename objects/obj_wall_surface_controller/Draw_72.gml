//Draw Begin
if !surface_exists(big_surface) big_surface = surface_create(room_width, room_height)
surface_set_target(big_surface)

//previously surface = surface_create(global.cam_width * 1.5, global.cam_height) for cam sized (bugs)

with (obj_blood){
	var _image_index = irandom(sprite_get_number(spr_blood) - 1);
    draw_sprite_ext(spr_blood, _image_index, x, y ,1,1,0, c_red, 1)
}
surface_reset_target()

//if(surface_exists(big_surface)) show_debug_message("YAY IT EXISTS")