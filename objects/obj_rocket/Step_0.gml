val++;

image_angle += cos(val * .1) * .3;

if image_alpha <= 1 image_alpha += 0.01

if(alarm[1] >= 0){
	var x_pos =  obj_player.x + lengthdir_x(radius, target_angle);
	var y_pos =  obj_player.y + lengthdir_y(radius, target_angle);

	x = lerp(x, x_pos, move_speed * 0.01);
	y = lerp(y, y_pos, move_speed * 0.01);
}

if(speed < 0 and sprite_index != spr_empty) part_particles_create(particle_system, x, y, particle_trail, 1);

//// Check for collision with obj_player or obj_wall
//if (place_meeting(x, y, obj_hurtbox)) {
//    // Trigger explosion (e.g., create explosion object, deal damage, etc.)
//    instance_destroy(); // Destroy the grenade object
//}
