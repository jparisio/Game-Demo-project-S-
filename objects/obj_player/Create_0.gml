//movements
hsp = 0;
vsp = 0;
vsp_jump = -6;
global_grv = 0.27;
grv = global_grv;
walksp = 0;
max_walksp = 4;
approach_walksp_max = 0.3;
approach_walksp = approach_walksp_max;
coyote_time = 4;
can_jump = true;
jump_buffer_max = 5;
jump_buffer = jump_buffer_max;
peak_grv = global_grv / 2;
stored_velocity = 0;
stored_velocity_timer = 6;
input_dir = 0;
decelerate_ground = 0.2;
decelerate_air = 0.1;
decelerate = decelerate_ground
//grapples
can_grapple = false;
grapple_target = noone;
grapple_target_list = ds_list_create();
grapple_move_speed_x = 0;
grapple_move_speed_y = 0;
grapple_new_x = 0;
grapple_new_y = 0;
grapple_speed = 7;
grapple_direction = 0;
katana = noone;
grapple_frames = 4;
grapple_target_dist = 0;
grapple_cooldown = 0;
grapple_cooldown_max = 30;
grapple_coll_line = 0;
tween = 0;
//respawn 
respawn_point = noone;

// Sprites for Act 1 (scarlet)
sprites_scar = {
    idle: spr_idle,
    run: spr_run,
	run_to_idle: spr_run_to_idle,
	idle_to_run: spr_idle_to_run,
    jump: spr_jump,
	jump_start: spr_jump_start,
	jump_fall_start: spr_jump_fall_start,
	jump_fall: spr_jump_fall,
	dash: spr_dash2,
	wall_slide: spr_wall_slide
};

// Sprites for Act 2 (ghost switch)
sprites_ghost = {
    idle: spr_ghost_idle,
    run: spr_run,
	run_to_idle: spr_run_to_idle,
	idle_to_run: spr_idle_to_run,
    jump: spr_ghost_jump,
	jump_start: spr_ghost_jump,
	jump_fall_start: spr_ghost_jump,
	jump_fall: spr_ghost_jump,
	dash: spr_dash2,
	wall_slide: spr_ghost_wall_slide
};

// character instance with sprites
player_character = character(sprites_scar, sprites_ghost);

//cutscenes
cutscene_instance = noone;

//squash and stretch
xscale = 1;
yscale = 1;

//dash
can_dash = false;
dash_timer_max = 5;
dash_timer = dash_timer_max;
dash_length_max = 15;
dash_length = dash_length_max;
dash_direction = 0;
dash_x = 0;
dash_y = 0;

//wall
on_wall = 0;
wall_fric = 0.25;
wall_jump_frames_max = 9;
wall_jump_frames = wall_jump_frames_max ;
wall_jump_hsp = 0;
wall_jump_hsp_max = 4;
slash_dir = 0;

facing = 1;
y_dir = 0;

hit_dir = -1;

on_ground = 0;
on_one_way = false;

move_amount = 0;

slow_time_meter = 250;
refill = 200;

//health
hp = 50;

//damage
damage = 5;
invulnerability_max = 60 * 2;
invulnerability = invulnerability_max;
be_invulnerable = false;
pushback = 2;
kill_push_back = 6;
frame_counter = 0;
flash_alpha = 0;
already_hit = false;

//dialogue
dialogue_buffer = 10
talking = false

//sound
sound_frame_counter = 0;
walking_on = snd_walk2;

//cam
cam_bounds = noone;


