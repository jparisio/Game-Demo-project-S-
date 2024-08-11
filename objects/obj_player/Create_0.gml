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
wall_fric = 0.17;
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

//dialogue
dialogue_buffer = 10
talking = false


//6B9199
//this is code for bg colour

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
	if place_meeting(x+hsp,y,obj_wall) {
	    while !place_meeting(x+sign(hsp),y,obj_wall) {
	        x += sign(hsp);
	    }
	    hsp = 0;
	}
	x += hsp;

	//vert
	if place_meeting(x,y + vsp,obj_wall) {
	    while !place_meeting(x,y+sign(vsp),obj_wall) {
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
	if place_meeting(x+hsp,y,obj_wall) {
	    while !place_meeting(x+sign(hsp),y,obj_wall) {
	        x += sign(hsp);
	    }
	    hsp = 0;
	}
	x += hsp;

	//vert
	if place_meeting(x,y + vsp,obj_wall) {
	    while !place_meeting(x,y+sign(vsp),obj_wall) {
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
			sprite_index = spr_idle;
			image_index = 0;
			
			//return after run
			if(fsm.get_previous_state() == "run"){
				sprite_index = spr_run_to_idle
				image_index = 0;
			}
			
		},
		step: function() {
			
			//transition from running to idle animation
			if(sprite_index == spr_run_to_idle) and animation_end(){
				sprite_index = spr_idle;
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
			if(!place_meeting(x, y + 1, obj_wall) and fsm.get_previous_state() == "run"){
				fsm.change("jump");
			}
			
			//switch to finisher
			var _circle = instance_place(x, y, obj_finisher_circle);
			if (input_check_pressed("cancel") and _circle){
				fsm.change("finisher");
				instance_destroy(obj_finisher_circle);
			}
	   }
  })
  
	
	.add("run", {
		enter: function(){
			sprite_index = spr_run;
			image_index = 0;
			coyote_time = 7;
			
			//run to idle
			if(fsm.get_previous_state() == "idle"){
				sprite_index = spr_idle_to_run;
				image_index = 0;
			}
			
			var dust_dir = 1
			if right dust_dir = 1 else dust_dir = -1
			instance_create_layer(x, y, "Instances", obj_dust_run).image_xscale = dust_dir;
			
		},
		
		step: function(){
			
			//transition from idle to run animation
			if(sprite_index == spr_idle_to_run) and animation_end(){
				sprite_index = spr_run;
				image_index = 0;
			}
			
			//move
			get_input_and_move();
			determine_facing();
			
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
			if(!place_meeting(x, y + 1, obj_wall)){
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
			
	  }
})
	
	
	
	.add("jump", {
		
		enter: function(){
			sprite_index = spr_jump_start;
			image_index = 0;
			can_jump = false;
		},
		
		step: function(){
			//move
			get_input_and_move();
			determine_facing();
			
			//change animations
			if(sprite_index == spr_jump_start and animation_end()){
				sprite_index = spr_jump;
				image_index = 0;
			}
			
			//variable jump
			if(!input_check("jump")) vsp = max(vsp, -2);
			
			//animations
			if (vsp >= 0.5 and vsp <= 1){ //this is because we dont want it to be stuck on index 0 for forever we want it to only activate at the turn  around point
				sprite_index = spr_jump_fall_start;
				image_index = 0;
			}
			if(sprite_index == spr_jump_fall_start and animation_end()){
				sprite_index = spr_jump_fall;
				image_index = 0;
			}
			
			//check if colliding with bottom of wall
			if(place_meeting(x, y - 1, obj_wall)) vsp = 1;
			
			//if let go of jump, can press it again
			if(input_check_released("jump")) can_jump = true;
			
			//jump buffer
			if(input_check("jump") and can_jump) jump_buffer = jump_buffer_max;
			if(jump_buffer >= 0){
				jump_buffer--;
				if(place_meeting(x, y + 1, obj_wall)){
					vsp = vsp_jump;
					sprite_index = spr_jump;
					can_jump = false;
				}
			} else if(place_meeting(x, y + 1, obj_wall)){
				xscale = 1.25;
				yscale = 0.75;
				can_jump = false
				fsm.change("idle");
			}
			
			//attack switch
			if(attack) fsm.change("attack");
			
			//dash check
			if(dash and can_dash) fsm.change("dash");
	  }
})

	.add("attack", {
		
		enter: function(){
			sprite_index = spr_attack;
			image_index = 0;
			//create the hitbox
			//create_hitbox("player", x, y, facing, spr_hitbox, 1, damage);
			//instance_create_layer(x, y, "Instances", obj_slash).image_xscale = facing;
		},
		
		step: function(){
			//move
			get_input_and_move();
			//determine_facing();
			
			//hit enemy details
			if(animation_hit_frame(1)){
				create_hitbox("player", x, y, facing, spr_hitbox, 1, damage);
			}
				
		
			//switch back to idle on ground or air in air
			if(animation_end()){
				if place_meeting(x, y + 1, obj_wall){
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
			sprite_index = spr_dash;
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
			//determine dash dir (the .4 is a magic number that decreases the angle you dash at so it isnt so sharp)
			if (right - left != 0){
				dash_direction = point_direction(0, 0, right - left + .4 * facing, down - up)
			} else if(right - left == 0 and down - up != 0){
				dash_direction = point_direction(0, 0, 0, down - up)
			} else dash_direction = point_direction(0, 0, facing, down - up);
			//create screenshake
			instance_create_layer(x, y, "Instances", obj_screenshake);
			instance_destroy(obj_hurtbox)
		},
		
		step: function(){
			
			if(dash_length >= 0){
				dash_length--;
			
				//speed up the dash at end
				dash_x = lerp(dash_x, 7, .5);
				dash_y = lerp(dash_y, 7, .5);
				//move
				hsp = lengthdir_x(dash_x, dash_direction);
				vsp = lengthdir_y(dash_y, dash_direction);
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
						image_blend = #6495ED;
						image_alpha = 1;
					}
					dash_timer = dash_timer_max;
				}
			} else {
				//switch to air if in air otherwise ground idle
				image_speed = 1;
				grv = global_grv;
				can_dash = false;
				instance_create_layer(x, y, "Instances", obj_hurtbox);
				if(place_meeting(x, y + 1, obj_wall)) fsm.change("idle") else fsm.change("jump");
			}
		}
})


	.add("dialogue", {
		
		enter: function(){
			//sprite_index = spr_idle;
			talking = true;
			dialogue_buffer = 10;
		},
		
		step: function(){
			
			//stop animation from looping
			if (sprite_index == spr_run_to_idle and animation_end()) sprite_index = spr_idle;
			
			var _dialogue_box = instance_place(x, y, obj_dialogue_collision);
			
			if(_dialogue_box != noone){
				with(_dialogue_box){
					//show_debug_message(_self)
					if(!instance_exists(obj_text) and timer <= 0 and obj_player.talking == true){
						with(instance_create_layer(obj_player.x, obj_player.y, "Instances", obj_text)){
							//create script with the id retrieved from this
							current_dialogue_id = other.text_id;
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
});
