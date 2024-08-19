//set hp
hp = 300;


//face player upon creation
facing = sign(obj_player.x - x);

//timer for switching states
state_timer = 0;

//flash shader
flash_alpha = 0;
flash_colour = c_white;

//states	
fsm = new SnowState("idle")

fsm
	.add("idle", {
		enter: function() {
			
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
			var _x = random_range(-100, 100) + obj_player.x
			var _y = random_range(-100, 100) + obj_player.y
			instance_create_layer(_x, _y, "Instances", obj_reticle);
			state_timer = 240;
			
		},
		step: function() {
			state_timer--;
			//if the animation ends fire the bullet
			if state_timer<=0 fsm.change("rockets")
			
			
		}

  })
  
    
	.add("fire", {
		enter: function() {
			
		},
		step: function() {
	
			
		}

  })
  
  	.add("rockets", {
		enter: function() {
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
			state_timer = 120;
		},
		step: function() {
				state_timer--;
				if state_timer<=0 fsm.change("steady")
		}

  });
  