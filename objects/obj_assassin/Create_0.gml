hp = 12;
//flash for hit effect
flash_alpha = 0;
flash_colour = c_white;
//hori and verti move
hsp = 0;
vsp = 0;
grv = .28;
facing = 0
_speed = 2.1;
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
	if place_meeting(x+hsp,y,obj_wall) {
	    while !place_meeting(x+sign(hsp),y,obj_wall) {
	        x += sign(hsp);
	    }
	    hsp = 0;
		//show_debug_message(sprite_get_name(mask_index))
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
			sprite_index = spr_assassin_idle;
			if(fsm.get_previous_state() == "walk"){
				sprite_index = spr_assassin_run_to_idle;
			}
			image_index = 0;
			timer_switch_state = timer_max;
			determine_facing();
		},
		step: function() {
			
			if(sprite_index == spr_assassin_run_to_idle and animation_end()){
				sprite_index = spr_assassin_idle;
				image_index = 0;
			}
			//if dead switch to dead state
			if(hp <= 0){
				fsm.change("dead");
			}
			//if hp < 0 fsm.change("dead");
			//to slow down after the run
			collide_and_move();
			//switch to attack if in range and on same level veritcally
			if (abs(obj_player.x - x) <= 50 and timer_attack <= 0 and (abs(obj_player.y - y <= 10))){
				var _attack = random(2)
				//if _attack <= 1 fsm.change("attack1") else fsm.change("attack2")
			}
			//facing player always if alerted
			if (abs(obj_player.x - x) <= 100 and (abs(obj_player.y - y <= 10))) image_xscale = sign(obj_player.x - x)
			//switch to run if timer is up
			if timer_switch_state <= 0 fsm.change("walk");
			
		}

  })
  
	.add("walk", {
		enter: function() {
			sprite_index = spr_warrior_slime_walk;
			if(fsm.get_previous_state() == "idle"){
				sprite_index = spr_assassin_idle_to_run;
			}
			image_index = 0;
			timer_switch_state = timer_max;
	
		},
		step: function() {
			
			if(sprite_index = spr_assassin_idle_to_run and animation_end()){
				sprite_index = spr_assassin_run;
				image_index = 0;
			}
			
			//if dead switch to dead state
			if(hp <= 0){
				fsm.change("dead");
			}
			//if hp < 0 fsm.change("dead");
			//if in range of player attack
			//if (abs(obj_player.x - x) <= 80 and timer_attack <= 0 and (abs(obj_player.y - y <= 10))){
			//	var _attack = random(2)
			//	//if _attack <= 1 fsm.change("attack1") else fsm.change("attack2")
			//}
			//move random direction
			if (move_dir <= 0) hsp = -_speed else hsp = _speed;
			
			//if player is near move towards him
			//if(abs(obj_player.x - x) <= 100) and (abs(obj_player.y - y <= 10)) hsp = 2 * sign(obj_player.x - x);
			
			//check if gonna fall off a ledge and flip if so
			var _side = bbox_right
			if (hsp >= 0) _side = bbox_right else _side = bbox_left
			if !position_meeting(_side + sign(hsp), bbox_bottom + 1, obj_wall) {
				//hsp = 0
				fsm.change("idle")
				move_dir = - move_dir;
			}
			
			//check if youre at wall
			if place_meeting(x + sign(hsp), y, obj_wall){
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
 
 	.add("dead", {
		enter: function() {
			sprite_index = spr_assassin_dead;
			image_index = 0;
			hsp = obj_player.pushback * sign(obj_player.facing)
		},
		step: function() {
			collide_and_move();
		}

  });
  
  