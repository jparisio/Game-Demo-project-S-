
// Function to capture the state and position of each enemy and player
function capture_initial_room_states() {
	// Clear previous states
	global.initial_player_state = [];
	global.initial_enemy_states = [];
    // Capture player states
    var player = instance_find(obj_player, 0); // one player
    if (player != noone) {
        var player_state = {
			_type: "player",
            _x: player.x,
            _y: player.y,
            hp: player.hp,
            state: player.fsm.get_current_state()
        };
        array_push(global.initial_player_state, player_state);
    }

    // Capture enemy states
    var enemy_count = instance_number(obj_enemy);
    for (var i = 0; i < enemy_count; i++) {
        var enemy = instance_find(obj_enemy, i);
        var enemy_state = {
			_type: enemy.object_index,
            _x: enemy.x,
            _y: enemy.y,
            hp: enemy.hp,
            state: enemy.fsm.get_current_state(),
			_id: enemy.id,
        };
        array_push(global.initial_enemy_states, enemy_state);
    }
}


function reset_room_states() {
    // Reset player states
    var player = instance_find(obj_player, 0);
    if (player != noone) {
        var player_state = global.initial_player_state[0];
        player.x = player_state._x;
        player.y = player_state._y;
        player.hp = player_state.hp;
        player.fsm.change(player_state.state);

		//clear the list of grapple targets
		ds_list_clear(player.grapple_target_list);
		player.can_grapple = false
		player.grapple_target = noone;
    }

    // Reset enemy states
    for (var i = 0; i < array_length(global.initial_enemy_states); i++) {
        var enemy_state = global.initial_enemy_states[i];
		// Find by ID from the stored state
        var enemy = instance_find(enemy_state._id, 0); 
        if (enemy != noone) {
            enemy.x = enemy_state._x;
            enemy.y = enemy_state._y;
            enemy.hp = enemy_state.hp;
			//remove movement
			enemy.hsp = 0;
			enemy.vsp = 0;
			//clear the grapple target on self if there is one
			if (variable_instance_exists(enemy, "self_grapple") && enemy.self_grapple != noone && instance_exists(enemy.self_grapple)) {
			    instance_destroy(enemy.self_grapple);
			}
			//switches back to proper state (creates new grapple instance if last state was a grappleable state)
			enemy.fsm.change(enemy_state.state);
        } else {
			// Recreate the enemy if it was deleted
	        var new_enemy = instance_create_layer(enemy_state._x, enemy_state._y, "Enemies", enemy_state._type);
	        new_enemy.hp = enemy_state.hp;
	        new_enemy.fsm.change(enemy_state.state);
		}
    }
	
	//clear the surface in the room
	with (obj_wall_surface_controller) {
		if (surface_exists(big_surface)) {
		    // Clear or reset the surface
		        surface_set_target(big_surface);
		        draw_clear_alpha(c_white, 0);
		        surface_reset_target();
		}
	}
	//destroy all blood instances so it doesnt keep drawing over the room
	instance_destroy(obj_blood);
	instance_destroy(obj_blood_sprayer);
	
	//remove grapple rope (aka katana) so it doesnt keep drawing
	instance_destroy(obj_katana)

	
	//clear the cursor data 
	obj_cursor_controller.lock_on = noone;
	obj_cursor_controller.found_hover = false;
}


