image_angle = direction;
speed = Approach(speed, max_speed, .5);
if speed != 0 move_dir = sign(speed);


if create_shells{
	
	create_shells = false 
	//shotgun so create a bunch of bullets in direction 
	repeat(10){
		var _bullet = instance_create_layer(x, y, "Instances", obj_shotgun_effect);
		with(_bullet){
			speed = random_range(5, 18);
			direction = other.direction + random_range(15, -15)
		}
	}
	
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