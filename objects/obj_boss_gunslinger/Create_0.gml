//set hp
hp = 300;

//move
hsp = 0;
vsp = 0;
grv = 0.4;
tp_back = false;

//face player upon creation
facing = sign(obj_player.x - x);
spotlight = false;

//timer for switching states
state_timer = 0;
state_timer_max = 120;

//random state 
rand_next_state = 0;

//teleporting
target_x = 0;
dust = noone;

//lasers
laser_timer = 0;
laser_angle_step = 0;

//flash shader
flash_alpha = 0;
flash_colour = c_white;

//shooting
reticle = noone;

//phase 2
phase2 = false

//movement for falling
collide_and_move = function(){

vsp += grv;
//hori
	if place_meeting(x+hsp,y,obj_wall_parent) {
	    while !place_meeting(x+sign(hsp),y,obj_wall_parent) {
	        x += sign(hsp);
	    }
	    hsp = 0;
		//show_debug_message(sprite_get_name(mask_index))
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

//states	
fsm = new SnowState("idle")

fsm
	.add("idle", {
		enter: function() {
			sprite_index = spr_boss_gunslinger_idle;
			image_index = 0;
		},
		step: function() {
			//timer minus and switch state
			if(global.boss_fight and !instance_exists(obj_text)){
				instance_destroy(obj_cone_light);
				audio_play_sound(snd_spotlight, 10, 0, 1, 0, 0.9)
				for(var i = 650; i <= 1050; i++){
					instance_create_layer(i, 280, "Lighting", obj_light)
					i+= 100;
				}
				var floor_light = instance_create_layer(830, 300, "Lighting", obj_light)
				floor_light.sprite = spr_floor_light;
				audio_play_sound(snd_temp_song, 10, 1, 0.5);
				fsm.change("steady");
			}
			//face player
			if(obj_player.talking) {
				obj_player.facing = sign( x - obj_player.x);
				if(!spotlight){
					spotlight = true;
					instance_create_layer(1054, 162, "Lighting", obj_cone_light);
					audio_play_sound(snd_spotlight, 10, 0, 1, 0, 0.9)
				}
			}
			
		}

  })
  
  	.add("steady", {
		enter: function() {
			//set sprite index
			sprite_index = spr_boss_gunslinger_aim;
			image_index = 0;

			state_timer = state_timer_max;
			//rand = irandom_range(0,2);
			//also create the grenadew to throw
			instance_create_layer(x, y - 30, "Instances", obj_grenade);
			
			
			//play this sound at 1:16 https://www.youtube.com/watch?v=FlU4mEjvkz8
			audio_play_sound(snd_reload, 15, 0, 5);
		
			
		},
		step: function() {
			if animation_hit_frame(5){
				//spawn in reticle
				var _x = random_range(-100, 100) + obj_player.x
				var _y = random_range(-100, 100) + obj_player.y
				reticle = instance_create_layer(_x, _y, "Instances", obj_reticle);
			}
			
			
			state_timer--;
			
			if hp <= 100 and !phase2{
				phase2 = true
				state_timer_max/= 2
			}
			
			//if dead dont go to the other states 
			if hp <= 0 fsm.change("dead");
			
			//injured state
			if( hp != 300 and hp mod 50 == 0 and hp > 0){
				fsm.change("injured")
			}
			
			if animation_end() {
				image_index = image_number - 1;
			}
			
			//firing
			if state_timer <=0 {
				reticle.stop = true;
				fsm.change("fire");
			}
			
		}

  })
  
    
	.add("fire", {
		enter: function() {
			//set sprite index
			sprite_index = spr_boss_gunslinger_fire;
			image_index = 0;
			//rand_next_state = choose("lasers", "rockets", "laser circle")
			//play this sound https://artlist.io/sfx/track/black-powder-guns---pistol-the-lone-ranger/62778
			// hit impact for this https://kiddolink.itch.io/vfx-fx-hit-impact-pixel-art
		},
		step: function() {
			
			//if dead dont go to the other states 
			if hp <= 0 fsm.change("dead");
			
			//injured state
			if( hp != 300 and hp mod 50 == 0 and hp > 0){
				fsm.change("injured")
			}
			
			//if the animation ends fire the bullet
			if (animation_end()){
				fsm.change("teleport");
			}
			
		}

  })
  
  .add("teleport", {
		enter: function() {
			//determine where to tp to
			if (x > 800) target_x = 580 else target_x = 1056;
			//create smoke effects;
			dust = instance_create_layer(x, y, "Instances", obj_dust_bomb);
			rand_next_state = choose("lasers", "rockets", "laser circle")
		},
		step: function() {
			image_index = image_number - 1
			//state_timer--;
			//tp to other side
			with(dust){
				if animation_hit_frame(3){
					other. x = -100000;
					other.fsm.change(other.rand_next_state);
				}
			}
			
		}

  })
  
   .add("reappear", {
		enter: function() {
			sprite_index = spr_boss_gunslinger_idle;
			image_index = 0;
			state_timer = state_timer_max/4;
			dust = instance_create_layer(target_x, y, "Instances", obj_dust_bomb);
			//create floor laser
			var floor_laser = instance_create_layer(400, 285, "Instances", obj_laser);
			floor_laser.image_angle = 270;
			floor_laser.image_yscale = 5;
			floor_laser.alarm_active = 20;
		},
		step: function() {
			
			state_timer--;
			
			with(dust){
				if animation_hit_frame(3){
					other.x = other.target_x;
				}
			}
			if state_timer <= 0 fsm.change("steady");
			
		}

  })
  
  
     .add("lasers", {
		enter: function() {
			state_timer = state_timer_max;
			// Starting and ending x-axis positions
			var start_x = 500;
			var end_x = 1200;

			// Spacing between each laser (50 pixels)
			var laser_spacing = 50;

			// Loop to create lasers between the specified x-axis range
			for (var i = start_x; i <= end_x; i += laser_spacing) {
			    var laser_x = i;
			    var laser_y = 288; 
    
			    // Create the laser at the specified position
			    var _laser =  instance_create_layer(laser_x, laser_y, "Instances", obj_laser);
				_laser.image_yscale = 4;
			}
		},
		step: function() {
			state_timer--;
			if(state_timer <= 0) fsm.change("reappear");
		}

  })
  
  	.add("rockets", {
		enter: function() {
			sprite_index = spr_boss_gunslinger_idle;
			image_index = 0;
			var center_x = obj_player.x; // Use the player's x position as the center
			var center_y = obj_player.y; // Use the player's y position as the center
			var max_radius = 300;
			var num_rockets = 10;

			// Step 2: Create the rockets in a loop
			for (var i = 0; i < num_rockets; i++) {
			    // Calculate the angle for this rocket
			    var angle = i * (360 / num_rockets);
    
			    // Convert the angle to radians
			    var radian_angle = degtorad(angle);
    
			    // Calculate the rocket's initial position
			    var x_pos = center_x + lengthdir_x(max_radius, angle);
			    var y_pos = center_y + lengthdir_y(max_radius, angle);
    
			    // Create the rocket instance at the calculated position
			    var _rocket = instance_create_layer(x_pos, y_pos, "Instances", obj_rocket);
    
			    // Step 3: Set the rocket's direction and initial speed
			    _rocket.direction = angle;
			    _rocket.speed = 0; // Initial speed, will be updated later
				_rocket.target_angle = angle;
				_rocket.move_speed = i + 1 * 2;
			}
			//set timer to max
			state_timer = state_timer_max;
			
		},
		step: function() {
				state_timer--;
				if state_timer<=0 fsm.change("reappear")
		}

  })
  
 .add("laser circle", {
    enter: function() {
        var center_x = 820;
        var center_y = 190;
        var _laser = instance_create_layer(center_x, center_y, "Instances", obj_laser);
        _laser.image_angle = 270;
        _laser.image_yscale = 3;
        _laser.alarm_active = 20;

        // Initialize variables for creating lasers
        laser_timer = 0;
        laser_counter = 0; // Counter for how many lasers have been created
        laser_angle_step = 180 / 10; // Number of lasers (adjust accordingly)
        max_lasers = 11; // Total number of lasers to create
		state_timer = state_timer_max / 2;
    },
    step: function() {
        laser_timer++;

        if (laser_timer % 3 == 0 && laser_counter < max_lasers) { // Create a laser every 4 frames
            var angle = 270 - laser_angle_step * laser_counter; // Angle from 270 to 90 degrees

            var new_laser = instance_create_layer(820, 190, "Instances", obj_laser);
            new_laser.image_angle = angle;
            new_laser.image_yscale = 6;
            new_laser.alarm_active = 15;

            laser_counter++; // Increment the counter
        }

        // Stop creating lasers after the maximum number is reached
        if (laser_counter >= max_lasers) {
            laser_timer = -1; // Stop the timer
        }
        
        // Handle transition to the next state
        if (laser_timer == -1) {
            state_timer--;
            if (state_timer <= 0) fsm.change("reappear");
        }
    }
})     


	.add("injured", {
		enter: function() {
			sprite_index = spr_boss_gunslinger_injured_begin;
			image_index = 0;
			if(instance_exists(obj_reticle)) instance_destroy(obj_reticle);
			instance_create_layer(x, y, "Instances", obj_player_damaged);
			var blood_spray = instance_create_layer(x, y, "Instances", obj_blood_sprayer);
			var _facing = sign(obj_player.facing);
			blood_spray.facing = -_facing;
			blood_spray.create_at = self;
			
			audio_play_sound(snd_injured, 13, 0, 20, 0.1, 1);
			audio_play_sound(snd_unsheath, 12, 0, 40, 0.1, 1);
			audio_play_sound(snd_old_dash, 10, 0, 3, 0, 2);
			//shake
			create_shake();
			//hit pause
			hit_pause(80);
			
			
			//begin movement
			//set vals
			hsp = 3 * _facing;
			vsp = -4;
			
			//subtract hp sp your not infintely going back to this
			hp -= 5;
			
			state_timer = state_timer_max/4;
			tp_back = false;
			facing = -sign(hsp)
			
			
		},
		step: function() {
			
			mask_index = spr_boss_gunslinger_idle;

			collide_and_move();

			// Handle animation transitions
			if (sprite_index == spr_boss_gunslinger_injured_begin && animation_end()) {
				show_debug_message("ENDED");
			    sprite_index = spr_boss_gunslinger_injured_loop;
			    image_index = 0;
			}

			// Check for ground collision and switch sprite
			if (place_meeting(x, y + 1, obj_wall) && sprite_index == spr_boss_gunslinger_injured_loop) {
			    sprite_index = spr_boss_gunslinger_injured_ground;
			    image_index = 0;
			}

			// Handle injured ground animation
			if (sprite_index == spr_boss_gunslinger_injured_ground && animation_end()) {
			    image_index = image_number - 1;  // Stop animation at the end
			    tp_back = true;   // Trigger teleport
			}

			// Handle teleport logic
			if (tp_back) {
			    state_timer--;
			    if (state_timer <= 0) {
					fsm.change("teleport");
				}
			}

			// Slow down the horizontal speed
			hsp = lerp(hsp, 0, 0.1);

		}

  })

     .add("dead", {
		enter: function() {
			sprite_index = spr_boss_gunslinger_idle;
			image_index = 0;
			//spawn the cutscene trigger on the player
			var _end = instance_create_layer(obj_player.x, obj_player.y,"Instances", obj_cutscene_collision);
			_end.text_id = "dead";
			_end.create_above = obj_boss_gunslinger;
			_end.image_xscale = 300;
			_end.image_yscale = 300;
			
			//make player face boss
			obj_player.facing = sign(x - obj_player.x);
			
			//stop all audio
			audio_stop_sound(snd_temp_song)
			
		},
		step: function() {
			//destroy reticle
			if(instance_exists(obj_reticle)) instance_destroy(obj_reticle);
			if(instance_exists(obj_shrapnel)) instance_destroy(obj_shrapnel);
			//make player face boss
			obj_player.facing = sign(x - obj_player.x);
		}

  });


  