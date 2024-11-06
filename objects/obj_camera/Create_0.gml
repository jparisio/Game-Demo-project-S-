//create
follow = noone;
bounds = noone;
target_x = 0;
target_y = 0;

fsm = new SnowState("static")

fsm
	.add("static", {
		enter: function(){
			
		},
		
		step: function(){
			if (follow != noone){
				fsm.change("follow");
			}
		}
		
	})
	
	.add("follow", {
		
		enter: function(){
			
		},
		
		step: function() {
				
				//lerp camera towards follow 
				x += (follow.x - x) / 15;
				y += (follow.y - 30 - y) / 15;
				if(variable_instance_exists(follow, "vsp") && follow.vsp > 0)  {
	                var look_ahead_offset = min(follow.vsp * 30, 100); // Cap the offset to prevent too much look-ahead
	                target_y += look_ahead_offset; 
	            }

				// Move the camera offset depending on if the player is facing left or right
				if (follow == obj_player) {
					if(obj_player.facing == 1){
						global.x_offset = lerp(global.x_offset, 0.48, 0.05);
					} else {
						global.x_offset = lerp(global.x_offset, 0.52, 0.05);
					}
				}
				
				//bounds to move to static cam 
				with(follow){
					other.bounds = instance_place(x, y, obj_cam_hori_offset);
				}
				
				if (bounds != noone) fsm.change("bounded");
			
			}
		})
		
		
	.add("bounded", {
        enter: function() {
            // Set target positions based on bounds for smooth transition
            if (bounds != noone) {
                target_x = bounds.x + (bounds.sprite_width * global.x_offset);
                target_y = bounds.y + (bounds.sprite_height * 0.5); // Center vertically
            }
        },
        
        step: function() {
			with(follow){
				other.bounds = instance_place(x, y, obj_cam_hori_offset);
			}
				
			if (!bounds){
				fsm.change("follow")
			} else {
                // Smoothly move camera towards the bounding area
                x = lerp(x, target_x, 0.04);
                y = lerp(y, target_y, 0.04);
            }
        }
    });