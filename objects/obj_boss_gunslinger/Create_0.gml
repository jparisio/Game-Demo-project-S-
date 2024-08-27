//set hp
hp = 300;


//face player upon creation
facing = sign(obj_player.x - x);

//timer for switching states
state_timer = 0;
state_timer_max = 120;

//random state 
rand = 0;

//teleporting
target_x = 0;
dust = noone;

//flash shader
flash_alpha = 0;
flash_colour = c_white;

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
				fsm.change("steady");
			}
			
		}

  })
  
  	.add("steady", {
		enter: function() {
			//set sprite index
			//sprite_index = spr_steady
			//image_index = 0;
			//spawn in reticle
			var _x = random_range(-100, 100) + obj_player.x
			var _y = random_range(-100, 100) + obj_player.y
			instance_create_layer(_x, _y, "Instances", obj_reticle);
			state_timer = state_timer_max;
			rand = irandom_range(0,2);
			//also create the grenadew to throw
			instance_create_layer(x, y - 30, "Instances", obj_grenade);
			
			
			//play this sound at 1:16 https://www.youtube.com/watch?v=FlU4mEjvkz8
			
		},
		step: function() {
			//if animation is over sit on last frame
			//if animation_end() image_index = image_number - 1
			state_timer--;
			//if the animation ends fire the bullet
			if state_timer<=0  and rand >= 1 fsm.change("rockets")
			if state_timer<=0  and rand < 1 fsm.change("teleport")
			
			
		}

  })
  
    
	.add("fire", {
		enter: function() {
			//set sprite index
			//sprite_index = spr_fire
			//image_index = 0;
			//rand = irandom_range(0,2);
			//play this sound https://artlist.io/sfx/track/black-powder-guns---pistol-the-lone-ranger/62778
			// hit impact for this https://kiddolink.itch.io/vfx-fx-hit-impact-pixel-art
		},
		step: function() {
			
			//if the animation ends fire the bullet
			if (animation_end()){
				if(rand <= 1){
					fsm.change("rockets")
				} else {
					fsm.change("teleport")
				}
			}
			
		}

  })
  
  .add("teleport", {
		enter: function() {
			//determine where to tp to
			if (x > 800) target_x = 580 else target_x = 1056;
			//create smoke effects;
			dust = instance_create_layer(x, y, "Instances", obj_dust_bomb);
		},
		step: function() {
			state_timer--;
			//tp to other side
			with(dust){
				if animation_hit_frame(3){
					other. x = -100000;
					//other.dust = instance_create_layer(other.target_x, other.y, "Instances", obj_dust_bomb);
					other.fsm.change("lasers");
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
			var start_x = 542;
			var end_x = 1191;

			// Spacing between each laser (50 pixels)
			var laser_spacing = 50;

			// Loop to create lasers between the specified x-axis range
			for (var i = start_x; i <= end_x; i += laser_spacing) {
			    var laser_x = i;
			    var laser_y = 288; 
    
			    // Create the laser at the specified position
			    instance_create_layer(laser_x, laser_y, "Instances", obj_laser);
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
				if state_timer<=0 fsm.change("steady")
		}

  });
  