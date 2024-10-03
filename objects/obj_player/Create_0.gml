//movements
hsp = 0;
vsp = 0;
vsp_jump = -6;
global_grv = 0.27;
grv = global_grv;
walksp = 0;
max_walksp = 4;
approach_walksp = 0.15;
coyote_time = 4;
can_jump = true;
jump_buffer_max = 5;
jump_buffer = jump_buffer_max;
input_dir = 0;
can_grapple = false;
//grapples
grapple_target = noone;
grapple_move_speed_x = 0;
grapple_move_speed_y = 0;
grapple_speed = 7;
katana = noone;
grapple_cooldown = 0;
grapple_cooldown_max = 30;
tween = 0;
//respawn 
respawn_point = noone;

//ghost sprite switch
global.ghost = false;
// Sprites for Act 1 (scarlet)
sprites_act1 = {
    idle: spr_idle,
    run: spr_run,
	run_to_idle: spr_run_to_idle,
	idle_to_run: spr_idle_to_run,
    jump: spr_jump,
	dash: spr_dash2
};

// Sprites for Act 2 (ghost switch)
sprites_act2 = {
    idle: spr_ghost_idle,
    run: spr_run,
	run_to_idle: spr_run_to_idle,
	idle_to_run: spr_idle_to_run,
    jump: spr_jump,
	dash: spr_dash2
};

// Create a character instance using the sprites
player_character = character(sprites_act1, sprites_act2);

//set fullscreen
//fullscreen = true;

//window_set_fullscreen(true)
//surface_resize(application_surface, display_get_width(), display_get_height())

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
wall_jump_frames = 5;
wall_jump_hsp = 0;
wall_jump_hsp_max = 6;
slash_dir = 0;

facing = 1;
y_dir = 0;

hit_dir = -1;

on_ground = 0;

move_amount = 0;

global.game_speed = 1;
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

