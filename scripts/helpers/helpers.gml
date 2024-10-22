

function create_hitbox(_creator, _follow, _x, _y, _facing, _sprite, _lifespan, _damage, _yscale = 1){
	var _hitbox = instance_create_layer(_x, _y, "Instances", obj_hitbox)
	_hitbox.sprite_index = _sprite;
	_hitbox.facing = _facing
	_hitbox.image_xscale = _facing;
	_hitbox.image_yscale = _yscale;
	_hitbox.creator = _creator;
	_hitbox.lifespan = _lifespan;
	_hitbox.damage = _damage;
	_hitbox.follow = _follow;

}


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



function hit_pause(_time){
	
	var _t = current_time + _time
	while(current_time <= _t){}
	
}

function create_shake(shake_type = "large"){
	
	if(shake_type == "large"){
		instance_create_layer(x, y, "Instances", obj_screenshake_large)
	} else if(shake_type = "small"){
		instance_create_layer(x, y, "Instances", obj_screenshake)
	} else if(shake_type == "spring"){
		instance_create_layer(x, y, "Instances", obj_screenshake_spring);
	}
}
