image_index = 0;
image_speed = 0;
alarm[0] = -1;
cooldown = false;
radius = 140;


// Define the FSM structure
fsm = new SnowState("inactive");

// Add states and their logic
fsm
    .add("inactive", {
        enter: function() {
            // Actions to take when entering the 'inactive' state
			obj_player.can_grapple = false;
            image_index = 0; // Show the inactive image
		
        },
        step: function() {
            // Check if player is within range and not in cooldown
            if (point_in_circle(obj_player.x, obj_player.y - 20, x, y, radius) && !cooldown) {
                // Transition to 'active' state
                fsm.change("active");
            }
        }
    })
    .add("active", {
        enter: function() {
            // Actions to take when entering the 'active' state
            image_index = 1; // Show the active image\
			obj_player.grapple_target = self;
			obj_player.can_grapple = true;
			
        },
        step: function() {
            // Check if player is out of range or in cooldown
            if (!point_in_circle(obj_player.x, obj_player.y - 20, x, y, radius) || cooldown) {
                // Reset grapple target if it's this point
                //if (obj_player.grapple_target == self) {
                //    obj_player.grapple_target = noone;
                //}
                // Transition to 'inactive' state
                fsm.change("inactive");
            }
        }
    });

	