//bosses
global.boss_fight = false;

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
	if (can_jump = true) jump = input_check("jump") else jump = 0;
	attack = input_check_pressed("shoot");
	dash = input_check_pressed("special");
	throw_grapple = input_check_pressed("aim");
	
	//calc
	var move = right - left;

	if(left xor right){
		walksp = lerp(walksp, max_walksp, approach_walksp);
	} else {
		walksp = 0;
	}
	walksp = min(walksp, max_walksp);
	hsp += move * walksp;
	hsp = lerp(hsp, 0, .2);
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
			sprite_index = player_character.getSprite("idle");
			image_index = 0;
			
			//return after run or dash
			if(fsm.get_previous_state() == "run" or fsm.get_previous_state() == "dash"){
				sprite_index = player_character.getSprite("rtoi");
				image_index = 0;
			}
			
			//return after jump !TODO: this is a temp landing animation
			if(fsm.get_previous_state() == "jump"){
				sprite_index = player_character.getSprite("rtoi");
				image_index = 0;
			}
			//for move cap stuff
			approach_walksp = .15;
			
		},
		step: function() {
			
			//transition from running to idle animation
			if(sprite_index == player_character.getSprite("rtoi")) and animation_end(){
				sprite_index = player_character.getSprite("idle");
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
			  vsp = vsp_jump;
			  instance_create_layer(x, y, "Instances", obj_dust_jump);
		      fsm.change("jump");
			}
			
			//attack check
			if(attack) fsm.change("attack");
			
			//dash check
			if(dash and can_dash) fsm.change("dash");
			
			//edge case for falling off block
			if(!place_meeting(x, y + 1, obj_wall_parent) and fsm.get_previous_state() == "run"){
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
			
	   }
  })
  
	
	.add("run", {
		enter: function(){
			sprite_index = spr_run;
			image_index = 0;
			coyote_time = 7;
			
			//run to idle
			if(fsm.get_previous_state() == "idle"){
				sprite_index = player_character.getSprite("itor");
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
			approach_walksp = .15;
			
		},
		
		step: function(){
			
			
			
			//transition from idle to run animation
			if(sprite_index ==  player_character.getSprite("itor")) and animation_end(){
				sprite_index = player_character.getSprite("run");
				image_index = 0;
			}
			
			//move
			get_input_and_move();
			determine_facing();
			
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
			if(!place_meeting(x, y + 1, obj_wall_parent)){
				coyote_time--;
				vsp = 0;
				//coyote time
				if(jump and coyote_time >=0){
					vsp = vsp_jump;
					//show_debug_message("YAY")
					fsm.change("jump");
				} else if(coyote_time <= 0) fsm.change("jump");
			}
			
			//switch to attack
			if(attack) fsm.change("attack");
			
			//dash check
			if(dash and can_dash) fsm.change("dash");
			
			if(place_meeting(x,y, obj_cutscene_collision)) fsm.change("dialogue");
			
	  }
})
	
	
	
	.add("jump", {
		
		enter: function(){
			sprite_index = spr_jump_start;
			image_index = 0;
			if(fsm.get_previous_state() == "dash"){
				sprite_index = spr_dash_to_jump;
				image_index = 0;
			}
			can_jump = false;
			audio_play_sound(snd_jump, 0, false, .05);
			input_dir = sign(facing);
		},
		
		step: function(){
			
			//momentum in mid air calc
			if(sign(facing) != input_dir){
				input_dir = sign(facing);
				walksp = 0;
				hsp = 0;
				approach_walksp = 0.04;
			}

			
			//move
			get_input_and_move();
			determine_facing();
			

			//change animations
			if(sprite_index == spr_jump_start and animation_end()){
				sprite_index = player_character.getSprite("jump");
				image_index = 0;
			}
			
			//variable jump
			if(!input_check("jump")) vsp = max(vsp, -2);
			
			//animations
			if (vsp >= 0.5 and vsp <= 1 and sprite_index != spr_dash_to_jump){ //this is because we dont want it to be stuck on index 0 for forever we want it to only activate at the turn  around point
				sprite_index = spr_jump_fall_start;
				image_index = 0;
			}

			
			if(sprite_index == spr_jump_fall_start and animation_end() or sprite_index == spr_dash_to_jump and animation_end()){
				sprite_index = spr_jump_fall;
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
				if(place_meeting(x, y + 1, obj_wall_parent)){
					vsp = vsp_jump;
					sprite_index = spr_jump;
					can_jump = false;
				}
			} else if(place_meeting(x, y + 1, obj_wall_parent)){
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
			if(grapple_target != noone){
				var coll = collision_line(x, y, grapple_target.x, grapple_target.y, obj_wall, false, false)
				show_debug_message(coll)
			}
			
			//grapple check
			if(can_grapple and throw_grapple and coll == -4) fsm.change("grapple initiate");
			
			//wall slide check
			if(place_meeting(x + sign(facing), y, obj_slide_wall) and vsp >= 0){
				fsm.change("wall slide");
			} 
			
			////cutscene 
			//if place_meeting(x, y, obj_cutscene_collision){
			//	hsp = 0;
			//	fsm.change("dialogue");
			//}
	  }
})

	.add("wall slide", {
		
		enter: function(){
			grv = global_grv;
			grv = grv * wall_fric;
			sprite_index = spr_wall_slide;
		},
		
		step: function(){
			if(input_check_pressed("jump")) fsm.change("wall jump");
			if(!place_meeting(x + sign(facing), y, obj_slide_wall)){
				determine_facing();
				grv = global_grv;
				fsm.change("jump");
			}
		
			get_input_and_move();
		}
})

	.add("wall jump", {
		
		enter: function(){
			sprite_index = spr_jump;
			image_index = 0;
			wall_jump_frames = 8;
			grv = global_grv;
			wall_jump_hsp = wall_jump_hsp_max * - facing
			//wall_jump_hsp_max *= -facing
		},
		
		step: function(){
			wall_jump_frames --
			//wall_jump_hsp = lerp(wall_jump_hsp, wall_jump_hsp_max, .3);
			show_debug_message(wall_jump_hsp)
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
			sprite_index =  player_character.getSprite("dash");
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
        var katana_speed = grapple_speed * 1.5;
        var katana_move_speed_x = dx / dist * katana_speed;
        var katana_move_speed_y = dy / dist * katana_speed;

        // Create and launch the katana object toward the grapple point
        var katana = instance_create_layer(x, y - sprite_height / 2, "Instances", obj_katana);
        katana.hspeed = katana_move_speed_x;
        katana.vspeed = katana_move_speed_y;
        katana.image_angle = point_direction(x, y, grapple_target.x, grapple_target.y);

        // Store the grapple movement speed for later use
        //grapple_move_speed_x = dx / dist * grapple_speed;
        //grapple_move_speed_y = dy / dist * grapple_speed;

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
			},
		
			step: function(){
					// Move the player along the line towards the grapple point
			        tween = TweenEasyMove(x, y, grapple_target.x, grapple_target.y + 30, 0, 30, EaseOutElastic);
					
			         //Check if the player has reached the grapple point
			        var dist_to_target = point_distance(x, y - sprite_height / 2, grapple_target.x, grapple_target.y);
        
			        if (dist_to_target <= grapple_speed) {
			            // Snap to the exact grapple point
			            x = grapple_target.x;
			            y = grapple_target.y + sprite_height / 2;
            
			            // Transition to the "grapple complete" state
			            fsm.change("grapple complete");
					}
				
			}
	})
	
	.add("grapple complete", {
		
			enter: function(){
				grapple_cooldown = grapple_cooldown_max;
				audio_stop_sound(snd_grapple_rope);
				audio_play_sound(snd_grapple_rope_complete, 10 , 0);
				instance_destroy(katana);
				//regen a dash
				can_dash = true;
			},
		
			step: function(){
				//better_solution
				if(input_check_pressed("jump")){
						TweenDestroy(tween);
						grapple_target.cooldown = true;
						vsp = vsp_jump;
						fsm.change("jump");
				}
				//grapple_cooldown--;
				//if grapple_cooldown <= 0 {
				//	if(input_check_pressed("jump")){
				//		grapple_target.cooldown = true;
				//		vsp = vsp_jump;
				//		fsm.change("jump");
				//	}
				//}
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
