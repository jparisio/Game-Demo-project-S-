
// Function to capture the state and position of each enemy and player
function capture_initial_room_states() {
	// Clear previous states
	global.initial_player_state = [];
	global.initial_enemy_states = [];
	global.initial_wall_states = [];
	global.initial_item_states = [];
    // Capture player states
    var player = instance_find(obj_player, 0); // one player
    if (player != noone) {
        var player_state = {
			_type: "player",
            _x: player.x,
            _y: player.y,
            hp: player.hp,
			hsp: 0,
			vsp: 0,
			facing: player.facing,
            state: player.fsm.get_current_state()
        };
        array_push(global.initial_player_state, player_state);
		
		//reload gun 
		player.gun.reload();
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
	
	//capture window states
	var wall_count = instance_number(obj_wall_parent);
	for (var i = 0; i < wall_count; i++) {
	    var wall = instance_find(obj_wall_parent, i);
	    var wall_state = {
			_mask: wall.mask_index,
			_sprite_index: wall.sprite_index,
			_id: wall.id,
			_x: wall.x,
			_y: wall.y
	    };
	    array_push(global.initial_wall_states, wall_state);
	}
	
	//capture items in room 
	var item_count = instance_number(obj_item_parent);
    for (var i = 0; i < item_count; i++) {
        var item = instance_find(obj_item_parent, i);
        var item_state = {
			_type: item.object_index,
            _x: item.x,
            _y: item.y,
			_id: item.id,
        };
        array_push(global.initial_item_states, item_state);
    }
	//save the game contents if not in the main menu
	if room != Room0 save_game();
}


function reset_room_states() {
    // Reset player states
    var player = instance_find(obj_player, 0);
    if (player != noone) {
        var player_state = global.initial_player_state[0];
        player.x = player_state._x;
        player.y = player_state._y;
        player.hp = player_state.hp;
		player.hsp = player_state.hsp;
		player.vsp = player_state.vsp;
        player.fsm.change(player_state.state);

		//clear the list of grapple targets
		ds_list_clear(player.grapple_target_list);
		player.can_grapple = false
		player.grapple_target = noone;
		//reload gun bullets
		player.gun.reload();
    }

	// Restore enemies
	array_foreach(global.initial_enemy_states, function(enemy_state) {
	    if (instance_exists(enemy_state._id)) {
	        var enemy = enemy_state._id;
	        enemy.x = enemy_state._x;
	        enemy.y = enemy_state._y;
	        enemy.hp = enemy_state.hp;
	        enemy.hsp = 0;
	        enemy.vsp = 0;

	        if (variable_instance_exists(enemy, "self_grapple") && enemy.self_grapple != noone && instance_exists(enemy.self_grapple)) {
	            instance_destroy(enemy.self_grapple);
	        }
        
	        enemy.fsm.change(enemy_state.state);
	    } else {
	        var new_enemy = instance_create_layer(enemy_state._x, enemy_state._y, "Enemies", enemy_state._type);
	        new_enemy.hp = enemy_state.hp;
	        new_enemy.fsm.change(enemy_state.state);
			// Update ID in the stored state
			enemy_state._id = new_enemy.id;
	    }
	});

	// Restore windows
	array_foreach(global.initial_wall_states, function(wall_state) {
	    if (instance_exists(wall_state._id)) {
	        var wall = wall_state._id;
	        wall.mask_index = wall_state._mask;
	        wall.image_index = 0;
			wall.sprite_index = wall_state._sprite_index;
			wall.x = wall_state._x;
			wall.y = wall_state._y;
	    }
	});
	 
	//restore items in room 
	instance_destroy(obj_item_parent);
	array_foreach(global.initial_item_states, function(item) {
	     instance_create_layer(item._x, item._y, "Instances", item._type);
	});

	
	//---------------------------------EXTRAS----------------------------------//
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
	
	//camera snap back to player
	obj_camera.follow = obj_player;
	obj_camera.fsm.change("follow");
	obj_camera.x = obj_player.x;
	obj_camera.y = obj_player.y - 22;
}


