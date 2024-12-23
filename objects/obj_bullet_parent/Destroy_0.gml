//instance_create_layer(x, y, "Instances", obj_shrapnel_destroy);
var opposite_direction = (direction + 180) mod 360;

var _x = x + lengthdir_x(8, direction);
var _y = y + lengthdir_y(8, direction);
part_particles_create(global.part_sys, _x, _y, global.hit_circle, 3);

repeat(10){
	var _rand_min = random_range(opposite_direction - 30, opposite_direction);
	var _rand_max = random_range(opposite_direction, opposite_direction + 30);
	part_type_color3(global.hit_burst, c_white, c_white, c_white);
	part_type_direction(global.hit_burst, _rand_min, _rand_max, 0, 0);
	part_type_orientation(global.hit_burst, 0,  0, 0, 0, true);
	part_particles_create(global.part_sys, _x, _y, global.hit_burst, 1);
}
