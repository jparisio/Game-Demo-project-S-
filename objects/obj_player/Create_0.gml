//----------------------------------------------------MOVEMENTS----------------------------------------------------------//
hsp = 0;
vsp = 0;
vsp_jump = -5;
global_grv = 0.27;
grv = global_grv;
walksp = 0;
max_walksp = 4;
approach_walksp_max = 0.6;
approach_walksp = approach_walksp_max;
coyote_time_max = 4;
coyote_time = coyote_time_max;
can_jump = true;
jump_buffer_max = 5;
jump_buffer = jump_buffer_max;
peak_grv = global_grv / 2;
stored_velocity = 0;
stored_velocity_timer = 6;
input_dir = 0;
decelerate_ground = 0.4;
decelerate_air = 0.1;
decelerate = decelerate_ground
carried_momentum = 0;
max_carried_momentum = 4;
facing = 1;
//-------------------------------------------------------GRAPPLES-------------------------------------------------------//
can_grapple = false;
grapple_target = noone
grapple_target_list = ds_list_create();
grapple_speed = 7;
grapple_direction = 0;
katana = noone;
grapple_frames = 9;
grapple_target_dist = 0;
grapple_cooldown = 0;
grapple_cooldown_max = 30;
grapple_coll_line = 0;
grapple_momentum_modifier = 0;
tween = 0;
chainsaw_fly = false;
//----------------------------------------------------------GUN------------------------------------------------------//
default_bullet = new Bullet(15, obj_bullet);
gun = new Gun(default_bullet, 5);
shoot_direction = 0;

//--------------------------------------------------------SPRITES-----------------------------------------------------//

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
    run: spr_ghost_run,
	run_to_idle: spr_ghost_run_to_idle,
	idle_to_run: spr_ghost_idle_to_run,
    jump: spr_ghost_jump,
	jump_start: spr_ghost_jump,
	jump_fall_start: spr_ghost_jump,
	jump_fall: spr_ghost_jump,
	dash: spr_ghost_jump,
	wall_slide: spr_ghost_wall_slide
};

// character instance with sprites
player_character = character(sprites_scar, sprites_ghost);

//cutscenes
cutscene_instance = noone;

//squash and stretch
xscale = 1;
yscale = 1;

//--------------------------------------------------------dash-------------------------------------------------//
can_dash = false;
dash_timer_max = 5;
dash_timer = dash_timer_max;
dash_length_max = 15;
dash_length = dash_length_max;
dash_direction = 0;
dash_x = 0;
dash_y = 0;

//---------------------------------------------------WALL JUMP STUFF-------------------------------------------//
wall_fric = 0.25;
wall_jump_frames_max = 9;
wall_jump_frames = wall_jump_frames_max ;
wall_jump_hsp = 0;
wall_jump_hsp_max = 4;
wall_slide_side = 0;

//-------------------------------------------------health and damage------------------------------------------//
hp = 50;
damage = 5;
invulnerability_max = 60 * 2;
invulnerability = invulnerability_max;
be_invulnerable = false;
pushback = 2;
frame_counter = 0;
flash_alpha = 0;

//dialogue
dialogue_buffer = 10
talking = false

//sound
sound_frame_counter = 0;
walking_on = snd_walk2;

//--------------------------------------------lighting-----------------------------------------------------------//

material = new Crystal_Material(id);
material.normalSprite = spr_ghost_idle_normal;
material.depth = depth - 1;
material.Apply();

//--------------------------------------------create the player ui--------------------------------------------//
instance_create_layer(x, y, "Cursor", obj_cursor_controller);
instance_create_layer(x, y, "UI", obj_player_gui);

