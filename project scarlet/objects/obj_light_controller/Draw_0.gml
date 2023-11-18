var vx = obj_camera.x - global.cam_width * global.x_offset
var vy = obj_camera.y - global.cam_height * global.y_offset

if(!surface_exists(surface)){
    surface = surface_create(global.cam_width, global.cam_height)
}
matrix_set(matrix_world, matrix_build(-vx,-vy,0,0,0,0,1,1,1)); //Do this to use in room x/y cordinates 
    
surface_set_target(surface); //start drawing to the surface

draw_clear_alpha(c_black, .5)

//draw light
with(obj_lamp){
    gpu_set_blendmode(bm_subtract)
    draw_sprite_ext(spr_light, 0, x, y, 2.5, 2.5, 0, c_orange, .6)
    gpu_set_blendmode(bm_normal)
}    

with(obj_player){
    gpu_set_blendmode(bm_subtract)
    draw_sprite_ext(spr_light, 0, x, y, 2, 2, 0, c_white, .7)
    gpu_set_blendmode(bm_normal)
}    


surface_reset_target(); //reset draw target
matrix_set(matrix_world, matrix_build(0,0,0,0,0,0,1,1,1)); //undo matrix change
draw_surface(surface, vx, vy) //draw your surface 