//movement
get_input_and_move = function() {
	
	//input
	left = input_check("left");
    right = input_check("right");
	up = input_check("up");
	down = input_check("down");
	if (can_jump) jump = input_check("jump") else jump = 0;
	attack = input_check_pressed("shoot");
	dash = input_check_pressed("special");
	throw_grapple = input_check_pressed("aim");
	
	//calc
	var move = right - left;

	if(left xor right){
		//walksp = lerp(walksp, max_walksp, approach_walksp);
		walksp = Approach(walksp, max_walksp, approach_walksp);
	} else {
		walksp = 0;
	}
	walksp = min(walksp, max_walksp);
	hsp += move * walksp;
	hsp = lerp(hsp, 0, decelerate);
	if(abs(hsp) <= .1) hsp = 0;
	hsp = min(abs(hsp), max_walksp) * sign(hsp)
	
	//add gravity
	vsp+=grv;

	//hori
	if place_meeting(x+hsp,y,obj_wall_parent) {
	    while !place_meeting(x+sign(hsp),y,obj_wall_parent) {
	        x += sign(hsp);
	    }
	    hsp = 0;
	}
	x += hsp;

	//vert
	if place_meeting(x,y + vsp,obj_wall_parent) {
	    while !place_meeting(x,y+sign(vsp),obj_wall_parent) {
	        y += sign(vsp);
	    }
	    vsp = 0;
	}
	
	//one way
	var _one_way = instance_place(x, y + max(1, vsp), obj_one_way_plat);
	if _one_way != noone {
	if bbox_bottom < _one_way.bbox_bottom && vsp > 0 && !down
		{
		//stop moving or snap player to other.bbox_top eg.
		  y = _one_way.bbox_top - (bbox_bottom - y)
		  vsp = 0;
		}
		
	}
	
	y += vsp;
	
}

collide_and_move = function(_hsp, _vsp){
	
hsp = _hsp
vsp = _vsp
//hori
	if place_meeting(x+hsp,y,obj_wall_parent) {
	    while !place_meeting(x+sign(hsp),y,obj_wall_parent) {
	        x += sign(hsp);
	    }
	    hsp = 0;
	}
	x += hsp;

	//vert
	if place_meeting(x,y + vsp,obj_wall_parent) {
	    while !place_meeting(x,y+sign(vsp),obj_wall_parent) {
	        y += sign(vsp);
	    }
	    vsp = 0;
	}
	y += vsp;

}

determine_facing = function(){
	
	if(hsp != 0){
		facing = sign(hsp)
	}
}
	
	
	
	
	
//states
fsm = new SnowState("idle")

