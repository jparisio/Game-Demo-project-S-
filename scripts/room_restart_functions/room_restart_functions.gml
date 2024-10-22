
// Function to capture the state and position of each enemy and player
function capture_initial_room_states() {
	// Clear previous states
	global.initial_player_state = [];
	global.initial_enemy_states = [];
    // Capture player states
    var player = instance_find(obj_player, 0); // one player
    if (player != noone) {
        var player_state = {
			type: "player",
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
			type: "enemy",
            _x: enemy.x,
            _y: enemy.y,
            hp: enemy.hp,
            state: enemy.fsm.get_current_state(),
			_id: enemy.id
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
        player.fsm.change(player_state.state); // Restore state
    }

    // Reset enemy states
    for (var i = 0; i < array_length(global.initial_enemy_states); i++) {
        var enemy_state = global.initial_enemy_states[i];
        var enemy = instance_find(enemy_state._id, 0); // Find by ID from the stored state
        if (enemy != noone) {
            enemy.x = enemy_state._x;
            enemy.y = enemy_state._y;
            enemy.hp = enemy_state.hp;
            enemy.fsm.change(enemy_state.state); // Restore enemy state
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
}