//--------------------------------------------MOVE FUNCS-----------------------------------------------------------//
get_input_and_move = function() {
	
	//input verbs
	left = input_check("left");
    right = input_check("right");
	up = input_check("up");
	down = input_check("down");
	if (can_jump) jump = input_check("jump") else jump = 0;
	attack = input_check_pressed("attack");
	shoot = input_check_pressed("shoot");
	dash = input_check_pressed("special");
	throw_grapple = input_check_pressed("aim");
	
	//calc
	var move = right - left;
	var target_speed = move * (max_walksp + carried_momentum);  // Target speed is either max_walksp or -max_walksp based on direction

	// Lerp hsp towards the target speed (transitioning smoothly)
	if (left xor right) hsp = Approach(hsp, target_speed, approach_walksp);  

	// Decelerate smoothly when no input is pressed
	if (move == 0) {
	    hsp = Approach(hsp, 0, decelerate);
	}
	
	// Gradually reduce carried momentum
	carried_momentum = Approach(carried_momentum, 0, decelerate);

	// If the speed is very small, stop completely
	if(abs(hsp) <= .1) hsp = 0;

	// Cap hsp to max_walksp and carried momentum
	hsp = clamp(hsp, -(max_walksp + carried_momentum), max_walksp + carried_momentum);
	
	//add gravity
	vsp+=grv;
	
	vsp = clamp(vsp, -9, 9);
	
	//----collisions----//
	collide_and_move();
	
}

collide_and_move = function(){
	
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
	if bbox_bottom < _one_way.bbox_bottom && vsp > 0
		{
		//stop moving or snap player to other.bbox_top eg.
		  y = _one_way.bbox_top - (bbox_bottom - y)
		  vsp = 0;
		}
		
	}
	
	y += vsp;

}

determine_facing = function(){
	
	if(hsp != 0){
		facing = sign(hsp)
	}
}
	
	
	
	
	
//-----------------------------------------------states-------------------------------------------------------------//
fsm = new SnowState("idle")

