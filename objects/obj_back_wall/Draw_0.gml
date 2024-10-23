draw_self()

//if(!surface_exists(surf)){
//surf = surface_create(sprite_width, sprite_height)
//}
draw_set_alpha(wall_alpha)
draw_surface_part(obj_wall_surface_controller.big_surface, x, y, sprite_width, sprite_height, x, y);
draw_set_alpha(1)
//draw_set_alpha(.4)


