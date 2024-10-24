//state machine
fsm.step();
//fsm.trigger("to_run");
//fsm.trigger("to_jump");
//fsm.trigger("to_attack");
//fsm.trigger("to_dash");
//fsm.trigger("to_grapple");


//check all grapples instances
if (!ds_list_empty(grapple_target_list)) {
    var closest_dist = 9999; // Arbitrarily large number
    for (var i = 0; i < ds_list_size(grapple_target_list); i++) {
        var target = grapple_target_list[| i];
        
        // Check if this target is being hovered
        if (target.mouse_hovering) {
            var dist = point_distance(x + hsp, y - sprite_height / 2, target.x, target.y);
            
            // Check distance and if the target is closer
            if (dist < closest_dist) {
                closest_dist = dist;

                // Make sure we're not already moving to a grapple point or in grapple states
                if (fsm.get_current_state() != "grapple initiate" && fsm.get_current_state() != "grapple move" && fsm.get_current_state() != "grapple hang") {
                    // Set the new grapple point
                    grapple_target = target;
                }
            }
			can_grapple = true;
        } else {
			//reset flag if stopped hovering (need to be hovering to move to grapple point)
			can_grapple = false;
		}
    }
} else {
    // Reset if no valid targets
    can_grapple = false;
    grapple_target = noone;
}

//check if on ground or not
var _on_ground = on_ground(self)
//show_debug_message(on_ground(self));
if(_on_ground){
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
if (on_ground(self)) can_dash = true;

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

//death if hp < 0 
if (hp <= 0) and fsm.get_current_state() != "dead"{
	fsm.change("dead");
}


//respawn to last respawn point
if(instance_place(x, y, obj_respawn_point) != noone){
	respawn_point = instance_place(x, y, obj_respawn_point);
}

if instance_place(x, y, obj_respawner) and fsm.get_current_state() != "injured"{
	//x = respawn_point.x;
	//y = respawn_point.y;
	//reset_room_states();
	fsm.change("injured");
}


cam_bounds = instance_place(x, y, obj_cam_bounds);

cutscene_instance = instance_place(x, y, obj_cutscene);

show_debug_message(instance_exists(obj_reset_room_transition));
//show_debug_message(ds_list_size(grapple_target_list));