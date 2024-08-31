hp = 12;
//flash for hit effect
flash_alpha = 0;
flash_colour = c_white;
//hori and verti move
hsp = 0;
vsp = 0;
grv = .28;
facing = 0
starting_x = x;
starting_y = y;
//timers
timer_max = 60 * 2;
timer_switch_state = timer_max;
timer_attack_max = 60 * 1;
timer_attack = timer_attack_max;
//dir to move in
move_dir = random_range(-1, 1)	

//finisher stuff
headless = false
headless_timer_max = 80;
headless_timer = headless_timer_max;
stunned_timer_max = 300;
stunned_timer = stunned_timer_max;

_ended = false;

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

//determine facing script
determine_facing = function(){
	
	if(hsp != 0){
		facing = sign(hsp)
		image_xscale = facing;
	}
}

	
	
	
//states	
fsm = new SnowState("idle")

fsm
	.add("idle", {
		enter: function() {
			sprite_index = spr_warrior_slime_idle1;
			image_index = 0;
			timer_switch_state = timer_max;
			determine_facing();
		},
		step: function() {
			//if dead switch to dead state
			if hp < 0 fsm.change("dead");
			//to slow down after the run
			collide_and_move();
			//switch to attack if in range and on same level veritcally
			if (abs(obj_player.x - x) <= 50 and timer_attack <= 0 and (abs(obj_player.y - y <= 10))){
				var _attack = random(2)
				if _attack <= 1 fsm.change("attack1") else fsm.change("attack2")
			}
			//facing player always if alerted
			if (abs(obj_player.x - x) <= 100 and (abs(obj_player.y - y <= 10))) image_xscale = sign(obj_player.x - x)
			//switch to run if timer is up
			if timer_switch_state <= 0 fsm.change("walk");
			
			if hp <= 2 fsm.change("stunned");
		}
		
			

  })
  
	.add("walk", {
		enter: function() {
			sprite_index = spr_warrior_slime_walk;
			image_index = 0;
			timer_switch_state = timer_max;
	
		},
		step: function() {
			//if dead switch to dead state
			if hp < 0 fsm.change("dead");
			//if in range of player attack
			if (abs(obj_player.x - x) <= 80 and timer_attack <= 0 and (abs(obj_player.y - y <= 10))){
				var _attack = random(2)
				if _attack <= 1 fsm.change("attack1") else fsm.change("attack2")
			}
			//move random direction
			if (move_dir <= 0) hsp = -1.3 else hsp = 1.3;
			
			//if player is near move towards him
			if(abs(obj_player.x - x) <= 100) and (abs(obj_player.y - y <= 10)) hsp = 2 * sign(obj_player.x - x);
			
			//check if gonna fall off a ledge and flip if so
			var _side = bbox_right
			if (hsp >= 0) _side = bbox_right else _side = bbox_left
			if !position_meeting(_side + sign(hsp), bbox_bottom + 1, obj_wall_parent) {
				//hsp = 0
				fsm.change("idle")
				move_dir = - move_dir;
			}
			
			//check if youre at wall
			if place_meeting(x + sign(hsp), y, obj_wall_parent){
				//hsp = 0
				fsm.change("idle")
				move_dir = -move_dir;
			}
			
			//collision and move
			collide_and_move();
			determine_facing();
			//switch back after timer_max seconds
			if timer_switch_state <= 0 fsm.change("idle");
		}
			

  })
  
  
	.add("attack1", {
		enter: function() {
			sprite_index = spr_warrior_slime_attack;
			image_index = 0;
			//switch to face the player
			image_xscale = sign(obj_player.x - x);
		},
		step: function() {
			//if dead switch to dead state
			if hp < 0 fsm.change("dead");
			//stay still
			collide_and_move();
			//create the hitbox on slash frame
			if(animation_hit_frame(5)){
				//create hitbox
				create_hitbox("enemy", self, x, y, image_xscale, spr_warrior_slime_attack1_hitbox, 1, 3)
			}
			
			//switch to idle
			if animation_end(){
				fsm.change("idle");
				//reset the timer
				timer_attack = timer_attack_max
			}
		}
			
  })
  

	.add("attack2", {
		enter: function() {
			sprite_index = spr_warrior_slime_attack2;
			image_index = 0;
			//switch to face the player
			image_xscale = sign(obj_player.x - x);
		},
		step: function() {
			//if dead switch to dead state
			if hp < 0 fsm.change("dead");
			//stay still
			collide_and_move();
			//create the hitbox on slash frame
			if(animation_hit_frame(10)){
				//create hitbox
				create_hitbox("enemy", self, x, y, image_xscale, spr_warrior_slime_attack2_hitbox, 5, 10)
			}
			
			//switch to idle
			if animation_end(){
				fsm.change("idle");
				//reset the timer
				timer_attack = timer_attack_max
			}
		}
			
  })
  
  	.add("stunned", {
		enter: function() {
			sprite_index = spr_warrior_slime_idle1;
			image_index = 0;
			with(instance_create_layer(x, y, "Instances", obj_finisher_circle)){
				image_xscale = -other.image_xscale;
				creator = other.id;
			}
			stunned_timer = stunned_timer_max;
		},
		step: function() {
			
			collide_and_move();
			
			//switch to idle if not killed in time
			stunned_timer--;
			if stunned_timer <= 0 and image_speed > 0{
				instance_destroy(obj_finisher_circle);
				fsm.change("idle");
				hp += 5
			}
			
			if image_speed = 0{
				headless = true;
			}
			
			if headless {
				headless_timer--;
			}
			var _self = -self.image_xscale
			if headless_timer <= 0 {
				with (instance_create_layer(x, y - 30,"Instances", obj_warrior_slime_head)){
					direction = 90 - _self * random_range(30, 60);
					speed = random_range(4, 7)
				}
				instance_create_layer(x, y, "Instances", obj_blood_spray).image_xscale = -image_xscale;
				//shake large
				create_shake();
				//cause hit flash
				flash_alpha = 0.8;
				//create the slashed effect
				var _slash = instance_create_layer(x, y, "Instances", obj_hit_effect);
				_slash.image_xscale = obj_player.image_xscale;
				_slash.image_angle = random_range(20, -20);
				//create blood and blood angle
				var _angled = random(2)
				if(_angled <= 1) repeat(30) create_blood(-image_xscale, x -10, y-40, true) else repeat(30) create_blood(-image_xscale, x -10, y-40, false)
				//hit pause
				hit_pause(20)
				
				fsm.change("headless");
			}
			
			if hp <= 0 {
				instance_destroy(obj_finisher_circle);
				fsm.change("dead");
			}
		} 
			
  })
  
  
  	.add("headless", {
		enter: function() {
			sprite_index = spr_warrior_slime_headless;
			image_speed = 0;
			mask_index = spr_warrior_slime_dead_mask
		},
		step: function() {
			//image_alpha -= 0.02;
		}
			
  })
  
  
	.add("dead", {
		enter: function() {
			sprite_index = spr_warrior_slime_death;
			image_index = 0;
			//FIX what deosnt fall and collide if in mid air since it has no collision mask
			mask_index = spr_warrior_slime_dead_mask
			var _sprayer = instance_create_layer(x,y, "Instances", obj_blood_sprayer);
			_sprayer.facing = obj_player.facing;
			_sprayer.create_at = self;
			//sound
			//audio_play_sound(snd_crunch, 1, 0, 1.1, 0 ,0.7);
			var vol = choose(0.1, 0.3)
			audio_play_sound(snd_crunch2, 1, 0, vol, 0, 1.2);
			audio_play_sound(snd_old_dash, 2, 0, 3, 0, 2);
			//shake
			create_shake();
			//hit pause
			hit_pause(20)
			
		},
		step: function() {
			//collide_and_move();
			if animation_end(){
				image_index = image_number - 1;
				//fade one death animation is done
				image_alpha -= 0.05;
			}
			if image_alpha <= 0 instance_destroy();
		}
			
  });