fsm
	.add("idle", {
		enter: function() {
			//normal return to idle
			sprite_index = player_character.setSprite("idle");
			image_index = 0;
			
			//return after run or dash
			if(fsm.get_previous_state() == "run" or fsm.get_previous_state() == "dash" or fsm.get_previous_state() == "grapple enemy"){
				sprite_index = player_character.setSprite("rtoi");
				image_index = 0;
			}
			
			//return after jump !TODO: this is a temp landing animation
			if(fsm.get_previous_state() == "jump"){
				sprite_index = player_character.setSprite("rtoi");
				image_index = 0;
			}
			//for move cap stuff
			approach_walksp = approach_walksp_max;
			
		},
		step: function() {
			
			//transition from running to idle animation
			if(player_character.getSpriteState() == "rtoi") and animation_end(){
				sprite_index = player_character.setSprite("idle");
				image_index = 0;
			}
			
			//movement
			get_input_and_move();
			determine_facing();
			
			//switch to dialogue if meeting a dialogue block and enter pressed
			if(place_meeting(x, y, obj_dialogue_collision) and input_check_pressed("action")){
				fsm.change("dialogue");
			}
			
			
			//if holding one move key
			if (right xor left) {
				fsm.change("run");
			}
			
			//check if player has let go of jump
			if(input_check_released("jump") or !input_check("jump")) can_jump = true;
			
			//jump check
			if(jump){
			  xscale = .75;
			  yscale = 1.25;
			  vsp = vsp_jump + stored_velocity;
			  instance_create_layer(x, y, "Instances", obj_dust_jump);
		      fsm.change("jump");
			}
			
			//attack check
			if(attack) fsm.change("attack");
			
			//dash check
			if(dash and can_dash) fsm.change("dash");
			
			//edge case for falling off block
			if(!on_ground(self)){
				fsm.change("jump");
			}
			
			//switch to finisher
			var _circle = instance_place(x, y, obj_finisher_circle);
			if (input_check_pressed("cancel") and _circle){
				fsm.change("finisher");
				instance_destroy(obj_finisher_circle);
			}
			
			//cutscene
			if(place_meeting(x,y, obj_cutscene_collision)) fsm.change("dialogue");
			
			
			//grapple
			if(grapple_target != noone){
				grapple_coll_line = collision_line(x, y - 20, grapple_target.x, grapple_target.y, obj_wall_parent, false, true)
				//show_debug_message(coll)
			}
			
			//grapple check
			if(can_grapple and throw_grapple and grapple_coll_line == -4) fsm.change("grapple initiate");
			
	   }
  })
  
	
	.add("run", {
		enter: function(){
			sprite_index = spr_run;
			image_index = 0;
			coyote_time = 7;
			
			//run to idle
			if(fsm.get_previous_state() == "idle"){
				sprite_index = player_character.setSprite("itor");
				image_index = 0;
			}
			
			if(fsm.get_previous_state() == "dash"){
				image_index = 5;
			}
			
			var dust_dir = 1
			if right dust_dir = 1 else dust_dir = -1
			instance_create_layer(x, y, "Instances", obj_dust_run).image_xscale = dust_dir;
			
			//play sound for initial step
			if!(audio_is_playing(walking_on)) audio_play_sound(walking_on, 0, false, 0.2);
			
			//for move cap stuff
			approach_walksp = approach_walksp_max;
			
			input_dir = sign(facing);
			
		},
		
		step: function(){
			
			
			
			//transition from idle to run animation
			if(sprite_index ==  player_character.setSprite("itor")) and animation_end(){
				sprite_index = player_character.setSprite("run");
				image_index = 0;
			}
			
			//move
			get_input_and_move();
			determine_facing();
			
			//if turn around stop momentum
			if(sign(facing) != input_dir){
				input_dir = sign(facing);
				walksp = 0;
				hsp = 0;
				fsm.change("idle");
			}
			
			//for cutscene 
			if (cutscene_instance != noone){
				fsm.change("cutscene");
				cutscene_instance.start = true;
			}
			
			//sound
			//evbery 4 frames play sound sndwalk or snd_walk2 randomized
			// Increment the frame counter
			sound_frame_counter++;

			// Check if 4 frames have passed
			if (sound_frame_counter >= 18) {
			    // Reset the counter
			    sound_frame_counter = 0;
				//play audio
			    var volume = .6
			    audio_play_sound(walking_on, 0, false, volume);
			}
			
			//switch to dialogue if meeting a dialogue block and enter pressed
			//if(place_meeting(x, y, obj_dialogue_collision) and input_check_pressed("action")){
			//	fsm.change("dialogue");
			//}
			
						
			//cutscene check
			if(place_meeting(x,y, obj_cutscene_collision)) fsm.change("dialogue");
			
			//not holding move, switch to idle
			if ((!right and !left) or (right and left)){
				fsm.change("idle");
			}
			
					
			//check if player has let go of jump
			if(input_check_released("jump") or !input_check("jump")) can_jump = true;
			
			//jump
			if(jump){
				xscale = .75;
				yscale = 1.25;
				vsp = vsp_jump;
				instance_create_layer(x, y, "Instances", obj_dust_jump);
				fsm.change("jump");
			}
			
			//run off edge
			if(!on_ground(self)){
				coyote_time--;
				vsp = 0;
				//coyote time
				if(jump and coyote_time >=0){
					vsp = vsp_jump + stored_velocity;
					//show_debug_message("YAY")
					fsm.change("jump");
				} else if(coyote_time <= 0) fsm.change("jump");
			}
			
			//switch to attack
			if(attack) fsm.change("attack");
			
			//dash check
			if(dash and can_dash) fsm.change("dash");
			
			//grapple
			if(grapple_target != noone){
				grapple_coll_line = collision_line(x, y - 20, grapple_target.x, grapple_target.y, obj_wall_parent, false, true)
				//show_debug_message(coll)
			}
			
			//grapple check
			if(can_grapple and throw_grapple and grapple_coll_line == -4) fsm.change("grapple initiate");
			
	  }
})
	
	
	
	.add("jump", {
		
		enter: function(){
			sprite_index =  player_character.setSprite("jstart");
			image_index = 0;
			if(fsm.get_previous_state() == "dash"){
				sprite_index = spr_dash_to_jump;
				image_index = 0;
			}
			can_jump = false;
			//dont play this if last state was a wall jump
			if(fsm.get_previous_state() != "wall jump") audio_play_sound(snd_jump, 0, false, .05);
			input_dir = sign(facing);
			//make air accel slower
			approach_walksp = 0.1;
			//show_debug_message("START JUMP")
		},
		
		step: function(){
			
			//carry momentum -> if player moves in the opposite direction of jump, cut their hsp/acceleration
			if(sign(facing) != input_dir){
				input_dir = sign(facing);
				walksp = 0;
				hsp = 0;
				if(fsm.get_previous_state() == "wall jump"){
					approach_walksp = 0.025;
				} else {
					approach_walksp = 0.1;
				}
			}

			
			//move
			get_input_and_move();
			determine_facing();
			

			//change animations
			//show_debug_message( player_character.getSpriteState());
			if(player_character.getSpriteState() == "jstart" and animation_end()){
				sprite_index =  player_character.setSprite("jump");
				image_index = 0;
			}
			
			//variable jump
			if(!input_check("jump")) vsp = max(vsp, -2);
			
			//half grav at peak of jump 
			if(vsp >= -0.4 and vsp <= 0.4){
				grv = peak_grv;
			} else {
				grv = global_grv;
			}
		
			
			//show_debug_message("vsp is :" + string(vsp));
			//show_debug_message("grv is :" + string(grv));  
			
			//animations
			if (vsp >= 0.5 and vsp <= 1 and sprite_index != spr_dash_to_jump){ //this is because we dont want it to be stuck on index 0 for forever we want it to only activate at the turn  around point
				sprite_index =  player_character.setSprite("jfalls");
				image_index = 0;
			}

			//if not equal to jump fall start anim 
			if(player_character.getSpriteState() == "jfalls" and animation_end() or sprite_index == spr_dash_to_jump and animation_end()){
				sprite_index =  player_character.setSprite("jfall");
				image_index = 0;
			}
			
			//check if colliding with bottom of wall
			if(place_meeting(x, y - 1, obj_wall_parent)) vsp = 1;
			
			//if let go of jump, can press it again
			if(input_check_released("jump")) can_jump = true;
			
			//jump buffer
			if(input_check("jump") and can_jump) jump_buffer = jump_buffer_max;
			if(jump_buffer >= 0){
				jump_buffer--;
				if(on_ground(self)){
					vsp = vsp_jump;
					sprite_index =  player_character.setSprite("jstart");
					can_jump = false;
				}
			} else if(on_ground(self)){
				xscale = 1.25;
				yscale = 0.75;
				can_jump = false
				audio_play_sound(snd_land, 0, 0, 0.6)
				fsm.change("idle");
			}
			
			//attack switch
			if(attack) fsm.change("attack");
			
			//dash check
			if(dash and can_dash) fsm.change("dash");
			
			//grapple
			if(grapple_target != noone){
				grapple_coll_line = collision_line(x, y - 20, grapple_target.x, grapple_target.y, obj_wall_parent, false, true)
				//show_debug_message(coll)
			}
			
			//grapple check
			if(can_grapple and throw_grapple and !grapple_coll_line) fsm.change("grapple initiate");
			
			//wall slide check
			if(place_meeting(x + sign(facing), y, obj_slide_wall) and vsp >= 0){
				fsm.change("wall slide");
			} 
			
	  }
})

	.add("wall slide", {
		
		enter: function(){
			grv = global_grv;
			grv = grv * wall_fric;
			sprite_index = player_character.setSprite("wslide");
			//approach_walksp = 0.04;
			audio_play_sound(snd_wall_slide, 0, 1);
		},
		
		step: function(){
			//create dust
			var _x = x + 12 * facing
			var _max = y - sprite_height / 2
			var _min = y;
			var _y = random_range(_min, _max);
			instance_create_layer(_x, _y, "Instances", obj_slide_dust);
			
			
			//movement 
			if(input_check_pressed("jump")) fsm.change("wall jump");
			if(!place_meeting(x + sign(facing), y, obj_slide_wall)){
				determine_facing();
				grv = global_grv;
				audio_stop_sound(snd_wall_slide);
				fsm.change("jump");
			}
			//show_debug_message(vsp)
			//cap the vsp on the wall
			vsp = min(vsp, 3.8);
			get_input_and_move();
		}
})

	.add("wall jump", {
		
		enter: function(){
			audio_stop_sound(snd_wall_slide);
			audio_play_sound(snd_wall_jump, 0, 0);
			sprite_index = spr_jump;
			image_index = 0;
			wall_jump_frames = wall_jump_frames_max ;
			grv = global_grv;
			wall_jump_hsp = wall_jump_hsp_max * - facing
			//wall_jump_hsp_max *= -facing
		},
		
		step: function(){
			wall_jump_frames --
		    //wall_jump_hsp = lerp(wall_jump_hsp, sign(wall_jump_hsp) * max_walksp, 0.1);
			//wall_jump_hsp = lerp(wall_jump_hsp, wall_jump_hsp_max, .3);
			//show_debug_message(wall_jump_hsp)
			collide_and_move(wall_jump_hsp, -3);
			determine_facing();
			
			if wall_jump_frames <= 0 fsm.change("jump");
		}
})

	.add("attack", {
		
		enter: function(){
			//sprite_index = spr_attack;
			//image_index = 0;
			//create the hitbox
			create_hitbox("player", obj_player, x, y, facing, spr_hitbox, 1, damage);
			instance_create_layer(x, y, "Instances", obj_slash).image_xscale = facing;
			//website for sound effects
			//https://artlist.io/sfx/search?terms=juicy
			//https://artlist.io/sfx/search?terms=hit&terms=juicy
			//https://artlist.io/sfx/track/cartoonish---ninja-sword-swing-squishy-hit/66937
			var slash_sound = random(2)
			if(slash_sound > 1) {
				audio_play_sound(snd_slash1, 30, 0, 8);
			} else {
				audio_play_sound(snd_slash2, 30, 0, 8);
			}
		},
		
		step: function(){
			//move
			get_input_and_move();
			//determine_facing();
			
			//hit enemy details
			//if(animation_hit_frame(1)){
			//	create_hitbox("player", x, y, facing, spr_hitbox, 1, damage);
			//}
				
		
			//switch back to idle on ground or air in air
			//if(animation_end()){
			//	if place_meeting(x, y + 1, obj_wall){
			//		fsm.change("idle")
			//	} else fsm.change("jump")
			//}
			
			if(!instance_exists(obj_slash)){
				if place_meeting(x, y + 1, obj_wall_parent){
					fsm.change("idle")
				} else fsm.change("jump")
			}
			
			
		}
})

	.add("finisher", {
		
		enter: function(){
			image_index = 0;
			sprite_index = spr_steady;
		},
		
		step: function(){
			//TODO right now skipping spin but idk if i like the spin or without the spin
			if (sprite_index == spr_steady and animation_end()) {
				sprite_index = spr_finisher;
				image_index = 0;
			} else if (sprite_index == spr_katana_spin and animation_end()){
				sprite_index = spr_finisher;
				image_index = 0;
			} else if (sprite_index == spr_finisher and animation_end()){
				sprite_index = spr_release;
				image_index = 0;
			} else if (sprite_index == spr_release and animation_end()){
				fsm.change("idle");
			}
			
			if(sprite_index = spr_finisher) and animation_hit_frame(5){
				instance_create_layer(x, y, "Instances", obj_finisher_hit_box).image_xscale = facing;
			}
		
			
		}
})


	.add("dash", {
		
		enter: function(){
			sprite_index =  player_character.setSprite("dash");
			image_index = 0;
			image_speed = 1;
			with(instance_create_layer(x, y, "Instances", obj_dust_jump)){
				sprite_index = spr_jump_dust3
				image_index = 0;
				image_speed = 1;
			}
			grv = 0;
			dash_length = dash_length_max;
			dash_x = 0;
			dash_y = 0;
			xscale = 1.25
			yscale = 0.65
			//no more dashing upwards
			if (right - left != 0) {
				dash_direction = point_direction(0, 0, right - left, 0);
			} else {
				dash_direction = point_direction(0, 0, facing, 0);
			}
			//determine dash dir (the .4 is a magic number that decreases the angle you dash at so it isnt so sharp)
			//if (right - left != 0){
			//	dash_direction = point_direction(0, 0, right - left + .4 * facing, down - up)
			//} else if(right - left == 0 and down - up != 0){
			//	dash_direction = point_direction(0, 0, 0, down - up)
			//} else dash_direction = point_direction(0, 0, facing, down - up);
			//create screenshake
			instance_create_layer(x, y, "Instances", obj_screenshake);
			if instance_exists(obj_hurtbox) {
			    instance_destroy(obj_hurtbox);
			}
			audio_play_sound(snd_dash, 5, 0, .3)
		},
		
		step: function(){
			
			if(dash_length >= 0){
				dash_length--;
				//wall slide check
				if(place_meeting(x + sign(facing), y, obj_slide_wall) and vsp >= 0){
					image_speed = 1;
					grv = global_grv * wall_fric; // Gradually apply gravity for wall slide
					can_dash = false;
					instance_create_layer(x, y, "Player", obj_hurtbox);
					fsm.change("wall slide");
				} 
			
				//speed up the dash at end
				dash_x = lerp(dash_x, 7, .5);
				dash_y = lerp(dash_y, 7, .5);
				//move
				hsp = lengthdir_x(dash_x, dash_direction);
				vsp = lengthdir_y(dash_y, dash_direction);
				determine_facing();
				//move
				collide_and_move(hsp, vsp);
				//create dash trail
				dash_timer--
				if dash_timer <= 0 {
					with (instance_create_layer(x, y, "Player", obj_trail)){
						sprite_index = other.sprite_index;
						image_index = other.image_index;
						image_xscale = other.facing;
						image_speed = 0;
						image_blend = #760D3A;
						image_alpha = 1;
					}
					dash_timer = dash_timer_max;
				}
			} else {
				//switch to air if in air otherwise ground idle
				image_speed = 1;
				grv = global_grv;
				can_dash = false;
				//make sure were not spawning in another hitbox while in hitsun cancelling our invul frames
				if (!instance_exists(obj_hurtbox) and !be_invulnerable){
				    instance_create_layer(x, y, "Player", obj_hurtbox);
				}
				if(place_meeting(x, y + 1, obj_wall_parent)){
					if(!left and !right){
						fsm.change("idle");
					} else {
						fsm.change("run");
					}
				} else {
					fsm.change("jump");
				}

				//if(place_meeting(x, y, obj_cutscene_collision)) fsm.change("dialogue");
			}
		}
})


	.add("dialogue", {
		
		enter: function(){
			//sprite_index = spr_idle;
			talking = true;
			dialogue_buffer = 10;
			if (sprite_index != spr_run and sprite_index != spr_idle and sprite_index != spr_run_to_idle){
				sprite_index = spr_run_to_idle;
				image_index = 0;
			}
			
		},
		
		step: function(){
			vsp+=grv;
			//collide_and_move(0 , vsp);
			
			//stop animation from looping
			if (sprite_index == spr_run or sprite_index == spr_idle_to_run){
				sprite_index = spr_run_to_idle;
				image_index = 0;
			}
			if (sprite_index == spr_run_to_idle and animation_end()) sprite_index = spr_idle; //just leave this line too

			var _dialogue_box = instance_place(x, y, obj_dialogue_collision); //and this and chance target to _dialogue box
			
			var _cutscene_box = instance_place(x, y, obj_cutscene_collision); //probably move this shit to another state tbh
			
			var _target = _dialogue_box == noone? _cutscene_box: _dialogue_box //that includes this
			
			if(_target != noone){
				with(_target){
					//show_debug_message(_self)
					if(!instance_exists(obj_text) and timer <= 0 and obj_player.talking == true){
						with(instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_text)){
							//create script with the id retrieved from this
							current_dialogue_id = other.text_id;
							create_above = other.create_above;
						}
					}
				}
			}
			
			if talking == false {
				//need a small buffer so player doesnt jump after hitting space
				dialogue_buffer--;
				if(dialogue_buffer <= 0){
					hsp = 0;
					vsp = 0;
					//talking = false;
					fsm.change("idle");
				}
			}

		}
})


	.add("grapple initiate", {

	    enter: function() {
		
			//set hsp and vsp to 0
			hsp = 0;
			vsp = 0;
			//play throw sound
			audio_play_sound(snd_grapple_throw, 10, 0);
			//reset grapple flag
			can_grapple = false;
	        // Set the player's sprite to a jumping or grappling sprite
	        sprite_index = spr_jump;
			facing = sign(grapple_target.x - x) == 0? 1 : sign(grapple_target.x - x);

	        // Calculate the direction and speed to move toward the grapple point
	        var dx = grapple_target.x - x;
	        var dy = grapple_target.y - (y - sprite_height / 2);
	        var dist = point_distance(x, y - sprite_height / 2, grapple_target.x, grapple_target.y);

	        // Calculate the katana's speed (twice the grapple speed)
	        var katana_speed = grapple_speed * 3;
	        var katana_move_speed_x = dx / dist * katana_speed;
	        var katana_move_speed_y = dy / dist * katana_speed;

	        // Create and launch the katana object toward the grapple point
	        var katana = instance_create_layer(x, y - sprite_height / 2, "Instances", obj_katana);
	        katana.hspeed = katana_move_speed_x;
	        katana.vspeed = katana_move_speed_y;
	        katana.image_angle = point_direction(x, y, grapple_target.x, grapple_target.y);
			
	        // Store the katana reference to check its position later
	        self.katana = katana;
	    },

	    step: function() {
			//TweenEasyMove(x, y, grapple_target.x, grapple_target.y, 0, 30, EaseInOutSine);
	        // Check if the katana has reached the grapple point
	        if (instance_place(katana.x, katana.y, obj_grapple_point)) {
	            // Snap the katana to the grapple point and destroy it
	            katana.x = grapple_target.x;
	            katana.y = grapple_target.y;
				katana.speed = 0;
	            //instance_destroy(katana);

	            // Transition to the grapple move state
	            fsm.change("grapple move");
	        }
	    }
	})

	
	
	.add("grapple move", {
		
			enter: function(){
				audio_play_sound(snd_grapple_rope, 10, 0);
				//set these for if player moves through the grapple target
			},
		
			step: function(){
				// Move the player along the line towards the grapple point
			    //tween = TweenEasyMove(x, y, grapple_target.x, grapple_target.y + 30, 0, 30, EaseOutElastic);
				//work tweens in later	
			     
			    grapple_target_dist = point_distance(x, y - sprite_height / 2, grapple_target.x, grapple_target.y);
				grapple_direction = point_direction(x, y - sprite_height / 2, grapple_target.x, grapple_target.y);
				hsp = lengthdir_x(grapple_target_dist, grapple_direction) * 0.5;
				vsp = lengthdir_y(grapple_target_dist, grapple_direction) * 0.5;
				x += hsp;
				y += vsp;
				
				//here check for the spot your ending up at make sure its not in a wall
				
			
				//Check if the player has reached the grapple point
			    if (grapple_target_dist <= grapple_speed) {
					// Make sure the player is not inside a wall
				     // Adjust upwards (top)
				    while (place_meeting(x, bbox_top, obj_wall_parent)) {
				        y += 1;
				    }
    
				    // Adjust downwards (bottom)
				    while (place_meeting(x, bbox_bottom, obj_wall_parent)) {
				        y -= 1;
				    }
    
				    // Adjust left (left side)
				    while (place_meeting(bbox_left, y, obj_wall_parent)) {
				        x += 1;
				    }
    
				    // Adjust right (right side)
				    while (place_meeting(bbox_right, y, obj_wall_parent)) {
				        x -= 1;
				    }
			        // Transition to the "grapple complete" state
					if (grapple_target.creator == "enemy"){
						fsm.change("grapple enemy");
					} else {
						fsm.change("grapple hang");
					}
				}
				
			}
	})
	
	.add("grapple hang", {
		
			enter: function(){
				// Snap to the exact grapple point
				x = grapple_target.x;
				y = grapple_target.y + sprite_height / 2;
				grapple_cooldown = grapple_cooldown_max;
				audio_stop_sound(snd_grapple_rope);
				audio_play_sound(snd_grapple_rope_complete, 10 , 0);
				instance_destroy(katana);
				//regen a dash
				can_dash = true;
			},
		
			step: function(){
				if(input_check_pressed("jump")){
						TweenDestroy(tween);
						grapple_target.cooldown = true;
						vsp = vsp_jump;
						fsm.change("jump");
				}
			}
	})
	
	
	.add("grapple enemy", {
			enter: function() {
				grapple_cooldown = grapple_cooldown_max;
				audio_stop_sound(snd_grapple_rope);
				audio_play_sound(snd_injured, 13, 0, 20, 0.1, 1);
				audio_play_sound(snd_unsheath, 12, 0, 40, 0.1, 1);
				//audio_play_sound(snd_old_dash, 10, 0, 3, 0, 2);
				instance_destroy(katana);
				//set enemy id attached to the grapple to dead state
				grapple_target.follow.grappled_to = true;
				create_shake();
				
				//gain a dash
				can_dash = true;
				
				
				// Keep momentum for a few frames
				grapple_frames = 9;
				hsp *= 4;
				vsp *= 4;
				
				vsp = clamp(vsp, vsp_jump, -vsp_jump);
				
				//add momentum to enemy
				grapple_target.follow.hsp = hsp / 2;
				grapple_target.follow.vsp = vsp / 2;
				
				//clean up left over grapple
				var _i = ds_list_find_index(obj_player.grapple_target_list, grapple_target);
				ds_list_delete(obj_player.grapple_target_list, _i);
				instance_destroy(grapple_target);
				grapple_target = noone;
				can_grapple = false;
		

				
				
			},
	
			step: function() {
				// Continue momentum from the last direction
				grapple_frames--;
					
				// Move player using hsp and vsp
				collide_and_move(hsp, vsp);
		
				// End state after 4 frames
				if (grapple_frames <= 0) {
					if on_ground fsm.change("idle") else fsm.change("jump");
				}
			}
		})
	
	.add("cutscene", {
		
			enter: function(){
					hsp = 0;
					vsp = 0;
					global.cutscene_ended = false;
			},
		
			step: function(){
				
				if (global.cutscene_ended){
					image_speed = 1;
					fsm.change("idle");
				}

			}
	})

	.add("dead", {
		
			enter: function(){
					audio_stop_all();
					instance_create_layer(x, y, "Instances", obj_glitch);
					if !audio_is_playing(snd_glitch) audio_play_sound(snd_glitch, 40, 0, 40, 0.9)
					sprite_index = spr_dead;
					instance_destroy(obj_hurtbox);
				
					_x = camera_get_view_x(view_camera[0]) + (camera_get_view_width(view_camera[0])/2)
					_y = camera_get_view_y(view_camera[0]) + (camera_get_view_height(view_camera[0])/2)
					instance_create_layer(_x, _y, "Lighting", obj_death);


			},
		
			step: function(){
					if(!instance_exists(obj_glitch)){
				
				}
			}
	});
