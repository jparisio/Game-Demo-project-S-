function create_blood(_angle, _facing, _x, _y, _grv = 0.1) {
    var _blood = instance_create_layer(_x, _y, "Instances", obj_blood);
    with(_blood){
	    image_index = 0; 
	    // Set a random lifetime for the blood particle
	    lifetime = random_range(10, 20);
	    // cycle through blood frames
		 image_speed = 1;
		
		if(_angle != noone){
			direction = _angle + random_range(-15, 15);
			speed = random_range(4, 6);
			image_angle = direction
		} else {
		    // Initialize blood velocity and angle
			var _speed = random_range(4, 6); // Initial speed of the blood particles
			var angle = _facing < 0? random_range( 150 , 180): random_range(30, 0)
    
			// Set the velocity of the blood particles
			hspeed = lengthdir_x(_speed, angle); // Horizontal speed
			vspeed = lengthdir_y(_speed, angle); // Vertical speed
		}

	    // Apply gravity to the blood particles
	    gravity = _grv; 
	    gravity_direction = 270;
		
		//show_debug_message(sign(hspeed))
	
		 // Flip the blood particle's x-scale based on the movement direction
        image_xscale = hspeed < 0 ? -1 : 1;
	}
}