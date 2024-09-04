//state machine
fsm.step();

//check if on gorund or not
on_ground = (place_meeting(x, y + 1, obj_wall_parent));

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

//change sound for material youre on 
if(place_meeting(x, y, obj_water)){
	walking_on = snd_water_walk;
} else {
	walking_on = snd_walk2;
}


if hp <= 0 {
	audio_stop_all()
	instance_create_layer(obj_camera.x, obj_camera.y, "Lighting", obj_game_over);
}

show_debug_message(hsp);

if input_check("pause"){
	fullscreen = !fullscreen;
	window_set_fullscreen(fullscreen);
}