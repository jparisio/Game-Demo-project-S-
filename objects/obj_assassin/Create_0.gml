hp = 12;
//flash for hit effect
flash_alpha = 0;
flash_colour = c_white;
//hori and verti move
hsp = 0;
vsp = 0;
//grv = .27;
grv = 0
facing = 1;
_speed = 1.3;
starting_x = x;
starting_y = y;
//timers
timer_max = 60 * 2;
timer_switch_state = timer_max;
timer_attack_max = 60 * 1;
timer_attack = timer_attack_max;

//dir to move in
move_dir = random_range(-1, 1)	

//raycast
vision_range = 150;  // How far the vision reaches
vision_angle = 20;   // Field of vision angle (in degrees)
vision_offset_y = -30;  // Offset the triangle from the enemy’s position

//patrol points
patrol_points = [x + 100, x - 100];
target_point = choose(patrol_points[0], patrol_points[1]);

//collision rectangle
rec_min_x = 0;
rec_min_y = 0;
rec_max_x = 0;
rec_max_y = 0;

//stunned
stunned = false;
grappled_to = false;

_ended = false;

slide = 9;
slide_hsp = 0;

//collide_and_move = function(){

//vsp += grv;
////hori
//	if place_meeting(x+hsp,y,obj_wall_parent) {
//	    while !place_meeting(x+sign(hsp),y,obj_wall_parent) {
//	        x += sign(hsp);
//	    }
//	    hsp = 0;
//		//show_debug_message(sprite_get_name(mask_index))
//	}
//	x += hsp;

//	//vert
//	if place_meeting(x,y + vsp,obj_wall_parent) {
//	    while !place_meeting(x,y+sign(vsp),obj_wall_parent) {
//	        y += sign(vsp);
//	    }
//	    vsp = 0;
//	}
//	y += vsp;

//}

////determine facing script
//determine_facing = function(){
	
//	if(hsp != 0){
//		facing = sign(hsp)
//	}
//}

event_inherited();
	
	
//states	
fsm = new SnowState("stunned")

fsm
	.add("patrol", {
		enter: function() {
			sprite_index = spr_assassin_run;
			image_index = 0;
			target_point = choose(patrol_points[0], patrol_points[1]);
			
		},
		step: function() {
			//if dead switch to dead state
			if(hp <= 0){
				fsm.change("dead");
			}
			
			//player is seen
			if(collision_rectangle(rec_min_x, rec_min_y, rec_max_x, rec_max_y, obj_player, false, true)){
				 //show_debug_message("Player is within the triangle's bounding box");
				 fsm.change("shoot");
			}
			
			//move to target point
			 if (abs(x - target_point) < _speed) {
                // Switch patrol points when reaching one
				//target_point = target_point == patrol_points[0]? patrol_points[1]: patrol_points[0];
				fsm.change("patrol rest");
            }
			
			//wall check
			if place_meeting(x + hsp, y, obj_wall_parent){
				target_point = target_point == patrol_points[0]? patrol_points[1]: patrol_points[0];
			}
			
			//fall off ledge check 
			var _side = bbox_right
			if (hsp >= 0) _side = bbox_right else _side = bbox_left
			//if theres a ledge turn around 
			if !position_meeting(_side + sign(hsp), bbox_bottom + 1, obj_wall_parent) {
				target_point = target_point == patrol_points[0]? patrol_points[1]: patrol_points[0];
			}

			//set hsp (approach it for smooth movment)
			//hsp = Approach(hsp, sign(target_point - x) * _speed, .3);
			hsp = sign(target_point - x) * _speed;
		
			//move and collide functions
			collide_and_move();
			determine_facing();
			
			//anims
			//if abs(hsp) > 0 sprite_index = spr_assassin_run;

			
		}

  })
  	.add("patrol rest", {
		enter: function() {
			// rest in between patrol points
			sprite_index = spr_assassin_idle;
			image_index = 0;
			timer_switch_state = timer_max;
			
			
		},
		step: function() {
			
			timer_switch_state--;
			
			//if dead switch to dead state
			if(hp <= 0){
				fsm.change("dead");
			}
			
			
			hsp = lerp(hsp, 0, .15);
			if abs(hsp) <= 0.01 hsp = 0;
			
			//collision and move
			collide_and_move();
			
			if(timer_switch_state <= 0){
				fsm.change("patrol");
			}
			
		
		}
		
 })
  
	.add("chase", {
		enter: function() {
			target_point = obj_player.x;
			
		},
		step: function() {
			
			//if dead switch to dead state
			if(hp <= 0){
				fsm.change("dead");
			}
			
			hsp = sign(target_point - x) * _speed;
		
			//move and collide functions
			collide_and_move();
			determine_facing();
		
			
			//collision and move
			collide_and_move();
			//determine_facing();
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
			
			if sprite_index == spr_boss_gunslinger_fire and animation_end() {
				fsm.change("patrol");
			}
		
			hsp = lerp(hsp, 0, .15);
			if abs(hsp) <= 0.01 hsp = 0;
			//collision and move
			collide_and_move();
			facing = sign (obj_player.x - x);
			//determine_facing();
		}
		
 })
 
 
  	.add("stunned", {
		enter: function() {
			//hsp = 0;
			sprite_index = spr_assassin_idle;
			image_index = 0;
			
			//make it so u can grapple to the enemy adn carry momentum through them
			create_enemy_grapple_target(self, x, y, 30, 200);
		},
		step: function() {
			
			if(hp <= 0 or grappled_to) fsm.change("dead");
			
			
			hsp = lerp(hsp, 0, .15);
			if abs(hsp) <= 0.01 hsp = 0;
			collide_and_move();
		}
		
 })
 
   .add("dead", {
		enter: function() {
			sprite_index = spr_assassin_dead;
			image_index = 0;
			//spray blood
			blood_sprayer(self);
			//sound
			audio_play_sound(snd_crunch2, 1, 0, .1, 0, 1.2);
			audio_play_sound(snd_old_dash, 2, 0, 3, 0, 2);
			//shake
			create_shake();
			//hit pause
			hit_pause(20)
			
			slide_hsp = (obj_player.pushback * 3) * sign(obj_player.facing);
			//in case died to grapple;
			hp = 0;
			
		},
		step: function() {
			hsp = lerp(hsp, 0, .15);
			if abs(hsp) <= 0.1 hsp = 0;
			if slide >= 0 hsp = slide_hsp
			slide--;
			collide_and_move();
		}
			
  });
  
  