//create
follow = noone;
pan_inst = noone;
target_x = 0;
target_y = 0;
val = 0;
start_x = 0;
start_y = 0;


mouse_look = function() {
	
	var screen_center_x = obj_player.x;
	var screen_center_y = obj_player.y - obj_player.sprite_height / 2;

	var mouse_screen_x = mouse_x;
	var mouse_screen_y = mouse_y;

	var distance = point_distance(screen_center_x, screen_center_y, mouse_screen_x, mouse_screen_y);
	var angle = point_direction(screen_center_x, screen_center_y, mouse_screen_x, mouse_screen_y);
	var threshold = 90;
	var max_offset = 2; 
	//show_debug_message(distance)

	// Calculate offset based on distance, clamped to max_offset
	var offset_amount = min(max((distance - threshold) / 100, 0), max_offset);


	x += lengthdir_x(offset_amount, angle);
	y += lengthdir_y(offset_amount, angle);

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
				if follow == noone fsm.change("static");
				//lerp camera towards follow 
				var cam_x = camera_get_view_x(view_camera[0]);
				var cam_y = camera_get_view_y(view_camera[0]);
				var cam_width = camera_get_view_width(view_camera[0]);
				var cam_height = camera_get_view_height(view_camera[0]);
				var center_x = cam_x + (cam_width / 2);
				//deadzone top
				var deadzone_top = cam_y + 200;
				//deadzone bot
				var deadzone_bottom = cam_y + cam_height;
						
				
				if (follow != noone) {
					x += (follow.x - x) / 15;
					//if(follow.y < deadzone_top || follow.y > deadzone_bottom){
						y += (follow.y - 30 - y) / 15;
					//} 
					//if(variable_instance_exists(follow, "vsp") && follow.vsp > 0)  {
		            //    var look_ahead_offset = min(follow.vsp * 30, 100); // Cap the offset to prevent too much look-ahead
		            //    target_y += look_ahead_offset; 
		            //}
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
			follow = noone;
			val = 0;
			start_x = x;
			start_y = y;
        },
        
        step: function() {
			with(obj_player){
				other.pan_inst = instance_place(x, y, obj_cam_pan);
			}
				
			if (!pan_inst){
				follow = obj_player
				fsm.change("follow")
			} else {
				val += 1/60
				x = AnimcurveTween(start_x, target_x, acCubicOut, val);
				y = AnimcurveTween(start_y, target_y, acCubicOut, val);
            }
        }
    });