//state machine
fsm.step();

//check all grapples instances
if(!ds_list_empty(grapple_target_list)){
	//for each grapple point in the list check only the ones in front of you, then check dsitance and pick closest
	var dist = 0;
	for (var i = 0; i < ds_list_size(grapple_target_list); i++){		
		if (dist < point_distance(x + hsp, y - sprite_height/2, grapple_target_list[|i].x, grapple_target_list[|i].y)){
			dist = point_distance(x + hsp, y - sprite_height/2, grapple_target_list[|i].x,grapple_target_list[|i].y);
			//make sure were not already mocing to a grapple point
			if(fsm.get_current_state() != "grapple initiate" and fsm.get_current_state() != "grapple move"){
				//set new grapple point
				grapple_target = grapple_target_list[|i];
			}
		}
		can_grapple = true;
	}
	//show_debug_message(grapple_target.x)
} else {
	
	can_grapple = false;
	grapple_target = noone;
}

//show_debug_message(ds_list_size(grapple_target_list))

//check if on ground or not
on_ground = onGround(self)
//show_debug_message(onGround(self));
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

//change sound for material youre on TODO: fix this oop later
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

//show_debug_message(vsp)