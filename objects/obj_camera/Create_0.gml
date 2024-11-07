//create
follow = noone;
pan_inst = noone;
target_x = 0;
target_y = 0;
default_offset_x = 0.45;
default_offset_y = 0.7;

pan_camera = function(_obj){
	if (_obj !=noone){
		global.x_offset = lerp(global.x_offset, _obj.offset_x, 0.03);
		global.y_offset = lerp(global.y_offset, _obj.offset_y, 0.03);
	} else {
		global.y_offset = lerp(global.y_offset, default_offset_y, 0.03);
	}
}

mouse_look = function() {
	
	// Center of the screen in GUI coordinates
	var screen_center_x = obj_player.x;
	var screen_center_y = obj_player.y;

	// Mouse position in screen coordinates
	var mouse_screen_x = mouse_x;
	var mouse_screen_y = mouse_y;

	var distance = point_distance(screen_center_x, screen_center_y, mouse_screen_x, mouse_screen_y);
	var angle = point_direction(screen_center_x, screen_center_y, mouse_screen_x, mouse_screen_y);
	var threshold = 150;
	var max_offset = 2; 
	
	show_debug_message(distance)

	// Only apply the offset if mouse is past threshold
	if (distance > threshold) {
	    // Calculate offset based on distance, clamped to max_offset
	    var offset_amount = min((distance - threshold) / 100, max_offset);

	    // Offset camera position in the direction of the angle
	    x += lengthdir_x(offset_amount, angle);
	    y += lengthdir_y(offset_amount, angle);
	}
}


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
				
				//pan camera if meeting point to pan
				with(follow){
					other.pan_inst = instance_place(x, y, obj_cam_pan);
				}
				
				//pan_camera(pan_inst);
				if pan_inst != noone fsm.change("bounded");
			
			}
		})
		
		
	.add("bounded", {
        enter: function() {
            // Set target to the right side of the sprite
            if (pan_inst != noone) {
                target_x = pan_inst.target_x;
                target_y = pan_inst.target_y;
            }
			follow = noone
        },
        
        step: function() {
			with(obj_player){
				other.pan_inst = instance_place(x, y, obj_cam_pan);
			}
				
			if (!pan_inst){
				follow = obj_player
				fsm.change("follow")
			} else {
                // Smoothly move camera towards the bounding area
                x += (target_x - x) / 15;
				y += (target_y - y) / 15;
            }
        }
    });