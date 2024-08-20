//state machine
fsm.step();

//check if on gorund or not
on_ground = (place_meeting(x, y + 1, obj_wall));

//if hit and hurt box doesnt exist give 2 seconds of invulnerability then recreate it
if(!instance_exists(obj_hurtbox) and be_invulnerable){
	invulnerability--;
	if (invulnerability <= -1){
		//recreate the hurtbox after invulnerability is up
		instance_create_layer(x, y, "Player", obj_hurtbox);
		invulnerability = invulnerability_max;
		be_invulnerable = false;
	}
}

//lerp back to normal size for squash and stretch
xscale = lerp(xscale, 1, 0.2);
yscale = lerp(yscale, 1, 0.2);

//shadow (use this for dash or roll state)
if (on_ground) can_dash = true;




//dash_timer--
//if dash_timer <= 0 {
//	with (instance_create_layer(x, y, "Player", obj_trail)){
//		sprite_index = other.sprite_index;
//		image_index = other.image_index;
//		image_xscale = other.facing;
//		image_speed = 0;
//		image_blend = #d00070;
//		//var _t = random(3)
//		//if(_t <= 1) image_blend = c_aqua else if (_t > 1 and _t <= 2) image_blend = c_fuchsia else image_blend = c_green
//		image_alpha = 1;
//	}
//	dash_timer = dash_timer_max;
//}



show_debug_message(self.hp);