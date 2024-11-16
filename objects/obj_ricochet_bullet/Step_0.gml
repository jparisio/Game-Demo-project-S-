image_angle = direction;
speed = Approach(speed, max_speed, .5);
if speed != 0 move_dir = sign(speed);


if (place_meeting(x + sign(speed), y, obj_wall_parent) and !bounced) {
    direction = 180 - direction;  
	bounced = true;
}
if (place_meeting(x, y + sign(speed), obj_wall_parent) and !bounced) {
    direction = -direction;  // Reverse vertical direction
	bounced = true;
}



