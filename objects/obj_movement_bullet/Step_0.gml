image_angle = direction;
speed = Approach(speed, max_speed, .5);
if speed != 0 move_dir = sign(speed);


if create_shells{
	repeat(10){
		create_shells = false;
		var _bullet = instance_create_layer(x, y, "Instances", obj_bullet);
		with(_bullet){
			speed = random_range(5, 18);
			direction = other.direction + random_range(15, -15)
		}
	}
	//create_shells = false 
	////shotgun so create a bunch of bullets in direction 
	//repeat(10){
	//	var _bullet = instance_create_layer(x, y, "Instances", obj_shotgun_effect);
	//	with(_bullet){
	//		speed = random_range(5, 18);
	//		direction = other.direction + random_range(15, -15)
	//	}
	//}
	//create_shells = false;
	//repeat(20){
	//	var _rand_min = random_range(direction - 30, direction);
	//	var _rand_max = random_range(direction, direction + 30);
	//	//part_type_color3(global.shotgun_blast, c_orange, c_white, c_yellow);
	//	part_type_direction(global.shotgun_blast, _rand_min, _rand_max, 0, 0);
	//	part_type_orientation(global.shotgun_blast, 0,  0, 0, 0, true);
	//	part_particles_create(global.part_sys, x, y, global.shotgun_blast, 1);
	//}
	
}

if (move_frames >= 0){
	move_frames--;
	with (obj_player) {

	    var opposite_dir = other.direction + 180;
		var _speed = 4;
	    // Set the hsp and vsp based on this opposite direction
	    hsp = lengthdir_x(_speed, opposite_dir);
	    vsp = lengthdir_y(_speed, opposite_dir);
	}
}


lifespan--;
if lifespan <= 0 instance_destroy();