fsm
	.add("idle", {
		enter: function() {
			//normal return to idle
			sprite_index = player_character.setSprite("idle");
			image_index = 0;
			
			//return after run or dash
			var prev_state = fsm.get_previous_state();
			if (prev_state == "run" || prev_state == "dash" || prev_state == "grapple enemy" || prev_state == "jump") {
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

			//check if player has let go of jump
			if(input_check_released("jump") or !input_check("jump")) can_jump = true;
					
	   }
  })
  	
	.add("run", {
		enter: function(){
			sprite_index = player_character.setSprite("run");
			image_index = 0;
			coyote_time = coyote_time_max;
			
			//run to idle
			if(fsm.get_previous_state() == "idle"){
				sprite_index = player_character.setSprite("itor");
				image_index = 0;
			}
			
			//pick up from dash frame in the run cycle
			if(fsm.get_previous_state() == "dash"){
				image_index = 5;
			}
			
			var dust_dir = 1
			if right dust_dir = 1 else dust_dir = -1
			instance_create_layer(x, y, "Instances", obj_dust_run).image_xscale = dust_dir;
			
			//play sound for initial step
			if!(audio_is_playing(walking_on)) audio_play_sound(walking_on, 0, false, 0.2);
			
			//reset the accel to normal ground accel
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
			
			//if turn around reset sprite ro itor
			if(sign(facing) != input_dir){
				input_dir = sign(facing);
				sprite_index = player_character.setSprite("itor");
				image_index = 0;
			}
			
			//every 4 frames play sound sndwalk or snd_walk2 randomized
			sound_frame_counter++;

			// Check if 4 frames have passed
			if (sound_frame_counter >= 18) {
			    // Reset the counter
			    sound_frame_counter = 0;
				//play audio
			    var volume = .6
			    audio_play_sound(walking_on, 0, false, volume);
			}
				
			//check if player has let go of jump
			if(input_check_released("jump") or !input_check("jump")) can_jump = true;
			
	  }
})
	
	.add("jump", {
		
		enter: function(){
			sprite_index =  player_character.setSprite("jstart");
			image_index = 0;
			if(fsm.get_previous_state() == "dash"){
				//TODO reset this
				//sprite_index = spr_dash_to_jump;
				sprite_index = player_character.setSprite("jfalls");
				image_index = 0;
			}
			//rest jump flag
			can_jump = false;
			
			//make air accel slower
			approach_walksp = 0.15;
			//if abs(hsp) > 1 approach_walksp = 0.25 else approach_walksp = 0.12;
			
			//dont play this if last state was a wall jump
			if(fsm.get_previous_state() != "wall jump") audio_play_sound(snd_jump, 0, false, .05);
			
			//carry momentum from the wall jump or grapple
			var _prev_state = fsm.get_previous_state()
			if (_prev_state == "wall jump" || _prev_state == "grapple enemy"){
				walksp  = max_walksp;
				carried_momentum = abs(hsp) - max_walksp
			}
			
		},
		
		step: function(){
			
			//move
			get_input_and_move();
			determine_facing();
			
			//increase app_walksp when moving against momemtum to have extra control
			if ((hsp >= 0 and right - left == -1) || (hsp <= 0 and right - left == 1)){
				approach_walksp = 0.2;
			} else {
				approach_walksp = 0.15;
			}
			
			
			
			//create trail effect
			part_system_depth(global.part_sys, depth + 1);
			part_type_scale(global.player_trail, facing, 1);
			part_type_sprite(global.player_trail, sprite_index, false, false, false);
			part_type_subimage(global.player_trail, image_index);
			part_particles_create(global.part_sys, x, y, global.player_trail, 1);
			

			//change animations
			//show_debug_message( player_character.getSpriteState());
			if(player_character.getSpriteState() == "jstart" and animation_end()){
				sprite_index =  player_character.setSprite("jump");
				image_index = 0;
			}
			
			//variable jump but dont cap after a grapple slash 
			//show_debug_message(fsm.get_previous_state())
			var prev = fsm.get_previous_state();
			if(!input_check("jump") and  prev != "grapple enemy" and prev != "shoot") vsp = max(vsp, -2);
			
			//half grav at peak of jump 
			if(vsp >= -0.4 and vsp <= 0.4){
				grv = peak_grv;
			} else {
				grv = global_grv;
			}
		
			
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
			if(place_meeting(x, y - 1, obj_wall_parent)) vsp = 0.5;
			
			//if let go of jump, can press it again
			if(input_check_released("jump")) can_jump = true;
			
			//jump buffer
			if(jump) jump_buffer = jump_buffer_max;
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
	  }
})

	.add("wall slide", {
		
		enter: function(){
			grv = global_grv;
			grv = grv * wall_fric;
			sprite_index = player_character.setSprite("wslide");
			//approach_walksp = 0.04;
			audio_play_sound(snd_wall_slide, 0, 1);
			//store the side of wall sliding on 
			wall_slide_side = facing;
		},
		
		step: function(){
			//create dust
			var _x = x + 12 * facing
			var _max = y - sprite_height / 2
			var _min = y;
			var _y = random_range(_min, _max);
			instance_create_layer(_x, _y, "Instances", obj_slide_dust);
			//cap the vsp on the wall
			vsp = min(vsp, 3.8);
			get_input_and_move();
			determine_facing();
		}, 
		
		leave: function() {
			audio_stop_sound(snd_wall_slide);
		}
})

	.add("wall jump", {
		
		enter: function(){
			audio_play_sound(snd_wall_jump, 0, 0);
			sprite_index = player_character.setSprite("jump");;
			image_index = 0;
			wall_jump_frames = wall_jump_frames_max;
			grv = global_grv;
			wall_jump_hsp = wall_jump_hsp_max * -wall_slide_side;
			facing = sign(wall_jump_hsp);
		},
		
		step: function(){
			wall_jump_frames --;
			hsp = wall_jump_hsp;
			vsp = -3;
			collide_and_move();
			determine_facing();
			part_system_depth(global.part_sys, depth + 1);
			part_type_scale(global.player_trail, facing, 1);
			part_type_sprite(global.player_trail, sprite_index, false, false, false);
			part_type_subimage(global.player_trail, image_index);
			part_particles_create(global.part_sys, x, y, global.player_trail, 1);
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
				if on_ground(self){
					fsm.change("idle")
				} else fsm.change("jump")
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
			create_shake("small");
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
				collide_and_move();
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
			
			sprite_index = player_character.setSprite("idle");
			
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
			carried_momentum = 0;
			//play throw sound
			audio_play_sound(snd_grapple_throw, 10, 0);
			//reset grapple flag
			can_grapple = false;
	        // Set the player's sprite to a jumping or grappling sprite
	        sprite_index =  player_character.setSprite("jump");
			image_index = 0;
			facing = sign(grapple_target.x - x) == 0? 1 : sign(grapple_target.x - x);
			
			//sprite arm TODO: get an anim for this
			//var _arm = instance_create_layer(x -3 * facing, y - 28, "Instances", obj_grapple_arm)
			//_arm.image_xscale = facing;
			//_arm.direction = point_direction(_arm.x, _arm.y, grapple_target.x, grapple_target.y);
			//ensure enemy cant move when being grappled to
			if (grapple_target.grapple_type == "grapple enemy"){
				grapple_target.follow.hsp = 0;
				grapple_target.follow.vsp = 0;
				grapple_target.follow.grv = 0;
			}

	        // Calculate the katana's speed (triple the grapple speed)
	        var katana_speed = grapple_speed * 3;

	        // Create and launch the katana/grapple at the hand object toward the grapple point
	        var katana = instance_create_layer(x, y - sprite_height / 2, "Instances", obj_katana);
			var _dir = point_direction(katana.x, katana.y, grapple_target.x, grapple_target.y);
			katana.direction = _dir;
	        katana.image_angle = direction;
			katana.speed = katana_speed;
			
	        // Store the katana reference to check its position later
	        self.katana = katana;
	    },

	    step: function() {

	        // Check if the katana has reached the grapple point
	        if (point_distance(katana.x, katana.y, grapple_target.x, grapple_target.y) < katana.speed) {
			    katana.x = grapple_target.x;
			    katana.y = grapple_target.y;
			    katana.speed = 0;
			    fsm.change("grapple move");
			}

	    }
	})
	
	.add("grapple move", {
		
			enter: function(){
				audio_play_sound(snd_grapple_rope, 10, 0);
				//add speed depending on distance travelled
				grapple_momentum_modifier = point_distance(x, y - sprite_height / 2, grapple_target.x, grapple_target.y) / grapple_target.radius 
				//set these for if player moves through the grapple target
			},
		
			step: function(){
				determine_facing();
				// Move the player along the line towards the grapple point	     
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
				    // Check if the player is inside a wall after grappling
					if (place_meeting(x, y, obj_wall_parent)) {
					    var directions = [
					        [0, -1],    // up
					        [0, 1],     // down
					        [-1, 0],    // left
					        [1, 0]      // right
					    ];

					    // Move player out of the wall step by step
					    for (var i = 0; i < 4; i++) {
					        var dir_x = directions[i][0];
					        var dir_y = directions[i][1];
        
					        while (place_meeting(x + dir_x, y + dir_y, obj_wall_parent)) {
					            x += dir_x;
					            y += dir_y;
					        }
					    }
					}

			        // Transition to the next grapple state (finishing part)
					fsm.change(grapple_target.grapple_type);
					
				}
				
			},
		
		leave: function(){
			audio_stop_sound(snd_grapple_rope);
		}
	})
	
	.add("grapple hang", {
		
			enter: function(){
				grapple_target.active = true;
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
				//stick to grapple
				x = grapple_target.x;
				y = grapple_target.y + sprite_height / 2;
			}
	})
	
	.add("grapple enemy", {
			enter: function() {
				sprite_index = spr_ghost_grapple_slash;
				image_index = 0;
				grapple_cooldown = grapple_cooldown_max;
				audio_stop_sound(snd_grapple_rope);
				audio_play_sound(snd_injured, 13, 0, 1, 0.1, 1);
				audio_play_sound(snd_unsheath, 12, 0, 1, 0.1, 1);
				//audio_play_sound(snd_old_dash, 10, 0, 3, 0, 2);
				instance_destroy(katana);
				//set enemy id attached to the grapple to dead state by making hp = 0
				grapple_target.follow.hp = 0;
				create_shake();
			
				
				//gain a dash
				can_dash = true;
				
				//reset throw grapple / clear it from being pressed
				throw_grapple = 0;
				
				
				// Keep enhanced momentum for a few frames
				grapple_frames = 9;
				hsp *= 5 * grapple_momentum_modifier;
				vsp *= 5 * grapple_momentum_modifier;
				
				//hsp = max(abs(hsp), 3) * sign(hsp)
				//vsp = max(abs(vsp), 3) * sign(vsp)
				
				//clamp jump to max jump so you cant go flying
				vsp = clamp(vsp, -5, 5);
				hsp = clamp(hsp, -(max_walksp + max_carried_momentum), (max_walksp + max_carried_momentum));
				
				//add momentum to enemy
				grapple_target.follow.hsp = hsp / 2;
				grapple_target.follow.vsp = vsp;
		
				//----create the slash---//
				// Handle flipping
				var y_dir = 0;
				if((grapple_direction > 90) and (grapple_direction < 270)){
					y_dir = -1;
				} else {
					y_dir = 1;
				}
				//create the actual slash
				instance_create_layer(x, y - sprite_height / 2, "Instances", obj_grapple_slash, {image_angle: grapple_direction}).image_yscale = y_dir;
				//create the hit effect
				//instance_create_layer(grapple_target.x, grapple_target.y, "Walls", obj_impact_frame, {image_angle: grapple_direction});
				
				
				//clean up left over grapple
				remove_grapple_target(grapple_target);
				instance_destroy(grapple_target);
				//grapple_target = noone;
				//can_grapple = false;
				
			},
	
			step: function() {
				// Continue momentum from the last direction
				grapple_frames--;
					
				// Move player
				collide_and_move();
		
				// End state after 4 frames
				if (grapple_frames <= 0) {
					//carried_momentum = abs(hsp) - max_walksp
					if on_ground(self) fsm.change("idle") else fsm.change("jump");
				}
			}
		})
			
	.add("shoot", {
		
			enter: function(){
					//TODO work on the muzzle flash 
					shoot_direction = point_direction(x, y - sprite_height / 2,  mouse_x, mouse_y)
					//var _x = lengthdir_x(12, _dir);
					//var _y = lengthdir_y(12, _dir);
					//var _muzzle = instance_create_layer(x + _x, y - sprite_height / 2 + _y, "Instances", obj_muzzle_flash, {image_angle: _dir});
					//_muzzle.offset_x = _x;
					//_muzzle.offset_y = _y;
					gun.fire(x, y - sprite_height / 2, shoot_direction);
					sprite_index = spr_ghost_grapple;
					image_index = 0;
			},
		
			step: function(){
				get_input_and_move();
				facing = (shoot_direction >= -90 && shoot_direction <= 90) ? 1 : -1;
			},
			
			leave: function(){

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
	
	.add("injured", {
	    enter: function() {
	        // Logic for hit state
	        //sprite_index = spr_player_hit;
	        //invincible = true;  // Make the player invincible for a short time
	        //input_enabled = false;  // Disable input
			create_shake();
			audio_play_sound(snd_player_hit, 30, 0, 1);
			//destroy grapple rope
			if instance_exists(katana) instance_destroy(katana);
	    },
	    step: function() {
	        //make it an anim or something or wait a few frames
	        
	    }
	})
	
	.add("paused", {
		
			enter: function(){


			},
		
			step: function(){

			}
	})

	.add("dead", {
		
			enter: function(){
					//entire is a placeholder state for now
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


	//--------------------------------------TRANSITIONS---------------------------------------------------------//
	
	//cutscenes
	fsm.add_transition("to_dialogue", "idle", "dialogue", function()  {
		return 	place_meeting(x, y, obj_dialogue_collision) and input_check_pressed("action")
	})
	
	fsm.add_transition("to_cut_dialogue", ["idle", "run"], "dialogue", function()  {
		return 	place_meeting(x,y, obj_cutscene_collision)
	})
	
	fsm.add_transition("to_cutscene", ["idle", "run", "jump"], "cutscene", function() {
			if (cutscene_instance != noone){
				cutscene_instance.start = true;
				return true;
			}
	    return false;
	})
	
	//movement 
	fsm.add_transition("to_run", "idle", "run", function()  {
		return right xor left
	})
	
	
	fsm.add_transition("to_idle", "run", "idle", function()  {
		return 	((!right and !left) or (right and left))
	})
	
	fsm.add_transition("t_coyote_jump", ["run"], "jump", function() {
	    if (!on_ground(self)) {
	        coyote_time--; 
	        if (jump && coyote_time >= 0) {
				instance_create_layer(x, y, "Instances", obj_dust_jump); 
	            vsp = vsp_jump; 
	            return true;
	        }
	        if (coyote_time < 0) {
	            return true; 
	        }
	    }
	    return false;
	});

	
	fsm.add_transition("to_jump", ["idle", "run"], "jump", function() {
	    if (jump) {
	        xscale = 0.75;    
	        yscale = 1.25;  
	        vsp = vsp_jump;   
	        instance_create_layer(x, y, "Instances", obj_dust_jump); 
	        return true; 
	    }
	    return false;
	})
	
	fsm.add_transition("to_wall_slide", ["jump", "wall jump"], "wall slide", function() {
	    return (place_meeting(x + sign(facing), y, obj_slide_wall) and vsp >= 0)
	})
	
	
	fsm.add_transition("fall_off", ["idle"], "jump", function() {
	    if(!on_ground(self)){
			return true;
		}
	    return false;
	})
	

	fsm.add_transition("to_attack", ["idle", "run", "jump"], "attack", function()  {
		return attack;
	})
	
	fsm.add_transition("to_shoot", ["idle", "run", "jump"], "shoot", function()  {
		if(shoot){
			if (array_length(gun.get_bullets()) > gun.get_index()){
				return true;
			} else {
				//play gun empty sound and dont state change
				var _snd = choose(snd_empty_gun3);
				var _pitch = random_range(1, 1.1);
				audio_play_sound(_snd, 10, 0, , , _pitch);
				return false;
			}
		}
		return false;
	})
	
	fsm.add_transition("shoot_to_idle", "shoot", "idle", function() {
	    return on_ground(self); 
	});

	fsm.add_transition("shoot_to_jump", "shoot", "jump", function() {
	    return !on_ground(self);
	});


	fsm.add_transition("to_dash", ["idle", "run"], "dash", function()  {
		return dash and can_dash
	})
	
	fsm.add_transition("to_grapple", ["idle", "run", "jump"], "grapple initiate", function()  {
		return can_grapple and throw_grapple and !grapple_coll_line
	})
	
	fsm.add_transition("grap_to_jump", "grapple hang", "jump", function()  {
		if(input_check_pressed("jump")){
					grapple_target.cooldown = true;
					vsp = vsp_jump;
					return true;
		}
		return false;
	})
	
	fsm.add_transition("wall_slide_to_wall_jump", "wall slide", "wall jump", function() {
		return input_check_pressed("jump");
	});

	fsm.add_transition("wall_slide_to_jump", "wall slide", "jump", function() {
	    return !place_meeting(x + sign(facing), y, obj_slide_wall);
	});

	fsm.add_transition("wall_slide_to_idle", "wall slide", "idle", function() {
	    if(on_ground(self)){
				facing *= -1;
				//move me 1 pixel forward so i can turn back into wall (edge case)
				x += facing;
				grv = global_grv;
				audio_stop_sound(snd_wall_slide);
				return true
		}
		return false;
	});
	
	fsm.add_transition("wall_jump_to_jump", "wall jump", "jump", function() {
	    return wall_jump_frames <= 0
	});
	
	
	//fsm.add_transition("grap_enemy_to_wall_slide", "grapple enemy", "wall slide", function() {
	//    return place_meeting(x + sign(facing), y, obj_slide_wall)
	//});



	

	
	
	
	
	
	

	
	
