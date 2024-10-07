//state machine
fsm.step();

//check if on gorund or not
on_ground = (place_meeting(x, y + 1, obj_wall_parent));
if(on_ground){
	decelerate = decelerate_ground;
} else {
	decelerate = decelerate_air;
}

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

//reset the dash if on ground
if (on_ground) can_dash = true;

//if theres a force applied to the player velocity, store it for 4 frames, thn clear it
if (stored_velocity != 0) {
	stored_velocity_timer--
	if(stored_velocity_timer <= 0){
		stored_velocity = 0;
		//reset this 
		stored_velocity_timer = 6;
	}
}

//change sound for material youre on 
if(place_meeting(x, y, obj_water)){
	walking_on = snd_water_walk;
} else {
	walking_on = snd_walk2;
}


if (hp <= 0) and fsm.get_current_state() != "dead"{
	fsm.change("dead");
}


//respawn to last respawn point
if(instance_place(x, y, obj_respawn_point) != noone){
	respawn_point = instance_place(x, y, obj_respawn_point);
}

if instance_place(x, y, obj_respawner){
	x = respawn_point.x;
	y = respawn_point.y;
}


cam_bounds = instance_place(x, y, obj_cam_bounds);

cutscene_instance = instance_place(x, y, obj_cutscene);


//show_debug_message(hsp);