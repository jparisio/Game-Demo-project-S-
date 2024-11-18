//inheret collisions and grapple stuff
event_inherited();

hp = 12;
//flash for hit effect
flash_alpha = 0;
flash_colour = c_white;

_speed = 1.3;
starting_x = x;
starting_y = y;
//timers
timer_max = 60 * 2;
timer_switch_state = timer_max;
timer_attack_max = 20 * 1;
timer_attack = timer_attack_max;

//dir to move in
move_dir = random_range(-1, 1)	

//raycast
//vision_range = 250;  // How far the vision reaches
vision_angle = 20;   // Field of vision angle (in degrees)
vision_offset_y = -30;  // Offset the triangle from the enemy’s position

//stunned
stunned = false;

_ended = false;

slide = 9;
slide_hsp = 0;
gun = noone;
	
	
// Add to the Create Event
detection_delay = 60; // delay before switching to aggro
timer_detect = detection_delay;
//indicator_shown = false; // to show detection indicator once

// Function to check if player is in range and visible
function detect_player() {
    if (point_distance(x, y, obj_player.x, obj_player.y) <= vision_range) {
        // Line-of-sight check
        if (!collision_line(x, y + vision_offset_y, obj_player.x, obj_player.y - 22, obj_wall_parent, true, true)) {
            return true;
        }
    }
    return false;
}

fsm = new SnowState("idle")

// Add "aggro" state
fsm.add("aggro", {
    enter: function() {
        sprite_index = spr_assassin_shoot;
		gun = instance_create_layer(x, y - 20, "Instances", obj_assassin_gun);
        image_index = 0;
        timer_attack = timer_attack_max; // Reset attack timer
        //indicator_shown = true; // Show indicator once
    },
    step: function() {
        // Check if enemy is dead
        if (hp <= 0) {
            fsm.change("dead");
            return;
        }
		
		if !detect_player() fsm.change("idle");
        
        // Attack every 2 seconds
        if (timer_attack <= 0 and obj_player. fsm.get_current_state() != "injured") {
            var bullet = instance_create_layer(x, y - 22, "Instances", obj_bullet);
            bullet.direction = point_direction(x, y - 22, obj_player.x, obj_player.y - 22);
            bullet.speed = 7;
			bullet.creator = self;
            timer_attack = timer_attack_max; // Reset attack timer
        } else {
            timer_attack--;
        }

        // Reset horizontal speed and collision
        hsp = lerp(hsp, 0, .15);
        if abs(hsp) <= 0.01 hsp = 0;
        collide_and_move();
    },
	
	leave: function(){
		
		instance_destroy(gun);
	}
	
})

// Modify "idle" state to detect player and switch to "aggro"
fsm.add("idle", {
    enter: function() {
        sprite_index = spr_assassin_idle;
        image_index = 0;
    },
    step: function() {
        if (hp <= 0) {
            fsm.change("dead");
            return;
        }
        
        // If player is detected, start delay before switching to aggro
        if (detect_player()) {
			fsm.change("aggro");
        }

        hsp = lerp(hsp, 0, .15);
        if abs(hsp) <= 0.01 hsp = 0;
        collide_and_move();
    }
})

 
 	.add("shoot", {
		enter: function() {
			hsp = 0;
			sprite_index = spr_boss_gunslinger_aim;
			image_index = 0;

			
			
		},
		step: function() {
			
			//if dead switch to dead state
			if(hp <= 0){
				fsm.change("dead");
			}
			
			if stunned fsm.change("stunned");
			
			if 	sprite_index == spr_boss_gunslinger_aim and animation_end() {
				var bullet = instance_create_layer(x, y - sprite_height/4, "Instances", obj_bullet);
				bullet.direction = point_direction(x, y - sprite_height/4, obj_player.x, obj_player. y - 22);
				bullet.speed = 7;
				sprite_index = spr_boss_gunslinger_fire;
				image_index = 0;
			}
		
			hsp = lerp(hsp, 0, .15);
			if abs(hsp) <= 0.01 hsp = 0;
			collide_and_move();
			facing = sign (obj_player.x - x);
		}
		
 })
 
 
  	.add("stunned", {
		enter: function() {
			//hsp = 0;
			sprite_index = spr_assassin_dead;
			image_index = 0;
			
			//make it so u can grapple to the enemy adn carry momentum through them
			self_grapple = create_grapple_target(self, x, y, 30, 200);
		},
		step: function() {
			
			if(hp <= 0) fsm.change("dead");
			
			//movement
			collide_and_move();
		}
		
 })
 
   .add("dead", {
		enter: function() {
			sprite_index = spr_assassin_dead;
			image_index = 0;
			//spray blood
			if(fsm.get_previous_state() == "stunned") blood_sprayer(self, obj_player.grapple_direction) else  blood_sprayer(self);
			//sound
			audio_play_sound(snd_crunch2, 1, 0, .1, 0, 1.2);
			audio_play_sound(snd_old_dash, 2, 0, 3, 0, 2);
			//shake
			create_shake();
			//hit pause
			hit_pause(20)
			
			slide_hsp = (obj_player.pushback * 3) * sign(obj_player.facing);
			
			//reset the frames to slide for
			slide = 9
			
			remove_grapple_target(self_grapple);
			instance_destroy(self_grapple);
			self_grapple = noone;
			
		},
		step: function() {
			hsp = Approach(hsp, 0, .2);
			if abs(hsp) <= 0.1 hsp = 0;
			if slide >= 0 hsp = slide_hsp
			slide--;
			collide_and_move();
		}
			
  });
  
  