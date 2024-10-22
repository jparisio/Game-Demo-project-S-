image_index = 0;
image_speed = 0;
alarm[0] = -1;
cooldown = false;
radius = 140;
coll_line = 0;
draw_line_ = false;
follow = noone;
grapple_type = noone;
offset = 0;
//mouse hover
mouse_hovering = false;
hover_radius = 40;

active = false;

// Define the FSM structure
fsm = new SnowState("inactive");

// Add states and their logic
fsm
    .add("inactive", {
        enter: function() {
            // Actions to take when entering the 'inactive' state
			//obj_player.can_grapple = false;
            image_index = 0; // Show the inactive image
		
        },
        step: function() {
            // Check if player is within range and not in cooldown
            if (point_in_circle(obj_player.x, obj_player.y - 20, x, y, radius) && !cooldown){
				draw_line_ = true;
                 if (!coll_line) fsm.change("active") 
            } else draw_line_ = false;
        }
    })
    .add("active", {
        enter: function() {
			//show_debug_message("should be adding to list here")
            image_index = 1; // Show the active image
			ds_list_add(obj_player.grapple_target_list, self);
			
        },
        step: function() {
			
			
			//obj_player.can_grapple = true;
            // Check if player is out of range or in cooldown
            if (!point_in_circle(obj_player.x, obj_player.y - 20, x, y, radius) || cooldown || coll_line) {
				//remove the point from the list if the players not already grappling to it
				if(obj_player.fsm.get_current_state() != "grapple initiate" and obj_player.fsm.get_current_state() != "grapple move"){
					//show_debug_message("player state is: " + obj_player.fsm.get_current_state());
	                remove_grapple_target(self);
					fsm.change("inactive");
				}
                
            }
        }
    });

	