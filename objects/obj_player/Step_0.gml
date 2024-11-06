//-----------------------------------------------------grapple-----------------------------------------------------------------//
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

if(grapple_target != noone){
	grapple_coll_line = collision_line(x, y - 20, grapple_target.x, grapple_target.y, obj_wall_parent, false, true)
}

//--------------------------------------------------state machine---------------------------------------------------------------//
// Update character state
fsm.step();
// Trigger state transitions based on current conditions
fsm.trigger("to_idle");
fsm.trigger("to_run");
fsm.trigger("t_coyote_jump");
fsm.trigger("to_jump");
fsm.trigger("to_wall_slide");
fsm.trigger("fall_off");
fsm.trigger("to_attack");
fsm.trigger("to_shoot");
fsm.trigger("shoot_to_idle");
fsm.trigger("to_dash");
fsm.trigger("to_grapple");
fsm.trigger("to_dialogue");
fsm.trigger("to_cut_dialogue");
fsm.trigger("to_cutscene");
fsm.trigger("grap_to_jump");
fsm.trigger("wall_slide_to_wall_jump");
fsm.trigger("wall_slide_to_jump");
fsm.trigger("wall_slide_to_idle");
fsm.trigger("wall_jump_to_jump");

//-------------------------------------------------other stuff------------------------------------------------------------------//
//check if on ground or not
if(on_ground(self)){
	decelerate = decelerate_ground;
	//reset dash
	can_dash = true;
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

if instance_place(x, y, obj_respawner) and fsm.get_current_state() != "injured"{
	fsm.change("injured");
}


cam_bounds = instance_place(x, y, obj_cam_bounds);

cutscene_instance = instance_place(x, y, obj_cutscene);

//var _bullets = gun.get_bullets()
//show_debug_message(vsp);
//show_debug_message(hsp);