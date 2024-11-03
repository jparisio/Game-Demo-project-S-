image_angle = direction;
speed = Approach(speed, max_speed, .5);
if speed != 0 move_dir = sign(speed);


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