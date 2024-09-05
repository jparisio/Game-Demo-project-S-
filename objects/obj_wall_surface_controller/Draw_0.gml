//// Check if the surface exists, otherwise create it
//if (!surface_exists(big_surface)) {
//    big_surface = surface_create(cam_width, cam_height);
//}

//// Set the surface as the target
//surface_set_target(big_surface);

//camera_apply(view_camera[0]);

//// Clear the surface with a transparent color
//draw_clear_alpha(c_white, .4);

//// Draw the blood onto the surface
//with (obj_blood) {
//	draw_set_color(c_red)
//    var _image_index = irandom(sprite_get_number(spr_blood) - 1);
//    draw_sprite_ext(spr_blood, _image_index, x, y,
//                    image_xscale, image_yscale, image_angle, c_red, image_alpha);
//}

//// Reset the surface target
//surface_reset_target();

//// Draw only the relevant parts of the surface where needed
//with (obj_back_wall) {
//    draw_surface_part(other.big_surface, x, y, sprite_width, sprite_height, x, y);
//}


